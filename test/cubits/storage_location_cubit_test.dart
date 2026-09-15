import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/cubits/storage_location_cubit.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/models/storage_location.dart';
import 'package:food_savior/repositories/food_item_repository.dart';
import 'package:food_savior/repositories/storage_location_repository.dart';
import 'package:hive_ce/hive.dart';

import '../helpers/hive_test_helper.dart';

void main() {
  final env = HiveTestEnv();
  late Box<StorageLocation> locationBox;
  late Box<FoodItem> foodBox;
  late StorageLocationRepository locationRepo;
  late FoodItemRepository foodRepo;

  setUpAll(env.setUpAll);
  tearDownAll(env.tearDownAll);
  setUp(() async {
    locationBox = await env.openBox<StorageLocation>('storageLocations');
    foodBox = await env.openBox<FoodItem>('foodItems');
    locationRepo = StorageLocationRepository(storageLocationBox: locationBox);
    foodRepo = FoodItemRepository(foodItemBox: foodBox);
  });
  tearDown(() async {
    await locationBox.deleteFromDisk();
    await foodBox.deleteFromDisk();
  });

  StorageLocationCubit build() => StorageLocationCubit(
        storageLocationRepository: locationRepo,
        foodItemRepository: foodRepo,
      );

  test('新增位置並依建立順序排序', () async {
    final cubit = build();

    await cubit.add(name: '蔬果室', kind: LocationKind.refrigerated);
    await cubit.add(name: '儲藏櫃', kind: LocationKind.ambient);

    expect(cubit.state.locations.map((l) => l.name).toList(), ['蔬果室', '儲藏櫃']);
  });

  test('空白名稱不建立位置', () async {
    final cubit = build();

    await cubit.add(name: '   ', kind: LocationKind.other);

    expect(cubit.state.locations, isEmpty);
  });

  test('改名與改變存放方式', () async {
    final cubit = build();
    await cubit.add(name: '冷藏', kind: LocationKind.refrigerated);

    final location = cubit.state.locations.single;
    await cubit.rename(location, '大冰箱');
    await cubit.changeKind(cubit.state.locations.single, LocationKind.frozen);

    expect(cubit.state.locations.single.name, '大冰箱');
    expect(cubit.state.locations.single.kind, LocationKind.frozen);
  });

  test('刪除位置時食物歸為未指定，不刪食物', () async {
    final cubit = build();
    await cubit.add(name: '冷藏', kind: LocationKind.refrigerated);
    final location = cubit.state.locations.single;
    await foodRepo.saveFoodItems([
      makeFood(id: 'a', storageLocationId: location.id),
      makeFood(id: 'b', storageLocationId: location.id),
    ]);

    expect(cubit.itemCountOf(location), 2);
    await cubit.delete(location);

    expect(cubit.state.locations, isEmpty);
    expect(foodRepo.getAllFoodItems(), hasLength(2));
    expect(foodRepo.getFoodItem('a')!.storageLocationId, isNull);
  });

  test('拖曳排序後順序持久化', () async {
    final cubit = build();
    await cubit.add(name: 'A', kind: LocationKind.refrigerated);
    await cubit.add(name: 'B', kind: LocationKind.frozen);

    await cubit.reorder(1, 0);

    expect(cubit.state.locations.map((l) => l.name).toList(), ['B', 'A']);
    expect(locationRepo.getAll().map((l) => l.name).toList(), ['B', 'A']);
  });

  test('種下預設位置三筆', () async {
    await seedDefaultStorageLocations(
      repository: locationRepo,
      defaults: const [
        (name: '冷藏', kind: LocationKind.refrigerated),
        (name: '冷凍', kind: LocationKind.frozen),
        (name: '常溫', kind: LocationKind.ambient),
      ],
    );

    expect(
        locationRepo.getAll().map((l) => l.name).toList(), ['冷藏', '冷凍', '常溫']);
  });
}
