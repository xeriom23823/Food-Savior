import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/repositories/used_food_item_repository.dart';
import 'package:hive_ce/hive.dart';

import '../helpers/hive_test_helper.dart';

void main() {
  final env = HiveTestEnv();
  late Box<UsedFoodItem> box;
  late UsedFoodItemRepository repo;

  setUpAll(env.setUpAll);
  tearDownAll(env.tearDownAll);
  setUp(() async {
    box = await env.openBox<UsedFoodItem>('usedFoodItem');
    repo = UsedFoodItemRepository(usedFoodItemBox: box);
  });
  tearDown(() => box.deleteFromDisk());

  test('filterByDate 以日曆日比對，忽略時間', () async {
    final day = DateTime(2026, 3, 10);
    await repo.saveUsedFoodItems([
      makeUsed(id: 'morning', usedDate: DateTime(2026, 3, 10, 7)),
      makeUsed(id: 'night', usedDate: DateTime(2026, 3, 10, 23, 59)),
      makeUsed(id: 'nextDay', usedDate: DateTime(2026, 3, 11)),
    ]);

    expect(ids(repo.filterByDate(day)).toSet(), {'morning', 'night'});
  });

  test('filterByStatus / filterByType / filterByName', () async {
    await repo.saveUsedFoodItems([
      makeUsed(id: 'c', name: '牛奶', type: FoodItemType.eggAndMilk),
      makeUsed(
          id: 'w',
          name: '牛肉',
          type: FoodItemType.meat,
          status: FoodItemStatus.wasted),
    ]);

    expect(ids(repo.filterByStatus(FoodItemStatus.wasted)), ['w']);
    expect(ids(repo.filterByType(FoodItemType.eggAndMilk)), ['c']);
    expect(ids(repo.filterByName('牛')).toSet(), {'c', 'w'});
  });

  test('save 覆寫同 id；delete 與 clearAll', () async {
    await repo.saveUsedFoodItem(makeUsed(id: 'a', quantity: 1));
    await repo.saveUsedFoodItem(makeUsed(id: 'a', quantity: 2));
    expect(box.length, 1);
    expect(repo.getUsedFoodItem('a')!.quantity, 2);

    await repo.deleteUsedFoodItem('a');
    expect(repo.getUsedFoodItem('a'), isNull);

    await repo.saveUsedFoodItem(makeUsed(id: 'b'));
    await repo.clearAll();
    expect(repo.getAllUsedFoodItems(), isEmpty);
  });
}
