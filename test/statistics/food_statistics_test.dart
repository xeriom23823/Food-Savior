import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/statistics/food_statistics.dart';

import '../helpers/hive_test_helper.dart';

void main() {
  UsedFoodItem eaten({String id = 'e', FoodItemType? type, int? price}) =>
      makeUsed(
        id: id,
        type: type ?? FoodItemType.vegetable,
        disposalMethod: DisposalMethod.eaten,
        priceTotal: price,
      );

  UsedFoodItem discarded({
    String id = 'd',
    String? name,
    FoodItemType? type,
    int? price,
    WasteReason? reason,
    DateTime? usedDate,
  }) =>
      makeUsed(
        id: id,
        name: name,
        type: type ?? FoodItemType.vegetable,
        disposalMethod: DisposalMethod.discarded,
        priceTotal: price,
        wasteReason: reason,
        usedDate: usedDate,
      );

  group('依類型的筆數分布', () {
    test('數筆數而不是點數', () {
      final items = [
        makeUsed(id: 'a', type: FoodItemType.vegetable, affectFoodPoint: 3),
        makeUsed(id: 'b', type: FoodItemType.fruit, affectFoodPoint: 1),
        makeUsed(id: 'c', type: FoodItemType.fruit, affectFoodPoint: 1),
        makeUsed(id: 'd', type: FoodItemType.fruit, affectFoodPoint: 1),
      ];

      final counts = countByType(items, waste: false);

      expect(counts[FoodItemType.vegetable], 1);
      expect(counts[FoodItemType.fruit], 3);
    });

    test('送人計入食用側', () {
      final counts = countByType(
        [makeUsed(id: 'g', disposalMethod: DisposalMethod.givenAway)],
        waste: false,
      );

      expect(counts.values.fold<int>(0, (sum, value) => sum + value), 1);
    });
  });

  group('浪費率趨勢', () {
    test('以筆數計算比率', () {
      final march = DateTime(2026, 3, 10);
      final april = DateTime(2026, 4, 10);
      final items = [
        for (var i = 0; i < 8; i++) eaten(id: 'm$i').copyWith(usedDate: march),
        for (var i = 0; i < 2; i++)
          discarded(id: 'md$i').copyWith(usedDate: march),
        for (var i = 0; i < 9; i++) eaten(id: 'a$i').copyWith(usedDate: april),
        discarded(id: 'ad').copyWith(usedDate: april),
      ];

      final points = wasteRateTrend(items);

      expect(
          points.map((point) => point.label).toList(), ['2026/03', '2026/04']);
      expect(points[0].rate, closeTo(0.2, 0.0001));
      expect(points[1].rate, closeTo(0.1, 0.0001));
    });

    test('沒有紀錄的月份不會被畫成 0%', () {
      final items = [
        eaten(id: 'a').copyWith(usedDate: DateTime(2026, 1, 5)),
        eaten(id: 'b').copyWith(usedDate: DateTime(2026, 3, 5)),
      ];

      final points = wasteRateTrend(items);

      expect(
          points.map((point) => point.label).toList(), ['2026/01', '2026/03']);
    });
  });

  group('最常浪費排行', () {
    test('依筆數排序並加總金額', () {
      final items = [
        for (var i = 0; i < 4; i++) discarded(id: 'p$i', name: '青椒', price: 10),
        discarded(id: 'm1', name: '牛奶', price: 50),
        discarded(id: 'm2', name: '牛奶'),
        eaten(id: 'ignored'),
      ];

      final ranks = topWastedFoods(items);

      expect(ranks.first.name, '青椒');
      expect(ranks.first.count, 4);
      expect(ranks.first.totalPrice, 40);
      expect(ranks[1].name, '牛奶');
      expect(ranks[1].totalPrice, 50);
    });
  });

  group('浪費原因分布', () {
    test('未填原因也要能被看見', () {
      final items = [
        for (var i = 0; i < 6; i++)
          discarded(id: 'r$i', reason: WasteReason.forgotten),
        for (var i = 0; i < 4; i++) discarded(id: 'n$i'),
      ];

      final breakdown = wasteReasonBreakdown(items);

      expect(breakdown[WasteReason.forgotten], 6);
      expect(breakdown[null], 4);
    });
  });

  group('金額損益', () {
    test('只統計有金額的紀錄並標示涵蓋率', () {
      final items = [
        eaten(id: 'a', price: 100),
        discarded(id: 'b', price: 40),
        eaten(id: 'c'),
        eaten(id: 'd'),
      ];

      final summary = moneySummary(items);

      expect(summary.saved, 100);
      expect(summary.lost, 40);
      expect(summary.withPrice, 2);
      expect(summary.total, 4);
      expect(summary.coverage, 0.5);
    });

    test('完全沒有金額時 hasData 為 false', () {
      expect(moneySummary([eaten(id: 'a')]).hasData, isFalse);
    });
  });
}
