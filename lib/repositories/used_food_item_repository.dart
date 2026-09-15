import 'package:food_savior/models/food_item.dart';
import 'package:hive_ce/hive.dart';

/// 唯一觸碰 `usedFoodItems` Box 的層（local-persistence 規格）。
class UsedFoodItemRepository {
  UsedFoodItemRepository({required this.usedFoodItemBox});

  final Box<UsedFoodItem> usedFoodItemBox;

  List<UsedFoodItem> getAllUsedFoodItems() => usedFoodItemBox.values.toList();

  UsedFoodItem? getUsedFoodItem(String id) => usedFoodItemBox.get(id);

  /// 寫入必須 await 完成後才回傳（local-persistence 規格）。
  Future<void> saveUsedFoodItem(UsedFoodItem item) =>
      usedFoodItemBox.put(item.id, item);

  Future<void> saveUsedFoodItems(List<UsedFoodItem> items) async {
    for (final item in items) {
      await saveUsedFoodItem(item);
    }
  }

  Future<void> deleteUsedFoodItem(String id) => usedFoodItemBox.delete(id);

  List<UsedFoodItem> filterByName(String name) {
    final normalized = normalizeFoodName(name);
    return usedFoodItemBox.values
        .where((item) => normalizeFoodName(item.name).contains(normalized))
        .toList();
  }

  List<UsedFoodItem> filterByType(FoodItemType type) =>
      usedFoodItemBox.values.where((item) => item.type == type).toList();

  List<UsedFoodItem> filterByStatus(FoodItemStatus status) =>
      usedFoodItemBox.values.where((item) => item.status == status).toList();

  List<UsedFoodItem> filterByDisposal(DisposalMethod method) =>
      usedFoodItemBox.values
          .where((item) => item.disposalMethod == method)
          .toList();

  List<UsedFoodItem> filterByDate(DateTime date) =>
      usedFoodItemBox.values.where((item) {
        return item.usedDate.year == date.year &&
            item.usedDate.month == date.month &&
            item.usedDate.day == date.day;
      }).toList();

  Future<void> clearAll() => usedFoodItemBox.clear();
}
