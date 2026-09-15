import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/models/expiry.dart';
import 'package:food_savior/models/food_item.dart';

import '../helpers/hive_test_helper.dart';

void main() {
  group('copyWith 保留未指定的欄位', () {
    test('只改狀態時 id 與其他欄位不變', () {
      final original = makeFood(id: 'abc', name: '蘋果', amount: 3);

      final updated = original.copyWith(status: FoodItemStatus.expired);

      expect(updated.id, 'abc');
      expect(updated.name, '蘋果');
      expect(updated.amount, 3);
      expect(updated.status, FoodItemStatus.expired);
    });

    test('clear 旗標才會把欄位清成 null', () {
      final original = makeFood(storageLocationId: 'fridge', priceTotal: 100);

      expect(original.copyWith().storageLocationId, 'fridge');
      expect(original.copyWith(clearStorageLocation: true).storageLocationId,
          isNull);
      expect(original.copyWith(clearPrice: true).priceTotal, isNull);
    });
  });

  group('相等性', () {
    test('欄位全同則相等，hashCode 一致', () {
      final a = makeFood(id: 'x');
      final b = makeFood(id: 'x');

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect({a, b}, hasLength(1));
    });

    test('份量不同則不相等', () {
      expect(makeFood(id: 'x', amount: 1), isNot(makeFood(id: 'x', amount: 2)));
    });

    test('UsedFoodItem 與 FoodItem 即使 id 相同也不相等', () {
      final food = makeFood(id: 'same');
      final used = makeUsed(id: 'same');

      expect(food, isNot(used));
      expect(used, isNot(food));
    });
  });

  group('轉為使用紀錄', () {
    test('處理方式決定狀態，浪費類才算浪費', () {
      final food = makeFood(id: 'f', amount: 5);

      final eaten = food.toUsedFoodItem(
        id: 'u1',
        disposalMethod: DisposalMethod.eaten,
        usedDate: testNow,
        usedAmount: 5,
      );
      final given = food.toUsedFoodItem(
        id: 'u2',
        disposalMethod: DisposalMethod.givenAway,
        usedDate: testNow,
      );
      final discarded = food.toUsedFoodItem(
        id: 'u3',
        disposalMethod: DisposalMethod.discarded,
        usedDate: testNow,
      );

      expect(eaten.status, FoodItemStatus.consumed);
      expect(eaten.isWaste, isFalse);
      expect(given.status, FoodItemStatus.consumed);
      expect(given.isWaste, isFalse);
      expect(discarded.status, FoodItemStatus.wasted);
      expect(discarded.isWaste, isTrue);
    });

    test('保留原本的期限，點數才算得對', () {
      final food = makeFood(id: 'f', daysToExpire: 2);

      final used = food.toUsedFoodItem(
        id: 'u',
        disposalMethod: DisposalMethod.eaten,
        usedDate: testNow,
      );

      expect(used.effectiveExpiry, daysFromNow(2));
    });
  });

  group('金額攤提', () {
    test('依份量比例攤提並四捨五入', () {
      final food = makeFood(amount: 10, priceTotal: 100);

      expect(food.priceForPortion(3), 30);
      expect(food.priceForPortion(10), 100);
    });

    test('沒有金額時回傳 null', () {
      expect(makeFood(amount: 10).priceForPortion(3), isNull);
    });
  });

  group('JSON 往返', () {
    test('FoodItem 四種精度都能還原', () {
      for (final expiry in [
        ExpiryValue.exact(daysFromNow(3)),
        ExpiryValue.range(daysFromNow(3), daysFromNow(6)),
        ExpiryValue.month(2026, 10),
        const ExpiryValue.unknown(),
      ]) {
        final item = makeFood(id: 'json', expiry: expiry);

        final restored = FoodItem.fromJsonString(item.toJsonString());

        expect(restored, item);
      }
    });

    test('UsedFoodItem 保留處理方式、原因與點數', () {
      final item = makeUsed(
        id: 'u',
        disposalMethod: DisposalMethod.composted,
        wasteReason: WasteReason.forgotten,
        priceTotal: 45,
        affectFoodPoint: -1,
      );

      final restored = UsedFoodItem.fromJsonString(item.toJsonString());

      expect(restored, item);
      expect(restored.disposalMethod, DisposalMethod.composted);
      expect(restored.wasteReason, WasteReason.forgotten);
      expect(restored.affectFoodPoint, -1);
    });

    test('列舉以 name 序列化（不是 toString）', () {
      final json = makeFood(type: FoodItemType.meat).toJson();

      expect(json['type'], 'meat');
      expect(json['expiryPrecision'], 'exact');
    });
  });

  group('名稱正規化', () {
    test('全形、空白、大小寫都會被收斂', () {
      expect(normalizeFoodName('  Ｍｉｌｋ '), 'milk');
      expect(normalizeFoodName('雞蛋  '), '雞蛋');
    });
  });
}
