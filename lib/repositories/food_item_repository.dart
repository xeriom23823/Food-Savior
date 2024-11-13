import 'package:hive/hive.dart';
import 'package:food_savior/models/food_item.dart';

class FoodItemRepository {
  final Box<FoodItem> foodItemBox;

  FoodItemRepository({required this.foodItemBox});

  // 取得所有食物項目
  List<FoodItem> getAllFoodItems() {
    return foodItemBox
        .getAll(foodItemBox.keys)
        .where((item) => item != null)
        .cast<FoodItem>()
        .toList();
  }

  // 依照 ID 取得食物項目
  FoodItem? getFoodItem(String id) {
    return foodItemBox.get(id);
  }

  // 新增或更新食物項目
  Future<void> saveFoodItem(FoodItem item) async {
    foodItemBox.put(item.id, item);
  }

  // 刪除食物項目
  Future<void> deleteFoodItem(String id) async {
    foodItemBox.delete(id);
  }

  // 依照名稱篩選食物項目
  List<FoodItem> filterByName(String name) {
    return foodItemBox
        .getAll(foodItemBox.keys)
        .where((item) => item != null && item.name.contains(name))
        .cast<FoodItem>()
        .toList();
  }

  // 依類型篩選食物項目
  List<FoodItem> filterByType(FoodItemType type) {
    return foodItemBox
        .getAll(foodItemBox.keys)
        .where((item) => item != null && item.type == type)
        .cast<FoodItem>()
        .toList();
  }

// 依狀態篩選食物項目
  List<FoodItem> filterByStatus(FoodItemStatus status) {
    return foodItemBox
        .getAll(foodItemBox.keys)
        .where((item) => item != null && item.status == status)
        .cast<FoodItem>()
        .toList();
  }

  // 清空所有食物項目
  Future<void> clearAll() async {
    foodItemBox.clear();
  }
}
