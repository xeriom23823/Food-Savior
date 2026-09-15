import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/statistics/monthly_trend.dart';

import '../helpers/hive_test_helper.dart';

void main() {
  UsedFoodItem consumed(String id, DateTime date, {int point = 1}) =>
      makeUsed(id: id, usedDate: date, affectFoodPoint: point);
  UsedFoodItem wasted(String id, DateTime date) => makeUsed(
      id: id,
      usedDate: date,
      disposalMethod: DisposalMethod.discarded,
      affectFoodPoint: -1);

  group('monthlyTrend（statistics-charts：年月粒度）', () {
    test('空清單 → 空列表', () {
      expect(monthlyTrend(const []), isEmpty);
    });

    test('兩個月的資料：食用與浪費分開加總，沒紀錄的線為 0', () {
      final points = monthlyTrend([
        consumed('a', DateTime(2026, 3, 2), point: 5),
        wasted('b', DateTime(2026, 3, 20)),
        wasted('c', DateTime(2026, 3, 21)),
        consumed('d', DateTime(2026, 4, 1), point: 3),
      ]);
      expect(points, const [
        MonthlyTrendPoint(year: 2026, month: 3, consumed: 5, wasted: -2),
        MonthlyTrendPoint(year: 2026, month: 4, consumed: 3, wasted: 0),
      ]);
      expect(points.first.label, '2026/03');
    });

    test('跨年資料不疊加：2025/12 與 2026/12 是不同刻度', () {
      final points = monthlyTrend([
        consumed('a', DateTime(2025, 12, 5), point: 3),
        consumed('b', DateTime(2026, 12, 5), point: 5),
      ], maxMonths: 24);
      expect(points.length, 13);
      expect(
          points.first,
          const MonthlyTrendPoint(
              year: 2025, month: 12, consumed: 3, wasted: 0));
      expect(
          points.last,
          const MonthlyTrendPoint(
              year: 2026, month: 12, consumed: 5, wasted: 0));
    });

    test('中間月份補 0 並依時間排序（輸入順序無關）', () {
      final points = monthlyTrend([
        consumed('later', DateTime(2026, 3, 1)),
        consumed('earlier', DateTime(2026, 1, 15)),
      ]);
      expect(points.map((p) => p.label), ['2026/01', '2026/02', '2026/03']);
      expect(
          points[1],
          const MonthlyTrendPoint(
              year: 2026, month: 2, consumed: 0, wasted: 0));
    });

    test('超過 12 個月只保留最近 12 個月', () {
      final points = monthlyTrend([
        consumed('old', DateTime(2025, 1, 1)),
        consumed('new', DateTime(2026, 3, 1)),
      ]);
      expect(points.length, 12);
      expect(points.first.label, '2026/04'.replaceFirst('2026/04', '2025/04'));
      expect(points.last.label, '2026/03');
    });

    test('點數為 0 的食用紀錄（達每日上限）不改變總和但仍算入月份範圍', () {
      final points = monthlyTrend([
        consumed('capped', DateTime(2026, 5, 1), point: 0),
      ]);
      expect(points, const [
        MonthlyTrendPoint(year: 2026, month: 5, consumed: 0, wasted: 0),
      ]);
    });
  });
}
