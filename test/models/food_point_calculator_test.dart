import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/models/food_point_calculator.dart';

import '../helpers/hive_test_helper.dart';

void main() {
  const calculator = FoodPointCalculator();

  int basePoint(DisposalMethod method,
          {DateTime? expiry, DateTime? usedDate}) =>
      calculator.basePointFor(
        disposalMethod: method,
        effectiveExpiry: expiry,
        usedDate: usedDate ?? testNow,
      );

  group('依時效加權的基本分', () {
    test('到期前 1 天吃完是即期救援 +3', () {
      expect(basePoint(DisposalMethod.eaten, expiry: daysFromNow(1)), 3);
    });

    test('距到期還有 10 天是一般食用 +2', () {
      expect(basePoint(DisposalMethod.eaten, expiry: daysFromNow(10)), 2);
    });

    test('期限未知的食用是 +2', () {
      expect(basePoint(DisposalMethod.eaten, expiry: null), 2);
    });

    test('過期後才吃掉是 +1', () {
      expect(basePoint(DisposalMethod.eatenAtRisk, expiry: daysFromNow(-1)), 1);
    });

    test('送人比照食用，未過期給 +2', () {
      expect(basePoint(DisposalMethod.givenAway, expiry: daysFromNow(10)), 2);
    });

    test('還沒過期就丟掉是 -3', () {
      expect(basePoint(DisposalMethod.discarded, expiry: daysFromNow(5)), -3);
    });

    test('過期後丟棄是 -2', () {
      expect(basePoint(DisposalMethod.discarded, expiry: daysFromNow(-1)), -2);
    });

    test('堆肥優於丟棄', () {
      expect(basePoint(DisposalMethod.composted, expiry: daysFromNow(-1)), -1);
      expect(basePoint(DisposalMethod.composted, expiry: daysFromNow(5)), -2);
    });

    test('期限未知的丟棄視為未過期 -3', () {
      expect(basePoint(DisposalMethod.discarded, expiry: null), -3);
    });
  });

  group('每日加分上限', () {
    UsedFoodItem consumed({required DateTime expiry, int point = 2}) =>
        makeUsed(
          disposalMethod: DisposalMethod.eaten,
          expiry: expiry,
          affectFoodPoint: point,
        );

    test('當日正分已達 10 時新的加分為 0', () {
      final existing = List.generate(
        5,
        (index) => consumed(expiry: daysFromNow(10)),
      );

      final point = calculator.pointFor(
        consumed(expiry: daysFromNow(10)),
        existing,
      );

      expect(point, 0);
    });

    test('差額截斷：只剩 1 分時 +3 變成 1', () {
      final existing = [
        consumed(expiry: daysFromNow(10), point: 3),
        consumed(expiry: daysFromNow(10), point: 3),
        consumed(expiry: daysFromNow(10), point: 3),
      ];

      final point = calculator.pointFor(
        consumed(expiry: daysFromNow(1)),
        existing,
      );

      expect(point, 1);
    });

    test('負分不放寬上限', () {
      final existing = [
        consumed(expiry: daysFromNow(10), point: 3),
        consumed(expiry: daysFromNow(10), point: 3),
        consumed(expiry: daysFromNow(10), point: 2),
        consumed(expiry: daysFromNow(10), point: 2),
        makeUsed(
          disposalMethod: DisposalMethod.discarded,
          expiry: daysFromNow(5),
          affectFoodPoint: -3,
        ),
      ];

      final point = calculator.pointFor(
        consumed(expiry: daysFromNow(10)),
        existing,
      );

      expect(point, 0);
    });

    test('上限不影響浪費', () {
      final existing = List.generate(
        6,
        (index) => consumed(expiry: daysFromNow(10)),
      );

      final point = calculator.pointFor(
        makeUsed(
          disposalMethod: DisposalMethod.discarded,
          expiry: daysFromNow(-1),
        ),
        existing,
      );

      expect(point, -2);
    });

    test('不同日期的正分不互相佔用額度', () {
      final existing = List.generate(
        5,
        (index) => consumed(expiry: daysFromNow(10)),
      );

      final point = calculator.pointFor(
        makeUsed(
          disposalMethod: DisposalMethod.eaten,
          expiry: daysFromNow(10),
          usedDate: daysFromNow(-1),
        ),
        existing,
      );

      expect(point, 2);
    });
  });
}
