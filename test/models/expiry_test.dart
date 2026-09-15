import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/models/expiry.dart';
import 'package:food_savior/models/food_item.dart';

import '../helpers/hive_test_helper.dart';

void main() {
  group('ExpiryValue 四種精度', () {
    test('exact：earliest 與 latest 同一天', () {
      final value = ExpiryValue.exact(DateTime(2026, 10, 1, 23, 30));

      expect(value.precision, ExpiryPrecision.exact);
      expect(value.earliest, DateTime(2026, 10, 1));
      expect(value.latest, DateTime(2026, 10, 1));
      expect(value.isApproximate, isFalse);
    });

    test('range：保留使用者輸入的順序，不自動對調', () {
      final value =
          ExpiryValue.range(DateTime(2026, 10, 5), DateTime(2026, 10, 1));

      expect(value.earliest, DateTime(2026, 10, 5));
      expect(value.latest, DateTime(2026, 10, 1));
      expect(value.isApproximate, isTrue);
    });

    test('monthOnly：涵蓋整個月份', () {
      final value = ExpiryValue.month(2026, 10);

      expect(value.earliest, DateTime(2026, 10, 1));
      expect(value.latest, DateTime(2026, 10, 31));
    });

    test('unknown：兩個日期都是 null', () {
      const value = ExpiryValue.unknown();

      expect(value.earliest, isNull);
      expect(value.latest, isNull);
      expect(value.isKnown, isFalse);
    });
  });

  group('有效期限與狀態推導', () {
    test('沒有開封資訊時等於 expiryEarliest', () {
      final item = makeFood(daysToExpire: 5);

      expect(item.effectiveExpiry, daysFromNow(5));
    });

    test('開封後效期較早時取開封後的日期', () {
      final item = makeFood(
        daysToExpire: 10,
        openedDate: testNow,
        shelfLifeAfterOpenDays: 3,
      );

      expect(item.effectiveExpiry, daysFromNow(3));
      expect(item.statusAt(testNow), FoodItemStatus.nearExpired);
    });

    test('原期限較早時不被開封後效期延長', () {
      final item = makeFood(
        daysToExpire: 2,
        openedDate: testNow,
        shelfLifeAfterOpenDays: 30,
      );

      expect(item.effectiveExpiry, daysFromNow(2));
    });

    test('期限未知的狀態是 unknownExpiry，不是 fresh 也不是 expired', () {
      final item = makeFood(daysToExpire: null);

      expect(item.effectiveExpiry, isNull);
      expect(item.statusAt(testNow), FoodItemStatus.unknownExpiry);
      expect(item.needsExpiryCompletion, isTrue);
    });

    test('區間期限以最早日判定狀態', () {
      final item = makeFood(
        expiry: ExpiryValue.range(daysFromNow(2), daysFromNow(6)),
      );

      expect(item.statusAt(testNow), FoodItemStatus.nearExpired);
    });

    test('2 天後到期是 nearExpired、10 天後是 fresh', () {
      expect(makeFood(daysToExpire: 2).statusAt(testNow),
          FoodItemStatus.nearExpired);
      expect(
          makeFood(daysToExpire: 10).statusAt(testNow), FoodItemStatus.fresh);
    });

    test('已過期', () {
      expect(
          makeFood(daysToExpire: -1).statusAt(testNow), FoodItemStatus.expired);
    });

    test('缺存放位置不算待補完', () {
      final item = makeFood(daysToExpire: 5, storageLocationId: null);

      expect(item.needsExpiryCompletion, isFalse);
    });
  });
}
