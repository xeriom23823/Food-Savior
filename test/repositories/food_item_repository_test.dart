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
    box = await env.openBox<FoodItem>('foodItem');
    repo = FoodItemRepository(foodItemBox: box);
  });
  tearDown(() => box.deleteFromDisk());

  group('updateAllFoodItemsStatus（依到期日推導狀態）', () {
    test('已過期 → expired；3 天內 → nearExpired；超過 3 天 → 不變', () async {
      await repo.saveFoodItems([
        makeFood(id: 'expired', daysToExpire: -1),
        makeFood(id: 'soon', daysToExpire: 2),
        makeFood(id: 'far', daysToExpire: 10),
      ]);

      await repo.updateAllFoodItemsStatus();

      expect(repo.getFoodItem('expired')!.status, FoodItemStatus.expired);
      expect(repo.getFoodItem('soon')!.status, FoodItemStatus.nearExpired);
      expect(repo.getFoodItem('far')!.status, FoodItemStatus.fresh);
    });

    test('邊界：現在 + 3 天前一分鐘 → nearExpired；後一分鐘 → fresh', () async {
      await repo.saveFoodItems([
        makeFood(id: 'inside', expirationDate: daysFromNow(3, minutes: -1)),
        makeFood(id: 'outside', expirationDate: daysFromNow(3, minutes: 5)),
      ]);

      await repo.updateAllFoodItemsStatus();

      expect(repo.getFoodItem('inside')!.status, FoodItemStatus.nearExpired);
      expect(repo.getFoodItem('outside')!.status, FoodItemStatus.fresh);
    });

    test('狀態更新保留 id 與其他欄位', () async {
      await repo.saveFoodItem(
          makeFood(id: 'x', name: '牛奶', quantity: 3, daysToExpire: 1));

      await repo.updateAllFoodItemsStatus();

      final x = repo.getFoodItem('x')!;
      expect(x.id, 'x');
      expect(x.name, '牛奶');
      expect(x.quantity, 3);
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

    test('filterByName 為子字串比對', () {
      expect(ids(repo.filterByName('蘋果')).toSet(), {'a', 'b'});
    });

    test('filterByType / filterByStatus', () {
      expect(ids(repo.filterByType(FoodItemType.meat)), ['c']);
      expect(
          ids(repo.filterByStatus(FoodItemStatus.fresh)).toSet(), {'b', 'c'});
    });

    test('deleteFoodItem 與 clearAll', () async {
      await repo.deleteFoodItem('a');
      expect(repo.getFoodItem('a'), isNull);
      await repo.clearAll();
      expect(repo.getAllFoodItems(), isEmpty);
    });
  });
}
