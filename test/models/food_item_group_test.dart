import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/models/food_item_group.dart';
import 'package:food_savior/models/food_list_grouping.dart';

import '../helpers/hive_test_helper.dart';

void main() {
  group('同名批次合併（只在呈現層）', () {
    test('名稱、位置、單位皆同才合併，份量相加', () {
      final groups = FoodItemGroup.groupAll([
        makeFood(
            id: 'a',
            name: '雞蛋',
            amount: 10,
            storageLocationId: 'fridge',
            daysToExpire: 3),
        makeFood(
            id: 'b',
            name: '雞蛋',
            amount: 8,
            storageLocationId: 'fridge',
            daysToExpire: 10),
      ]);

      expect(groups, hasLength(1));
      expect(groups.single.items, hasLength(2));
      expect(groups.single.totalAmount, 18);
      expect(groups.single.statusAt(testNow), FoodItemStatus.nearExpired);
    });

    test('位置不同就不合併', () {
      final groups = FoodItemGroup.groupAll([
        makeFood(id: 'a', name: '雞蛋', storageLocationId: 'fridge'),
        makeFood(id: 'b', name: '雞蛋', storageLocationId: 'freezer'),
      ]);

      expect(groups, hasLength(2));
    });

    test('名稱正規化：全形與空白不影響合併', () {
      final groups = FoodItemGroup.groupAll([
        makeFood(id: 'a', name: '雞蛋 '),
        makeFood(id: 'b', name: '雞蛋'),
      ]);

      expect(groups, hasLength(1));
    });

    test('組內依有效期限由近到遠，期限未知排最後', () {
      final group = FoodItemGroup.groupAll([
        makeFood(id: 'later', name: '蛋', daysToExpire: 9),
        makeFood(id: 'unknown', name: '蛋', daysToExpire: null),
        makeFood(id: 'soon', name: '蛋', daysToExpire: 1),
      ]).single;

      expect(ids(group.items), ['soon', 'later', 'unknown']);
      expect(group.hasPendingExpiry, isTrue);
    });

    test('全部以剩餘比例記錄時份量總和為 null', () {
      final group = FoodItemGroup.groupAll([
        makeFood(
            id: 'a',
            name: '醬油',
            amount: null,
            unit: null,
            remainingFraction: RemainingFraction.half),
      ]).single;

      expect(group.totalAmount, isNull);
    });
  });

  group('分群', () {
    List<FoodItem> sample() => [
          makeFood(id: 'expired', name: 'a', daysToExpire: -1),
          makeFood(id: 'today', name: 'b', daysToExpire: 0),
          makeFood(id: 'soon', name: 'c', daysToExpire: 2),
          makeFood(id: 'week', name: 'd', daysToExpire: 6),
          makeFood(id: 'plenty', name: 'e', daysToExpire: 30),
          makeFood(id: 'unknown', name: 'f', daysToExpire: null),
        ];

    test('依急迫度分群，順序固定且空群不出現', () {
      final sections = buildSections(
        items: sample(),
        grouping: FoodListGrouping.urgency,
        now: testNow,
      );

      expect(
        sections.map((section) => section.urgency).toList(),
        [
          UrgencyBucket.expired,
          UrgencyBucket.today,
          UrgencyBucket.withinThreeDays,
          UrgencyBucket.withinWeek,
          UrgencyBucket.plenty,
          UrgencyBucket.unknownExpiry,
        ],
      );
    });

    test('沒有已過期的項目時不出現已過期分群', () {
      final sections = buildSections(
        items: [makeFood(id: 'a', daysToExpire: 30)],
        grouping: FoodListGrouping.urgency,
        now: testNow,
      );

      expect(
        sections.any((section) => section.urgency == UrgencyBucket.expired),
        isFalse,
      );
    });

    test('依位置分群時沒有位置的歸在最後', () {
      final sections = buildSections(
        items: [
          makeFood(id: 'a', name: 'a', storageLocationId: 'fridge'),
          makeFood(id: 'b', name: 'b'),
        ],
        grouping: FoodListGrouping.location,
        now: testNow,
        locationOrder: const ['fridge'],
      );

      expect(sections.map((section) => section.locationId).toList(),
          ['fridge', null]);
    });

    test('依類型分群', () {
      final sections = buildSections(
        items: [
          makeFood(id: 'a', name: 'a', type: FoodItemType.meat),
          makeFood(id: 'b', name: 'b', type: FoodItemType.fruit),
        ],
        grouping: FoodListGrouping.type,
        now: testNow,
      );

      expect(sections.map((section) => section.type).toList(),
          [FoodItemType.fruit, FoodItemType.meat]);
    });
  });
}
