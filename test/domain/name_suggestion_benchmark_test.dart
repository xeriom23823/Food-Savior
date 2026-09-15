import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/domain/import/product_name_cleaner.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/models/food_preset.dart';
import 'package:food_savior/models/food_suggestion.dart';
import 'package:food_savior/models/storage_location.dart';

/// 命中率基準（item-normalization 規格）。
///
/// 存在的理由：在這之前沒有任何方式知道「名稱 → 類型」的命中率是多少，
/// 也無從判斷改了對照表之後是變好還是變壞。這個測試把它變成一個會擋回歸的數字。
///
/// **走完整管線**（清洗 → 推導），不是只測比對函式——否則量到的不是使用者
/// 實際會遇到的命中率。
void main() {
  /// 類型推導的命中率門檻。
  ///
  /// 實測歷程（2026-09-15，同一份樣本）：
  /// - 擴充對照表前：**63.9%**（61 筆中 39 筆）
  /// - 擴充對照表後：**98.4%**（唯一漏的是「巧克力蛋糕」被歸成零食）
  /// - 改用「最靠近字尾的命中優先」後：100%
  /// - 補進 18 筆**沒有為其調整過字典**的難樣本後：**79.7%**（79 筆中 63 筆）
  /// - 依基準指出的缺口補上台式熟食與小吃後：**98.7%**（79 筆中 78 筆）
  ///
  /// **這個數字高估了真實表現**：後半段是照著這份基準調字典調出來的。
  /// 拿到真實發票字串時要補進樣本，屆時數字會掉，那才是真的（design「Risks」）。
  ///
  /// 唯一仍未命中的「菜脯蛋」是標註本身有爭議（它確實是蛋料理），刻意留著——
  /// 一個永遠 100% 的基準等於沒有基準。
  ///
  /// 門檻設得比實測略低，留一點雜訊空間；任何實質下降都會讓這個測試變紅。
  const double typeHitRateThreshold = 0.92;

  late List<_Sample> samples;
  late FoodSuggestionEngine engine;
  late ProductNameCleaner cleaner;

  setUpAll(() {
    samples = (json.decode(
      File('test/fixtures/product_names/benchmark.json').readAsStringSync(),
    ) as List)
        .cast<Map<String, dynamic>>()
        .map(_Sample.fromJson)
        .toList();

    engine = FoodSuggestionEngine(
      presets: (json.decode(
        File('assets/data/food_presets.json').readAsStringSync(),
      ) as List)
          .cast<Map<String, dynamic>>()
          .map(FoodPreset.fromJson)
          .toList(),
    );

    final noise = json.decode(
      File('assets/data/product_noise_terms.json').readAsStringSync(),
    ) as Map;
    cleaner = ProductNameCleaner(noiseTerms: [
      for (final group in noise.values) ...(group as List).cast<String>(),
    ]);
  });

  FoodItemType typeFor(String rawName) => engine
      .suggest(
        name: cleaner.clean(rawName).coreName,
        now: DateTime(2026, 9, 15),
      )
      .type;

  test('類型推導的命中率不低於門檻', () {
    final misses = <String>[];
    for (final sample in samples) {
      final actual = typeFor(sample.name);
      if (actual != sample.type) {
        misses.add('${sample.name}: 期望 ${sample.type.name}，實際 ${actual.name}');
      }
    }

    final hitRate = (samples.length - misses.length) / samples.length;

    expect(
      hitRate,
      greaterThanOrEqualTo(typeHitRateThreshold),
      reason: '命中率 ${(hitRate * 100).toStringAsFixed(1)}% '
          '（${samples.length - misses.length}/${samples.length}）'
          '低於門檻 ${(typeHitRateThreshold * 100).toStringAsFixed(0)}%。\n'
          '推導錯誤的樣本：\n${misses.join('\n')}',
    );
  });

  test('基準樣本涵蓋類型消歧案例（短詞是長詞前綴但類型不同）', () {
    // design D3 (a) 表列的每一組。少了任何一組，這個基準就擋不住最容易發生的回歸。
    const pairs = [
      ['牛奶', '牛奶糖'],
      ['蛋', '蛋糕'],
      ['蛋', '雞蛋豆腐'],
      ['沙拉', '沙拉油'],
      ['花生', '花生醬'],
    ];

    for (final pair in pairs) {
      final short = pair[0];
      final long = pair[1];

      final longSample =
          samples.where((s) => s.name.contains(long)).firstOrNull;
      final shortSample = samples
          .where((s) => s.name.contains(short) && !s.name.contains(long))
          .firstOrNull;

      expect(longSample, isNotNull, reason: '基準缺少含「$long」的樣本');
      expect(shortSample, isNotNull, reason: '基準缺少含「$short」但不含「$long」的樣本');
      expect(
        longSample!.type,
        isNot(shortSample!.type),
        reason: '「$short」與「$long」的樣本期望類型相同，類型消歧沒有被測到',
      );
    }
  });

  test('類型消歧在實際推導上生效', () {
    expect(typeFor('森永牛奶糖'), FoodItemType.snack);
    expect(typeFor('光泉牛奶936ML'), FoodItemType.eggAndMilk);
    expect(typeFor('巧克力蛋糕'), isNot(FoodItemType.eggAndMilk));
    expect(typeFor('雞蛋10入'), FoodItemType.eggAndMilk);
    expect(typeFor('雞蛋豆腐'), FoodItemType.cookedFood);
    expect(typeFor('得意的一天沙拉油2L'), isNot(FoodItemType.vegetable));
    expect(typeFor('生菜沙拉'), FoodItemType.vegetable);
    expect(typeFor('花生醬340g'), isNot(FoodItemType.snack));
    expect(typeFor('花生'), FoodItemType.snack);
  });

  test('類型相同但保存期限差很多的消歧也要生效', () {
    // design D3 (b)：型別斷言抓不到，要斷言天數。
    int? daysFor(String name) => engine
        .presetFor(cleaner.clean(name).coreName)
        ?.daysFor(LocationKind.refrigerated);

    expect(daysFor('安佳奶油227g'), isNotNull);
    expect(daysFor('鮮奶油200ml'), isNotNull);
    expect(
      daysFor('鮮奶油200ml'),
      lessThan(daysFor('安佳奶油227g')!),
      reason: '鮮奶油比奶油容易壞，建議期限必須更短',
    );

    expect(daysFor('池上米2kg'), isNotNull);
    expect(
      daysFor('池上米2kg'),
      greaterThan(daysFor('鮮奶油200ml')!),
      reason: '米是常溫乾貨，期限應遠長於乳製品',
    );
  });

  test('基準樣本的期望類型都是合法列舉且分佈夠廣', () {
    final covered = samples.map((s) => s.type).toSet();

    // 涵蓋太少類型的基準量不出真實命中率。
    expect(covered.length, greaterThanOrEqualTo(8));
    expect(samples.length, greaterThanOrEqualTo(50));
  });
}

class _Sample {
  const _Sample(this.name, this.type);

  factory _Sample.fromJson(Map<String, dynamic> data) => _Sample(
        data['name'] as String,
        FoodItemType.values.firstWhere(
          (value) => value.name == data['type'],
          orElse: () => throw ArgumentError('未知的類型：${data['type']}'),
        ),
      );

  final String name;
  final FoodItemType type;
}
