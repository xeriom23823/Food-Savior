import 'package:food_savior/models/food_item.dart';
import 'package:hive_ce/hive.dart';

class UsedFoodItemRepository {
  final Box<UsedFoodItem> usedFoodItemBox;

  UsedFoodItemRepository({required this.usedFoodItemBox});

  // 取得所有已使用的食物項目
  List<UsedFoodItem> getAllUsedFoodItems() {
    return usedFoodItemBox.values.toList();
  }

  // 依照 ID 取得已使用的食物項目
  UsedFoodItem? getUsedFoodItem(String id) {
    return usedFoodItemBox.get(id);
  }

  // 新增或更新已使用的食物項目
  Future<void> saveUsedFoodItem(UsedFoodItem item) async {
    usedFoodItemBox.put(item.id, item);
  }

  Future<void> saveUsedFoodItems(List<UsedFoodItem> items) async {
    for (var item in items) {
      await saveUsedFoodItem(item);
    }
  }

  // 刪除已使用的食物項目
  Future<void> deleteUsedFoodItem(String id) async {
    usedFoodItemBox.delete(id);
  }

  // 依名稱篩選已使用的食物項目
  List<UsedFoodItem> filterByName(String name) {
    return usedFoodItemBox.values.where((item) {
      return item.name.contains(name);
    }).toList();
  }

  // 依類型篩選已使用的食物項目
  List<UsedFoodItem> filterByType(FoodItemType type) {
    return usedFoodItemBox.values.where((item) {
      return item.type == type;
    }).toList();
  }

  // 依狀態篩選已使用的食物項目
  List<UsedFoodItem> filterByStatus(FoodItemStatus status) {
    return usedFoodItemBox.values.where((item) {
      return item.status == status;
    }).toList();
  }

  // 依日期篩選已使用的食物項目
  List<UsedFoodItem> filterByDate(DateTime date) {
    return usedFoodItemBox.values.where((item) {
      return item.usedDate.year == date.year &&
          item.usedDate.month == date.month &&
          item.usedDate.day == date.day;
    }).toList();
  }

  // 清空所有已使用的食物項目
  Future<void> clearAll() async {
    usedFoodItemBox.clear();
  }
}
