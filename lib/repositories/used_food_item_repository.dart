import 'package:hive/hive.dart';
import 'package:food_savior/models/food_item.dart';

class UsedFoodItemRepository {
  final Box<UsedFoodItem> usedFoodItemBox;

  UsedFoodItemRepository({required this.usedFoodItemBox});

  // 取得所有已使用的食物項目
  List<UsedFoodItem> getAllUsedFoodItems() {
    return usedFoodItemBox
        .getAll(usedFoodItemBox.keys)
        .where((item) => item != null)
        .cast<UsedFoodItem>()
        .toList();
  }

  // 依照 ID 取得已使用的食物項目
  UsedFoodItem? getUsedFoodItem(String id) {
    return usedFoodItemBox.get(id);
  }

  // 新增或更新已使用的食物項目
  Future<void> saveUsedFoodItem(UsedFoodItem item) async {
    usedFoodItemBox.put(item.id, item);
  }

  // 刪除已使用的食物項目
  Future<void> deleteUsedFoodItem(String id) async {
    usedFoodItemBox.delete(id);
  }

  // 依照名稱篩選已使用的食物項目
  List<UsedFoodItem> filterByName(String name) {
    return usedFoodItemBox
        .getAll(usedFoodItemBox.keys)
        .where((item) {
          return item != null && item.name.contains(name);
        })
        .cast<UsedFoodItem>()
        .toList();
  }

  // 依類型篩選已使用的食物項目
  List<UsedFoodItem> filterByType(FoodItemType type) {
    return usedFoodItemBox
        .getAll(usedFoodItemBox.keys)
        .where((item) {
          return item != null && item.type == type;
        })
        .cast<UsedFoodItem>()
        .toList();
  }

  // 依狀態篩選已使用的食物項目
  List<UsedFoodItem> filterByStatus(FoodItemStatus status) {
    return usedFoodItemBox
        .getAll(usedFoodItemBox.keys)
        .where((item) {
          return item != null && item.status == status;
        })
        .cast<UsedFoodItem>()
        .toList();
  }

  // 清空所有已使用的食物項目
  Future<void> clearAll() async {
    usedFoodItemBox.clear();
  }
}
