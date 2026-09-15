import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/models/food_item_group.dart';

/// 主清單的分群方式。使用者的選擇會持久化（food-inventory 規格）。
enum FoodListGrouping { urgency, location, type }

/// 依到期急迫度的分群。順序即畫面上的顯示順序。
enum UrgencyBucket {
  expired,
  today,
  withinThreeDays,
  withinWeek,
  plenty,
  unknownExpiry,
}

/// 一個分群區塊：標題所需的資訊 + 該群的合併卡片。
class FoodListSection {
  const FoodListSection({
    required this.groups,
    this.urgency,
    this.locationId,
    this.type,
  });

  final List<FoodItemGroup> groups;

  /// 依急迫度分群時有值。
  final UrgencyBucket? urgency;

  /// 依位置分群時有值；null 代表「未指定位置」。
  final String? locationId;

  /// 依類型分群時有值。
  final FoodItemType? type;

  int get itemCount =>
      groups.fold<int>(0, (sum, group) => sum + group.items.length);
}

/// 把清單切成畫面上的區塊。
///
/// **先合併同名批次，再分群**：一張「雞蛋 18 個」的卡片不該因為兩個批次的
/// 急迫度不同而被拆成兩張（design D18）。合併後的卡片以組內最早的期限歸類。
List<FoodListSection> buildSections({
  required List<FoodItem> items,
  required FoodListGrouping grouping,
  required DateTime now,
  List<String> locationOrder = const [],
}) {
  final groups = FoodItemGroup.groupAll(items);
  switch (grouping) {
    case FoodListGrouping.urgency:
      return _byUrgency(groups, now);
    case FoodListGrouping.location:
      return _byLocation(groups, locationOrder);
    case FoodListGrouping.type:
      return _byType(groups);
  }
}

UrgencyBucket urgencyOf(FoodItem item, DateTime now) =>
    _bucketOf(item.effectiveExpiry, now);

UrgencyBucket _bucketOf(DateTime? expiry, DateTime now) {
  if (expiry == null) return UrgencyBucket.unknownExpiry;
  final days = daysUntilExpiry(expiry, now);
  if (days < 0) return UrgencyBucket.expired;
  if (days == 0) return UrgencyBucket.today;
  if (days <= 3) return UrgencyBucket.withinThreeDays;
  if (days <= 7) return UrgencyBucket.withinWeek;
  return UrgencyBucket.plenty;
}

List<FoodListSection> _byUrgency(List<FoodItemGroup> groups, DateTime now) {
  final buckets = <UrgencyBucket, List<FoodItemGroup>>{};
  for (final group in groups) {
    buckets
        .putIfAbsent(_bucketOf(group.earliestExpiry, now), () => [])
        .add(group);
  }
  return UrgencyBucket.values
      .where((bucket) => buckets[bucket]?.isNotEmpty ?? false)
      .map((bucket) =>
          FoodListSection(urgency: bucket, groups: buckets[bucket]!))
      .toList();
}

List<FoodListSection> _byLocation(
  List<FoodItemGroup> groups,
  List<String> locationOrder,
) {
  final buckets = <String?, List<FoodItemGroup>>{};
  for (final group in groups) {
    buckets.putIfAbsent(group.storageLocationId, () => []).add(group);
  }

  final ordered = <String?>[
    ...locationOrder.where(buckets.containsKey),
    ...buckets.keys.where(
      (key) => key != null && !locationOrder.contains(key),
    ),
    if (buckets.containsKey(null)) null,
  ];

  return ordered
      .map((locationId) =>
          FoodListSection(locationId: locationId, groups: buckets[locationId]!))
      .toList();
}

List<FoodListSection> _byType(List<FoodItemGroup> groups) {
  final buckets = <FoodItemType, List<FoodItemGroup>>{};
  for (final group in groups) {
    buckets.putIfAbsent(group.type, () => []).add(group);
  }
  return FoodItemType.values
      .where((type) => buckets[type]?.isNotEmpty ?? false)
      .map((type) => FoodListSection(type: type, groups: buckets[type]!))
      .toList();
}
