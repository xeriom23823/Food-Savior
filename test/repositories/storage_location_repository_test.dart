import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/models/storage_location.dart';
import 'package:food_savior/repositories/storage_location_repository.dart';
import 'package:hive_ce/hive.dart';

import '../helpers/hive_test_helper.dart';

void main() {
  final env = HiveTestEnv();
  late Box<StorageLocation> box;
  late StorageLocationRepository repo;

  setUpAll(env.setUpAll);
  tearDownAll(env.tearDownAll);
  setUp(() async {
    box = await env.openBox<StorageLocation>('storageLocations');
    repo = StorageLocationRepository(storageLocationBox: box);
  });
  tearDown(() => box.deleteFromDisk());

  test('依 sortOrder 排序', () async {
    await repo.saveAll([
      makeLocation(id: 'c', name: '儲藏櫃', sortOrder: 2),
      makeLocation(id: 'a', name: '冷藏', sortOrder: 0),
      makeLocation(id: 'b', name: '冷凍', sortOrder: 1),
    ]);

    expect(
        repo.getAll().map((location) => location.id).toList(), ['a', 'b', 'c']);
  });

  test('reorder 依傳入順序重寫 sortOrder', () async {
    await repo.saveAll([
      makeLocation(id: 'a', sortOrder: 0),
      makeLocation(id: 'b', sortOrder: 1),
    ]);

    await repo.reorder([repo.getById('b')!, repo.getById('a')!]);

    expect(repo.getAll().map((location) => location.id).toList(), ['b', 'a']);
  });

  test('重啟後保留（同一個 Box 重新讀）', () async {
    await repo.save(makeLocation(id: 'a', name: '蔬果室'));

    expect(repo.getById('a')!.name, '蔬果室');
  });

  test('刪除位置', () async {
    await repo.save(makeLocation(id: 'a'));

    await repo.delete('a');

    expect(repo.getById('a'), isNull);
  });
}
