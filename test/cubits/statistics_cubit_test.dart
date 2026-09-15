import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/cubits/statistics_cubit.dart';
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

  test('沒有紀錄時 hasRecords 為 false', () {
    final cubit = StatisticsCubit(usedFoodItemRepository: repo);

    expect(cubit.state.hasRecords, isFalse);
  });

  test('彙總筆數、排行、原因與金額', () async {
    await repo.saveUsedFoodItems([
      makeUsed(
        id: 'a',
        name: '青椒',
        type: FoodItemType.vegetable,
        disposalMethod: DisposalMethod.discarded,
        wasteReason: WasteReason.forgotten,
        priceTotal: 20,
      ),
      makeUsed(
        id: 'b',
        name: '青椒',
        type: FoodItemType.vegetable,
        disposalMethod: DisposalMethod.discarded,
        priceTotal: 20,
      ),
      makeUsed(
        id: 'c',
        name: '蘋果',
        type: FoodItemType.fruit,
        disposalMethod: DisposalMethod.eaten,
        priceTotal: 50,
      ),
    ]);

    final cubit = StatisticsCubit(usedFoodItemRepository: repo);

    expect(cubit.state.hasRecords, isTrue);
    expect(cubit.state.wastedByType[FoodItemType.vegetable], 2);
    expect(cubit.state.consumedByType[FoodItemType.fruit], 1);
    expect(cubit.state.topWasted.first.name, '青椒');
    expect(cubit.state.wasteReasons[WasteReason.forgotten], 1);
    expect(cubit.state.wasteReasons[null], 1);
    expect(cubit.state.money.lost, 40);
    expect(cubit.state.money.saved, 50);
    expect(cubit.state.wasteRate.single.rate, closeTo(2 / 3, 0.0001));
  });

  test('refresh 會重新讀取', () async {
    final cubit = StatisticsCubit(usedFoodItemRepository: repo);
    expect(cubit.state.hasRecords, isFalse);

    await repo.saveUsedFoodItem(makeUsed(id: 'a'));
    cubit.refresh();

    expect(cubit.state.hasRecords, isTrue);
  });
}
