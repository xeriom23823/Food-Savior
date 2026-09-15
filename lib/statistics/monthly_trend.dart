import 'package:equatable/equatable.dart';
import 'package:food_savior/models/food_item.dart';

/// 某個年月的食物點數彙總（statistics-charts 規格）。
class MonthlyTrendPoint extends Equatable {
  const MonthlyTrendPoint({
    required this.year,
    required this.month,
    required this.consumed,
    required this.wasted,
  });

  final int year;
  final int month;

  /// 該月 `consumed` 紀錄的 affectFoodPoint 總和（≥ 0）。
  final int consumed;

  /// 該月 `wasted` 紀錄的 affectFoodPoint 總和（≤ 0，維持負值語意）。
  final int wasted;

  /// X 軸刻度文字，例如 `2026/03`。
  String get label => '$year/${month.toString().padLeft(2, '0')}';

  @override
  List<Object> get props => [year, month, consumed, wasted];
}

/// 依「年月」彙總使用紀錄的點數：從最早到最晚的月份連續列出，
/// 中間沒有紀錄的月份補 0，最多保留最近 [maxMonths] 個月。空清單回傳空列表。
List<MonthlyTrendPoint> monthlyTrend(
  Iterable<UsedFoodItem> items, {
  int maxMonths = 12,
}) {
  final consumedByMonth = <int, int>{};
  final wastedByMonth = <int, int>{};
  int? first;
  int? last;

  for (final item in items) {
    final key = _monthIndex(item.usedDate.year, item.usedDate.month);
    first = first == null || key < first ? key : first;
    last = last == null || key > last ? key : last;
    if (item.status == FoodItemStatus.consumed) {
      consumedByMonth[key] = (consumedByMonth[key] ?? 0) + item.affectFoodPoint;
    } else if (item.status == FoodItemStatus.wasted) {
      wastedByMonth[key] = (wastedByMonth[key] ?? 0) + item.affectFoodPoint;
    }
  }
  if (first == null || last == null) return const [];

  final start = last - first + 1 > maxMonths ? last - maxMonths + 1 : first;
  return [
    for (var key = start; key <= last; key++)
      MonthlyTrendPoint(
        year: key ~/ 12,
        month: key % 12 + 1,
        consumed: consumedByMonth[key] ?? 0,
        wasted: wastedByMonth[key] ?? 0,
      ),
  ];
}

int _monthIndex(int year, int month) => year * 12 + (month - 1);
