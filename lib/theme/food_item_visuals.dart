import 'package:flutter/material.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/models/storage_location.dart';

/// 圖示與狀態視覺的集中定義。
///
/// 顏色一律來自 `FoodStatusColors` 與 `ColorScheme`，這裡只決定「用哪個圖示」。
abstract final class FoodItemVisuals {
  /// E 組食物類型圖示的 asset 對照。顏色由 [FoodTypeIcon] 依 IconTheme 套用。
  static String assetOf(FoodItemType type) => switch (type) {
        FoodItemType.vegetable => 'assets/icons/food_type_vegetable.png',
        FoodItemType.fruit => 'assets/icons/food_type_fruit.png',
        FoodItemType.meat => 'assets/icons/food_type_meat.png',
        FoodItemType.eggAndMilk => 'assets/icons/food_type_egg_milk.png',
        FoodItemType.seafood => 'assets/icons/food_type_seafood.png',
        FoodItemType.cannedFood => 'assets/icons/food_type_canned_food.png',
        FoodItemType.cookedFood => 'assets/icons/food_type_cooked_food.png',
        FoodItemType.drink => 'assets/icons/food_type_drink.png',
        FoodItemType.snack => 'assets/icons/food_type_snack.png',
        FoodItemType.bread => 'assets/icons/food_type_bread.png',
        FoodItemType.others => 'assets/icons/food_type_others.png',
      };

  static IconData statusIconOf(FoodItemStatus status) => switch (status) {
        FoodItemStatus.fresh => Icons.check_circle_outline,
        FoodItemStatus.nearExpired => Icons.schedule,
        FoodItemStatus.expired => Icons.error_outline,
        FoodItemStatus.consumed => Icons.restaurant,
        FoodItemStatus.wasted => Icons.delete_outline,
        FoodItemStatus.unknownExpiry => Icons.help_outline,
      };

  /// 期限精度的視覺語彙（art-requests C 組；先用 Material 圖示頂替）。
  static IconData expiryIconOf(ExpiryPrecision precision) =>
      switch (precision) {
        ExpiryPrecision.exact => Icons.event_available,
        ExpiryPrecision.range => Icons.date_range,
        ExpiryPrecision.monthOnly => Icons.calendar_month,
        ExpiryPrecision.unknown => Icons.event_busy,
      };

  static IconData locationIconOf(LocationKind kind) => switch (kind) {
        LocationKind.refrigerated => Icons.kitchen,
        LocationKind.frozen => Icons.ac_unit,
        LocationKind.ambient => Icons.shelves,
        LocationKind.other => Icons.inventory_2_outlined,
      };

  static IconData disposalIconOf(DisposalMethod method) => switch (method) {
        DisposalMethod.eaten => Icons.restaurant,
        DisposalMethod.eatenAtRisk => Icons.restaurant_menu,
        DisposalMethod.givenAway => Icons.volunteer_activism,
        DisposalMethod.composted => Icons.compost,
        DisposalMethod.discarded => Icons.delete_outline,
      };

  static IconData wasteReasonIconOf(WasteReason reason) => switch (reason) {
        WasteReason.forgotten => Icons.timer_off_outlined,
        WasteReason.boughtTooMuch => Icons.shopping_basket_outlined,
        WasteReason.spoiled => Icons.sick_outlined,
        WasteReason.disliked => Icons.thumb_down_outlined,
        WasteReason.expiredTooLong => Icons.event_busy,
        WasteReason.other => Icons.more_horiz,
      };
}
