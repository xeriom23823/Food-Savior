import 'package:food_savior/models/food_item.dart';

/// 同名批次在呈現層合併的結果（design D18）。
///
/// 資料層仍是多筆獨立 [FoodItem]；這個型別只描述「畫面上怎麼收合」，
/// 以及食用／丟棄時要依 FEFO 從哪一批開始扣。
class FoodItemGroup {
  FoodItemGroup({required this.items})
      : assert(items.isNotEmpty, 'group must not be empty');

  /// 依有效期限由近到遠排序（null 排最後）。
  final List<FoodItem> items;

  FoodItem get first => items.first;

  String get name => first.name;
  FoodItemType get type => first.type;
  Unit? get unit => first.unit;
  String? get storageLocationId => first.storageLocationId;

  bool get isSingle => items.length == 1;

  /// 組內最早的有效期限，決定卡片顯示的狀態。
  DateTime? get earliestExpiry {
    for (final item in items) {
      final expiry = item.effectiveExpiry;
      if (expiry != null) return expiry;
    }
    return null;
  }

  FoodItemStatus statusAt(DateTime now) {
    // items 已依期限排序，第一個有期限的就是最急迫的。
    for (final item in items) {
      if (item.effectiveExpiry != null) return item.statusAt(now);
    }
    return FoodItemStatus.unknownExpiry;
  }

  /// 份量總和。全組都以比例記錄時回傳 null（比例無法相加）。
  double? get totalAmount {
    double sum = 0;
    var hasAny = false;
    for (final item in items) {
      final amount = item.amount;
      if (amount != null) {
        sum += amount;
        hasAny = true;
      }
    }
    return hasAny ? sum : null;
  }

  bool get hasPendingExpiry => items.any((item) => item.needsExpiryCompletion);

  /// 依 (正規化名稱, 位置, 單位) 分組；組內依有效期限由近到遠排序。
  static List<FoodItemGroup> groupAll(List<FoodItem> items) {
    final buckets = <String, List<FoodItem>>{};
    for (final item in items) {
      final key = groupKeyOf(item);
      buckets.putIfAbsent(key, () => <FoodItem>[]).add(item);
    }

    final groups = buckets.values
        .map((bucket) => FoodItemGroup(items: sortByExpiry(bucket)))
        .toList()
      ..sort(_compareGroups);
    return groups;
  }

  /// 分組鍵：名稱正規化 + 位置 + 單位三者皆同才合併。
  static String groupKeyOf(FoodItem item) {
    final separator = String.fromCharCode(31); // Unit Separator，名稱不會包含
    return [
      normalizeFoodName(item.name),
      item.storageLocationId ?? '',
      item.unit?.name ?? '',
    ].join(separator);
  }

  /// 有效期限由近到遠；沒有期限的排最後（food-inventory 規格）。
  static List<FoodItem> sortByExpiry(List<FoodItem> items) {
    final sorted = List<FoodItem>.of(items);
    sorted.sort((a, b) {
      final left = a.effectiveExpiry;
      final right = b.effectiveExpiry;
      if (left == null && right == null) return a.name.compareTo(b.name);
      if (left == null) return 1;
      if (right == null) return -1;
      return left.compareTo(right);
    });
    return sorted;
  }

  static int _compareGroups(FoodItemGroup a, FoodItemGroup b) {
    final left = a.earliestExpiry;
    final right = b.earliestExpiry;
    if (left == null && right == null) return a.name.compareTo(b.name);
    if (left == null) return 1;
    if (right == null) return -1;
    final byExpiry = left.compareTo(right);
    return byExpiry != 0 ? byExpiry : a.name.compareTo(b.name);
  }
}
