import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/models/food_item_group.dart';
import 'package:hive_ce/hive.dart';

/// 唯一觸碰 `foodItems` Box 的層（local-persistence 規格）。
class FoodItemRepository {
  FoodItemRepository({required this.foodItemBox});

  final Box<FoodItem> foodItemBox;

  List<FoodItem> getAllFoodItems() => foodItemBox.values.toList();

  FoodItem? getFoodItem(String id) => foodItemBox.get(id);

  /// 寫入必須 await 完成後才回傳（local-persistence 規格）。
  Future<void> saveFoodItem(FoodItem item) => foodItemBox.put(item.id, item);

  Future<void> saveFoodItems(List<FoodItem> items) async {
    for (final item in items) {
      await saveFoodItem(item);
    }
  }

  Future<void> deleteFoodItem(String id) => foodItemBox.delete(id);

  List<FoodItem> filterByName(String name) {
    final normalized = normalizeFoodName(name);
    return foodItemBox.values
        .where((item) => normalizeFoodName(item.name).contains(normalized))
        .toList();
  }

  List<FoodItem> filterByType(FoodItemType type) =>
      foodItemBox.values.where((item) => item.type == type).toList();

  List<FoodItem> filterByStatus(FoodItemStatus status) =>
      foodItemBox.values.where((item) => item.status == status).toList();

  List<FoodItem> filterByLocation(String? locationId) => foodItemBox.values
      .where((item) => item.storageLocationId == locationId)
      .toList();

  /// 依有效期限重新推導所有項目的狀態並寫回（food-inventory 規格）。
  Future<void> updateAllFoodItemsStatus(DateTime now) async {
    for (final item in getAllFoodItems()) {
      final derived = item.statusAt(now);
      if (derived != item.status) {
        await saveFoodItem(item.copyWith(status: derived));
      }
    }
  }

  List<FoodItem> getExpiredFoodItems() =>
      filterByStatus(FoodItemStatus.expired);

  List<FoodItem> getNonExpiredFoodItems() => FoodItemGroup.sortByExpiry(
        getAllFoodItems()
            .where((item) => item.status != FoodItemStatus.expired)
            .toList(),
      );

  /// 位置被刪除時，該位置的食物歸為「未指定位置」，不刪食物
  /// （storage-locations 規格）。
  Future<int> detachLocation(String locationId) async {
    final affected = filterByLocation(locationId);
    for (final item in affected) {
      await saveFoodItem(item.copyWith(clearStorageLocation: true));
    }
    return affected.length;
  }

  int countByLocation(String locationId) => filterByLocation(locationId).length;

  Future<void> clearAll() => foodItemBox.clear();
}
