import 'package:food_savior/models/expiry.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/models/food_preset.dart';
import 'package:food_savior/models/storage_location.dart';

/// 使用者常用食物模板：由歷史推導，不另外維護一份清單（design D16）。
class FoodTemplate {
  const FoodTemplate({
    required this.name,
    required this.type,
    required this.usageCount,
    required this.lastUsedAt,
    this.amount,
    this.unit,
    this.storageLocationId,
    this.shelfLifeDays,
    this.shelfLifeAfterOpenDays,
  });

  final String name;
  final FoodItemType type;
  final int usageCount;
  final DateTime lastUsedAt;
  final double? amount;
  final Unit? unit;
  final String? storageLocationId;

  /// 「存放日到期限」的天數差，當作下次的預設效期。
  final int? shelfLifeDays;
  final int? shelfLifeAfterOpenDays;
}

/// 快速新增與表單的建議來源。順序：使用者模板 → 內建對照表 → 未知（design D17）。
///
/// 任何一步都不阻擋送出；「存得下去」永遠優先於「存得完整」。
class FoodSuggestionEngine {
  const FoodSuggestionEngine({
    this.templates = const [],
    this.presets = const [],
  });

  final List<FoodTemplate> templates;
  final List<FoodPreset> presets;

  /// 由歷史推導常用模板：出現次數多的在前，同次數則最近用過的在前。
  static List<FoodTemplate> templatesFromHistory({
    required List<FoodItem> foodItems,
    required List<UsedFoodItem> usedFoodItems,
    int limit = 12,
  }) {
    final byName = <String, List<FoodItem>>{};
    for (final item in [...foodItems, ...usedFoodItems]) {
      byName
          .putIfAbsent(normalizeFoodName(item.name), () => <FoodItem>[])
          .add(item);
    }

    final templates = <FoodTemplate>[];
    for (final entry in byName.entries) {
      final items = List<FoodItem>.of(entry.value)
        ..sort((a, b) => _lastTouched(a).compareTo(_lastTouched(b)));
      final latest = items.last;
      final expiry = latest.expiryEarliest;
      templates.add(FoodTemplate(
        name: latest.name,
        type: latest.type,
        usageCount: items.length,
        lastUsedAt: _lastTouched(latest),
        amount: latest.amount,
        unit: latest.unit,
        storageLocationId: latest.storageLocationId,
        shelfLifeDays: expiry?.difference(latest.storageDate).inDays,
        shelfLifeAfterOpenDays: latest.shelfLifeAfterOpenDays,
      ));
    }

    templates.sort((a, b) {
      final byCount = b.usageCount.compareTo(a.usageCount);
      return byCount != 0 ? byCount : b.lastUsedAt.compareTo(a.lastUsedAt);
    });
    return templates.take(limit).toList();
  }

  static DateTime _lastTouched(FoodItem item) =>
      item is UsedFoodItem ? item.usedDate : item.storageDate;

  FoodTemplate? templateFor(String name) {
    final normalized = normalizeFoodName(name);
    if (normalized.isEmpty) return null;
    for (final template in templates) {
      if (normalizeFoodName(template.name) == normalized) return template;
    }
    return null;
  }

  /// 命中多個關鍵字時，選**最靠近字尾**的那一個（design D4）。
  ///
  /// 中文複合詞的中心語在字尾：「巧克力蛋糕」是蛋糕、「牛奶糖」是糖、
  /// 「鮪魚罐頭」是罐頭。單看長度會選到修飾語——「巧克力」比「蛋糕」長，
  /// 於是巧克力蛋糕被歸成零食。位置優先才符合中文的構詞。
  ///
  /// 結束位置相同時比長度（「雞蛋豆腐」勝過「豆腐」），再相同時比字典序。
  /// 最後這一關實務上碰不到（結束位置與長度都相同就是同一個子字串），
  /// 留著是為了讓結果**與對照表在檔案裡的排列順序無關**——否則把 JSON
  /// 重新排序就可能改變推導結果，那種 bug 極難追。
  FoodPreset? presetFor(String name) {
    final normalized = normalizeFoodName(name);
    if (normalized.isEmpty) return null;

    FoodPreset? best;
    _KeywordMatch? bestMatch;
    for (final preset in presets) {
      for (final keyword in preset.keywords) {
        final normalizedKeyword = normalizeFoodName(keyword);
        if (normalizedKeyword.isEmpty) continue;
        final start = normalized.lastIndexOf(normalizedKeyword);
        if (start < 0) continue;
        final match = _KeywordMatch(
          normalizedKeyword,
          start + normalizedKeyword.length,
        );
        if (bestMatch == null || match.beats(bestMatch)) {
          best = preset;
          bestMatch = match;
        }
      }
    }
    return best;
  }

  /// 給一個名稱，推出建立草稿所需的欄位。
  FoodSuggestion suggest({
    required String name,
    required DateTime now,
    LocationKind? locationKind,
    String? defaultLocationId,
  }) {
    final template = templateFor(name);
    if (template != null) {
      final days = template.shelfLifeDays;
      return FoodSuggestion(
        type: template.type,
        amount: template.amount ?? 1,
        unit: template.unit ?? Unit.piece,
        storageLocationId: template.storageLocationId ?? defaultLocationId,
        expiry: days == null || days <= 0
            ? const ExpiryValue.unknown()
            : ExpiryValue.exact(now.add(Duration(days: days))),
        shelfLifeAfterOpenDays: template.shelfLifeAfterOpenDays,
        source: SuggestionSource.template,
      );
    }

    final preset = presetFor(name);
    final kind = locationKind ?? LocationKind.refrigerated;
    if (preset != null) {
      final days = preset.daysFor(kind);
      return FoodSuggestion(
        type: preset.type,
        amount: 1,
        unit: preset.unit ?? Unit.piece,
        storageLocationId: defaultLocationId,
        expiry: days == null
            ? const ExpiryValue.unknown()
            : ExpiryValue.exact(now.add(Duration(days: days))),
        shelfLifeAfterOpenDays: preset.afterOpenDays,
        source: SuggestionSource.preset,
      );
    }

    return FoodSuggestion(
      type: FoodItemType.others,
      amount: 1,
      unit: Unit.piece,
      storageLocationId: defaultLocationId,
      expiry: const ExpiryValue.unknown(),
      source: SuggestionSource.none,
    );
  }

  /// 已知類型時，依存放方式建議天數（表單切換位置時用）。
  int? shelfLifeFor({required FoodItemType type, required LocationKind kind}) {
    final table = kFallbackShelfLife[type];
    return table?[kind] ?? table?[LocationKind.ambient];
  }
}

enum SuggestionSource { template, preset, none }

class FoodSuggestion {
  const FoodSuggestion({
    required this.type,
    required this.expiry,
    required this.source,
    this.amount,
    this.unit,
    this.storageLocationId,
    this.shelfLifeAfterOpenDays,
  });

  final FoodItemType type;
  final ExpiryValue expiry;
  final SuggestionSource source;
  final double? amount;
  final Unit? unit;
  final String? storageLocationId;
  final int? shelfLifeAfterOpenDays;
}

/// 一個關鍵字在名稱中的命中位置，用來決定哪一個勝出（design D4）。
class _KeywordMatch {
  const _KeywordMatch(this.keyword, this.end);

  final String keyword;

  /// 命中片段在名稱中的結束位置（不含）。越靠近字尾越優先。
  final int end;

  bool beats(_KeywordMatch other) {
    if (end != other.end) return end > other.end;
    if (keyword.length != other.keyword.length) {
      return keyword.length > other.keyword.length;
    }
    return keyword.compareTo(other.keyword) < 0;
  }
}
