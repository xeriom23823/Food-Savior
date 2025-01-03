import 'package:food_savior/models/food_item.dart';
import 'package:hive_ce/hive.dart';

class FoodItemRepository {
  final Box<FoodItem> foodItemBox;

  FoodItemRepository({required this.foodItemBox});

  // 取得所有食物項目
  List<FoodItem> getAllFoodItems() {
    return foodItemBox.values.toList();
  }

  // 依照 ID 取得食物項目
  FoodItem? getFoodItem(String id) {
    return foodItemBox.get(id);
  }

  // 新增或更新食物項目
  Future<void> saveFoodItem(FoodItem item) async {
    foodItemBox.put(item.id, item);
  }

  Future<void> saveFoodItems(List<FoodItem> items) async {
    for (var item in items) {
      await saveFoodItem(item);
    }
  }

  // 刪除食物項目
  Future<void> deleteFoodItem(String id) async {
    foodItemBox.delete(id);
  }

  // 依照名稱篩選食物項目
  List<FoodItem> filterByName(String name) {
    return foodItemBox.values
        .where((item) => item.name.contains(name))
        .cast<FoodItem>()
        .toList();
  }

  // 依類型篩選食物項目
  List<FoodItem> filterByType(FoodItemType type) {
    return foodItemBox.values.where((item) => item.type == type).toList();
  }

  // 依狀態篩選食物項目
  List<FoodItem> filterByStatus(FoodItemStatus status) {
    return foodItemBox.values.where((item) => item.status == status).toList();
  }

  // 更新 foodItemBox 中所有食物的狀態
  Future<void> updateAllFoodItemsStatus() async {
    final items = getAllFoodItems();

    // 更新食物狀態
    final updatedItems = items.map((foodItem) {
      // 檢查是否已過期
      if (foodItem.expirationDate.isBefore(DateTime.now())) {
        return foodItem.copyWith(
          id: foodItem.id,
          status: FoodItemStatus.expired,
        );
      }
      // 檢查是否即將過期（3天內）
      if (foodItem.expirationDate.isBefore(
        DateTime.now().add(const Duration(days: 3)),
      )) {
        return foodItem.copyWith(
          id: foodItem.id,
          status: FoodItemStatus.nearExpired,
        );
      }
      return foodItem;
    }).toList();

    // 更新狀態
    for (var item in updatedItems) {
      foodItemBox.put(item.id, item);
    }
  }

  // 取得過期食物項目
  List<FoodItem> getExpiredFoodItems() {
    return getAllFoodItems()
        .where((item) => item.status == FoodItemStatus.expired)
        .toList();
  }

  // 取得未過期食物項目
  List<FoodItem> getNonExpiredFoodItems() {
    return getAllFoodItems()
        .where((item) => item.status != FoodItemStatus.expired)
        .toList();
  }

  // 清空所有食物項目
  Future<void> clearAll() async {
    foodItemBox.clear();
  }
}
