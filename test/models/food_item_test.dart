import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/models/food_item.dart';

import '../helpers/hive_test_helper.dart';

void main() {
  final storage = DateTime(2026, 9, 1);
  final expiration = DateTime(2026, 9, 10);

  FoodItem base({int quantity = 2}) => makeFood(
        id: 'id-1',
        name: '牛奶',
        type: FoodItemType.eggAndMilk,
        quantity: quantity,
        unit: Unit.milliliter,
        description: '全脂',
        storageDate: storage,
        expirationDate: expiration,
      );

  group('相等性（值相等，hashCode 與 == 一致）', () {
    test('所有欄位相同 → 相等且 hashCode 相同', () {
      expect(base(), equals(base()));
      expect(base().hashCode, base().hashCode);
    });

    test('數量不同 → 不相等', () {
      expect(base(quantity: 2), isNot(equals(base(quantity: 3))));
    });

    test('Set 以值去重', () {
      expect({base(), base()}.length, 1);
    });

    test('UsedFoodItem 與同 id 的 FoodItem 不相等', () {
      final used = base().toUsedFoodItem(
        id: 'id-1',
        usedStatus: FoodItemStatus.consumed,
        usedDate: DateTime(2026, 9, 5),
        usedQuantity: 1,
      );
      expect(used, isNot(equals(base())));
      expect(base(), isNot(equals(used)));
    });
  });

  group('copyWith', () {
    test('未提供 id 時保留原 id', () {
      final copy = base().copyWith(status: FoodItemStatus.expired);
      expect(copy.id, 'id-1');
      expect(copy.status, FoodItemStatus.expired);
      expect(copy.name, '牛奶');
    });

    test('UsedFoodItem.copyWith 保留 usedDate 與點數', () {
      final used =
          makeUsed(id: 'u', affectFoodPoint: 1, usedDate: DateTime(2026, 9, 5));
      final copy = used.copyWith(quantity: 5);
      expect(copy.id, 'u');
      expect(copy.quantity, 5);
      expect(copy.affectFoodPoint, 1);
      expect(copy.usedDate, DateTime(2026, 9, 5));
    });
  });

  group('toUsedFoodItem（food-points）', () {
    test('consumed → affectFoodPoint +1', () {
      final used = base().toUsedFoodItem(
        id: 'u1',
        usedStatus: FoodItemStatus.consumed,
        usedDate: DateTime(2026, 9, 5),
        usedQuantity: 1,
      );
      expect(used.affectFoodPoint, 1);
      expect(used.quantity, 1);
      expect(used.name, '牛奶');
    });

    test('wasted → affectFoodPoint -1', () {
      final used = base().toUsedFoodItem(
        id: 'u2',
        usedStatus: FoodItemStatus.wasted,
        usedDate: DateTime(2026, 9, 5),
        usedQuantity: 2,
      );
      expect(used.affectFoodPoint, -1);
    });
  });

  group('JSON 往返（cloud-backup-restore）', () {
    test('FoodItem toJson / fromJson', () {
      final restored = FoodItem.fromJson(base().toJson());
      expect(restored, equals(base()));
    });

    test('toJson 的列舉欄位是列舉名稱字串（不可被 localizedName 擴充遮蔽）', () {
      final json = base().toJson();
      expect(json['type'], 'eggAndMilk');
      expect(json['status'], 'fresh');
      expect(json['unit'], 'milliliter');
    });

    test('FoodItem toJsonString / fromJsonString（備份格式）', () {
      final restored = FoodItem.fromJsonString(base().toJsonString());
      expect(restored, equals(base()));
    });

    test('UsedFoodItem 往返保留 usedDate 與點數', () {
      final used = makeUsed(
          id: 'u', usedDate: DateTime(2026, 9, 5, 12), affectFoodPoint: 0);
      expect(UsedFoodItem.fromJson(used.toJson()), equals(used));
      expect(UsedFoodItem.fromJsonString(used.toJsonString()), equals(used));
    });

    test('備份缺少 affectFoodPoint → 0', () {
      final json = makeUsed(id: 'u').toJson()..remove('affectFoodPoint');
      expect(UsedFoodItem.fromJson(json).affectFoodPoint, 0);
    });
  });

  test('quantityWithUnit 組合數量與單位名稱需要 BuildContext，改由 widget test 覆蓋', () {
    // 佔位：確保 Unit 列舉順序未被重排（Hive 相容性）。
    expect(Unit.values, [Unit.gram, Unit.milliliter, Unit.piece]);
    expect(FoodItemStatus.values.length, 5);
    expect(FoodItemType.values.length, 11);
  });
}
