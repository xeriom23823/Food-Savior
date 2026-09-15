import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/cubits/food_points_cubit.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/models/food_points_summary.dart';
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

  FoodPointsCubit build() => FoodPointsCubit(
        usedFoodItemRepository: repo,
        now: () => testNow,
      );

  test('沒有紀錄時是 empty', () {
    expect(build().state, FoodPointsSummary.empty);
  });

  test('建立時就算好成績', () async {
    await repo.saveUsedFoodItems([
      makeUsed(id: 'a', affectFoodPoint: 3),
      makeUsed(id: 'b', affectFoodPoint: 2),
    ]);

    final cubit = build();

    expect(cubit.state.totalPoints, 5);
    expect(cubit.state.hasRecords, isTrue);
  });

  test('refresh 會重新讀取', () async {
    final cubit = build();
    expect(cubit.state.hasRecords, isFalse);

    await repo.saveUsedFoodItem(makeUsed(id: 'a', affectFoodPoint: 2));
    cubit.refresh();

    expect(cubit.state.totalPoints, 2);
  });
}
