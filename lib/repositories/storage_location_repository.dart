import 'package:food_savior/models/storage_location.dart';
import 'package:hive_ce/hive.dart';

/// 唯一觸碰 `storageLocations` Box 的層（local-persistence 規格）。
class StorageLocationRepository {
  StorageLocationRepository({required this.storageLocationBox});

  final Box<StorageLocation> storageLocationBox;

  /// 依 sortOrder 排序；同序則依名稱，避免順序在畫面間跳動。
  List<StorageLocation> getAll() {
    final locations = storageLocationBox.values.toList()
      ..sort((a, b) {
        final bySortOrder = a.sortOrder.compareTo(b.sortOrder);
        return bySortOrder != 0 ? bySortOrder : a.name.compareTo(b.name);
      });
    return locations;
  }

  StorageLocation? getById(String? id) =>
      id == null ? null : storageLocationBox.get(id);

  Future<void> save(StorageLocation location) =>
      storageLocationBox.put(location.id, location);

  Future<void> saveAll(List<StorageLocation> locations) async {
    for (final location in locations) {
      await save(location);
    }
  }

  Future<void> delete(String id) => storageLocationBox.delete(id);

  Future<void> clearAll() => storageLocationBox.clear();

  /// 重新排序：把整串位置依傳入順序重寫 sortOrder。
  Future<void> reorder(List<StorageLocation> ordered) async {
    for (var index = 0; index < ordered.length; index++) {
      await save(ordered[index].copyWith(sortOrder: index));
    }
  }
}
