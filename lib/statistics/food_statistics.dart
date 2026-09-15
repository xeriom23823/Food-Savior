import 'package:equatable/equatable.dart';
import 'package:food_savior/models/food_item.dart';

/// 某年月的浪費率（statistics-charts 規格）。
///
/// 沒有任何紀錄的月份不會出現在結果中——0% 代表「當月完全沒浪費」，
/// 與「當月沒資料」是兩件事，畫成同一條線會誤導。
class WasteRatePoint extends Equatable {
  const WasteRatePoint({
    required this.year,
    required this.month,
    required this.wastedCount,
    required this.totalCount,
  });

  final int year;
  final int month;
  final int wastedCount;
  final int totalCount;

  double get rate => totalCount == 0 ? 0 : wastedCount / totalCount;

  String get label => '$year/${month.toString().padLeft(2, '0')}';

  @override
  List<Object?> get props => [year, month, wastedCount, totalCount];
}

List<WasteRatePoint> wasteRateTrend(
  Iterable<UsedFoodItem> items, {
  int maxMonths = 12,
}) {
  final totals = <int, int>{};
  final wasted = <int, int>{};

  for (final item in items) {
    final key = item.usedDate.year * 12 + (item.usedDate.month - 1);
    totals[key] = (totals[key] ?? 0) + 1;
    if (item.isWaste) wasted[key] = (wasted[key] ?? 0) + 1;
  }
  if (totals.isEmpty) return const [];

  final keys = totals.keys.toList()..sort();
  final kept =
      keys.length > maxMonths ? keys.sublist(keys.length - maxMonths) : keys;

  return [
    for (final key in kept)
      WasteRatePoint(
        year: key ~/ 12,
        month: key % 12 + 1,
        wastedCount: wasted[key] ?? 0,
        totalCount: totals[key]!,
      ),
  ];
}

/// 依類型的筆數分布。點數加權後不再等比例反映行為，所以圓餅圖數筆數。
Map<FoodItemType, int> countByType(
  Iterable<UsedFoodItem> items, {
  required bool waste,
}) {
  final counts = <FoodItemType, int>{};
  for (final item in items.where((item) => item.isWaste == waste)) {
    counts[item.type] = (counts[item.type] ?? 0) + 1;
  }
  return counts;
}

class WastedFoodRank extends Equatable {
  const WastedFoodRank({
    required this.name,
    required this.count,
    required this.totalPrice,
    required this.lastWastedAt,
  });

  final String name;
  final int count;

  /// 有填金額的紀錄加總；沒有任何金額時為 null。
  final int? totalPrice;
  final DateTime lastWastedAt;

  @override
  List<Object?> get props => [name, count, totalPrice, lastWastedAt];
}

/// 最常浪費的食物排行。筆數相同時，最近浪費過的排前面。
List<WastedFoodRank> topWastedFoods(
  Iterable<UsedFoodItem> items, {
  int limit = 5,
}) {
  final grouped = <String, List<UsedFoodItem>>{};
  for (final item in items.where((item) => item.isWaste)) {
    grouped
        .putIfAbsent(normalizeFoodName(item.name), () => <UsedFoodItem>[])
        .add(item);
  }

  final ranks = grouped.values.map((records) {
    final prices =
        records.map((record) => record.priceTotal).whereType<int>().toList();
    final lastWastedAt = records
        .map((record) => record.usedDate)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    return WastedFoodRank(
      name: records.last.name,
      count: records.length,
      totalPrice: prices.isEmpty ? null : prices.reduce((a, b) => a + b),
      lastWastedAt: lastWastedAt,
    );
  }).toList()
    ..sort((a, b) {
      final byCount = b.count.compareTo(a.count);
      return byCount != 0 ? byCount : b.lastWastedAt.compareTo(a.lastWastedAt);
    });

  return ranks.take(limit).toList();
}

/// 浪費原因分布。未填原因的以 null 為 key，讓 UI 能顯示這張圖的完整度。
Map<WasteReason?, int> wasteReasonBreakdown(Iterable<UsedFoodItem> items) {
  final counts = <WasteReason?, int>{};
  for (final item in items.where((item) => item.isWaste)) {
    counts[item.wasteReason] = (counts[item.wasteReason] ?? 0) + 1;
  }
  return counts;
}

class MoneySummary extends Equatable {
  const MoneySummary({
    required this.saved,
    required this.lost,
    required this.withPrice,
    required this.total,
  });

  final int saved;
  final int lost;
  final int withPrice;
  final int total;

  /// 有金額的紀錄佔比。使用者必須看得到這個數字，才不會把局部當全貌。
  double get coverage => total == 0 ? 0 : withPrice / total;

  bool get hasData => withPrice > 0;

  @override
  List<Object?> get props => [saved, lost, withPrice, total];
}

MoneySummary moneySummary(Iterable<UsedFoodItem> items) {
  var saved = 0;
  var lost = 0;
  var withPrice = 0;
  var total = 0;

  for (final item in items) {
    total++;
    final price = item.priceTotal;
    if (price == null) continue;
    withPrice++;
    if (item.isWaste) {
      lost += price;
    } else {
      saved += price;
    }
  }

  return MoneySummary(
    saved: saved,
    lost: lost,
    withPrice: withPrice,
    total: total,
  );
}
