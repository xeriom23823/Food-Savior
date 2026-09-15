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
    box = await env.openBox<UsedFoodItem>('usedFoodItems');
    repo = UsedFoodItemRepository(usedFoodItemBox: box);
  });
  tearDown(() => box.deleteFromDisk());

  test('依日期篩選只回傳同一天的紀錄', () async {
    await repo.saveUsedFoodItems([
      makeUsed(id: 'today', usedDate: testNow),
      makeUsed(id: 'yesterday', usedDate: daysFromNow(-1)),
    ]);

    expect(ids(repo.filterByDate(testNow)), ['today']);
    expect(ids(repo.filterByDate(daysFromNow(-1))), ['yesterday']);
  });

  test('依處理方式篩選', () async {
    await repo.saveUsedFoodItems([
      makeUsed(id: 'eaten', disposalMethod: DisposalMethod.eaten),
      makeUsed(id: 'composted', disposalMethod: DisposalMethod.composted),
    ]);

    expect(ids(repo.filterByDisposal(DisposalMethod.composted)), ['composted']);
  });

  test('送人不算浪費', () async {
    await repo.saveUsedFoodItem(
      makeUsed(id: 'given', disposalMethod: DisposalMethod.givenAway),
    );

    expect(repo.getUsedFoodItem('given')!.isWaste, isFalse);
    expect(repo.filterByStatus(FoodItemStatus.wasted), isEmpty);
  });

  test('寫入、刪除、清空', () async {
    await repo.saveUsedFoodItem(makeUsed(id: 'x'));
    expect(repo.getUsedFoodItem('x'), isNotNull);

    await repo.deleteUsedFoodItem('x');
    expect(repo.getUsedFoodItem('x'), isNull);

    await repo.saveUsedFoodItems([makeUsed(id: 'a'), makeUsed(id: 'b')]);
    await repo.clearAll();
    expect(repo.getAllUsedFoodItems(), isEmpty);
  });
}
