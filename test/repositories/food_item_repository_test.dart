import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/repositories/food_item_repository.dart';
import 'package:hive_ce/hive.dart';

import '../helpers/hive_test_helper.dart';

void main() {
  final env = HiveTestEnv();
  late Box<FoodItem> box;
  late FoodItemRepository repo;

  setUpAll(env.setUpAll);
  tearDownAll(env.tearDownAll);
  setUp(() async {
    box = await env.openBox<FoodItem>('foodItems');
    repo = FoodItemRepository(foodItemBox: box);
  });
  tearDown(() => box.deleteFromDisk());

  group('updateAllFoodItemsStatus（依有效期限推導狀態）', () {
    test('已過期 → expired；3 天內 → nearExpired；超過 3 天 → fresh', () async {
      await repo.saveFoodItems([
        makeFood(id: 'expired', daysToExpire: -1),
        makeFood(id: 'soon', daysToExpire: 2),
        makeFood(id: 'far', daysToExpire: 10),
      ]);

      await repo.updateAllFoodItemsStatus(testNow);

      expect(repo.getFoodItem('expired')!.status, FoodItemStatus.expired);
      expect(repo.getFoodItem('soon')!.status, FoodItemStatus.nearExpired);
      expect(repo.getFoodItem('far')!.status, FoodItemStatus.fresh);
    });

    test('期限未知的項目狀態為 unknownExpiry', () async {
      await repo.saveFoodItem(makeFood(id: 'x', daysToExpire: null));

      await repo.updateAllFoodItemsStatus(testNow);

      expect(repo.getFoodItem('x')!.status, FoodItemStatus.unknownExpiry);
    });

    test('開封後效期會讓狀態提早變成 nearExpired', () async {
      await repo.saveFoodItem(makeFood(
        id: 'milk',
        daysToExpire: 10,
        openedDate: testNow,
        shelfLifeAfterOpenDays: 2,
      ));

      await repo.updateAllFoodItemsStatus(testNow);

      expect(repo.getFoodItem('milk')!.status, FoodItemStatus.nearExpired);
    });

    test('狀態更新保留 id 與其他欄位', () async {
      await repo.saveFoodItem(
          makeFood(id: 'x', name: '牛奶', amount: 3, daysToExpire: 1));

      await repo.updateAllFoodItemsStatus(testNow);

      final x = repo.getFoodItem('x')!;
      expect(x.id, 'x');
      expect(x.name, '牛奶');
      expect(x.amount, 3);
      expect(box.length, 1);
    });
  });

  group('查詢與篩選', () {
    setUp(() async {
      await repo.saveFoodItems([
        makeFood(
            id: 'a',
            name: '蘋果',
            type: FoodItemType.fruit,
            status: FoodItemStatus.expired),
        makeFood(id: 'b', name: '青蘋果', type: FoodItemType.fruit),
        makeFood(id: 'c', name: '牛肉', type: FoodItemType.meat),
      ]);
    });

    test('getExpired / getNonExpired 依狀態切分', () {
      expect(ids(repo.getExpiredFoodItems()), ['a']);
      expect(ids(repo.getNonExpiredFoodItems()).toSet(), {'b', 'c'});
    });

    test('getNonExpiredFoodItems 依有效期限排序，期限未知排最後', () async {
      await repo.clearAll();
      await repo.saveFoodItems([
        makeFood(id: 'later', daysToExpire: 9),
        makeFood(id: 'unknown', daysToExpire: null),
        makeFood(id: 'soon', daysToExpire: 1),
      ]);

      expect(ids(repo.getNonExpiredFoodItems()), ['soon', 'later', 'unknown']);
    });

    test('filterByName 為正規化後的子字串比對', () {
      expect(ids(repo.filterByName('蘋果')).toSet(), {'a', 'b'});
    });

    test('filterByType', () {
      expect(ids(repo.filterByType(FoodItemType.meat)), ['c']);
    });
  });

  group('位置', () {
    test('detachLocation 把食物歸為未指定位置，不刪食物', () async {
      await repo.saveFoodItems([
        makeFood(id: 'a', storageLocationId: 'fridge'),
        makeFood(id: 'b', storageLocationId: 'fridge'),
        makeFood(id: 'c', storageLocationId: 'pantry'),
      ]);

      final affected = await repo.detachLocation('fridge');

      expect(affected, 2);
      expect(box.length, 3);
      expect(repo.getFoodItem('a')!.storageLocationId, isNull);
      expect(repo.getFoodItem('c')!.storageLocationId, 'pantry');
    });

    test('countByLocation', () async {
      await repo.saveFoodItems([
        makeFood(id: 'a', storageLocationId: 'fridge'),
        makeFood(id: 'b', storageLocationId: 'fridge'),
      ]);

      expect(repo.countByLocation('fridge'), 2);
      expect(repo.countByLocation('pantry'), 0);
    });
  });

  group('寫入與持久化', () {
    test('儲存後可讀回，刪除後消失', () async {
      await repo.saveFoodItem(makeFood(id: 'x'));
      expect(repo.getFoodItem('x'), isNotNull);

      await repo.deleteFoodItem('x');
      expect(repo.getFoodItem('x'), isNull);
    });

    test('clearAll 清空', () async {
      await repo.saveFoodItems([makeFood(id: 'a'), makeFood(id: 'b')]);

      await repo.clearAll();

      expect(repo.getAllFoodItems(), isEmpty);
    });
  });
}
