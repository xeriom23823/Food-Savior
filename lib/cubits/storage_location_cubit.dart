import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_savior/models/storage_location.dart';
import 'package:food_savior/repositories/food_item_repository.dart';
import 'package:food_savior/repositories/storage_location_repository.dart';
import 'package:uuid/uuid.dart';

class StorageLocationState extends Equatable {
  const StorageLocationState({this.locations = const []});

  final List<StorageLocation> locations;

  @override
  List<Object?> get props => [locations];
}

/// 存放位置的管理（storage-locations 規格）。
class StorageLocationCubit extends Cubit<StorageLocationState> {
  StorageLocationCubit({
    required this.storageLocationRepository,
    required this.foodItemRepository,
    Uuid? uuid,
  })  : _uuid = uuid ?? const Uuid(),
        super(const StorageLocationState()) {
    load();
  }

  final StorageLocationRepository storageLocationRepository;
  final FoodItemRepository foodItemRepository;
  final Uuid _uuid;

  void load() {
    emit(StorageLocationState(locations: storageLocationRepository.getAll()));
  }

  Future<void> add({required String name, required LocationKind kind}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final existing = storageLocationRepository.getAll();
    await storageLocationRepository.save(StorageLocation(
      id: _uuid.v4(),
      name: trimmed,
      kind: kind,
      sortOrder: existing.length,
    ));
    load();
  }

  Future<void> rename(StorageLocation location, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    await storageLocationRepository.save(location.copyWith(name: trimmed));
    load();
  }

  Future<void> changeKind(StorageLocation location, LocationKind kind) async {
    await storageLocationRepository.save(location.copyWith(kind: kind));
    load();
  }

  /// 刪除位置：該位置的食物歸為「未指定位置」，食物本身保留。
  Future<void> delete(StorageLocation location) async {
    await foodItemRepository.detachLocation(location.id);
    await storageLocationRepository.delete(location.id);
    load();
  }

  int itemCountOf(StorageLocation location) =>
      foodItemRepository.countByLocation(location.id);

  /// [newIndex] 是移除後的目標索引（`ReorderableListView.onReorderItem` 的語意）。
  Future<void> reorder(int oldIndex, int newIndex) async {
    final locations = List<StorageLocation>.of(state.locations);
    final moved = locations.removeAt(oldIndex);
    locations.insert(newIndex, moved);
    await storageLocationRepository.reorder(locations);
    load();
  }
}

/// 首次啟動的預設位置。名稱存成字串，之後改名或切換語系都不會變動
/// （storage-locations 規格）。
Future<void> seedDefaultStorageLocations({
  required StorageLocationRepository repository,
  required List<({String name, LocationKind kind})> defaults,
  Uuid uuid = const Uuid(),
}) async {
  for (var index = 0; index < defaults.length; index++) {
    final entry = defaults[index];
    await repository.save(StorageLocation(
      id: uuid.v4(),
      name: entry.name,
      kind: entry.kind,
      sortOrder: index,
    ));
  }
}
