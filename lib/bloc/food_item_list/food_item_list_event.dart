part of 'food_item_list_bloc.dart';

sealed class FoodItemListEvent {
  const FoodItemListEvent();
}

/// 啟動時從本機載入（含狀態重新推導與過期檢查）。
class FoodItemListStarted extends FoodItemListEvent {
  const FoodItemListStarted();
}

/// 一行快速新增：只有名稱，其餘由建議機制決定（food-inventory 規格）。
class FoodItemListQuickAdd extends FoodItemListEvent {
  const FoodItemListQuickAdd({required this.name});

  final String name;
}

class FoodItemListAdd extends FoodItemListEvent {
  const FoodItemListAdd({required this.foodItem});

  final FoodItem foodItem;
}

/// 以 id 比對更新，呼叫端不需要傳入清單中的同一個實例。
class FoodItemListUpdate extends FoodItemListEvent {
  const FoodItemListUpdate({required this.foodItem});

  final FoodItem foodItem;
}

class FoodItemListRemove extends FoodItemListEvent {
  const FoodItemListRemove({required this.id});

  final String id;
}

/// 補期限：不必開完整表單。
class FoodItemListFillExpiry extends FoodItemListEvent {
  const FoodItemListFillExpiry({required this.id, required this.expiry});

  final String id;
  final ExpiryValue expiry;
}

class FoodItemListMarkOpened extends FoodItemListEvent {
  const FoodItemListMarkOpened({
    required this.id,
    this.shelfLifeAfterOpenDays,
  });

  final String id;
  final int? shelfLifeAfterOpenDays;
}

/// 全部使用／丟棄。[items] 可以是合併卡片的多個批次。
class FoodItemListUseAll extends FoodItemListEvent {
  const FoodItemListUseAll({
    required this.items,
    required this.disposalMethod,
    this.wasteReason,
  });

  final List<FoodItem> items;
  final DisposalMethod disposalMethod;
  final WasteReason? wasteReason;
}

/// 部分處理：可同時記食用與丟棄，跨批次依 FEFO 扣減。
class FoodItemListPartialUse extends FoodItemListEvent {
  const FoodItemListPartialUse({
    required this.items,
    required this.consumedAmount,
    required this.wastedAmount,
    required this.usedDate,
    this.wasteReason,
    this.remainingAfter,
  });

  final List<FoodItem> items;
  final double consumedAmount;
  final double wastedAmount;
  final DateTime usedDate;
  final WasteReason? wasteReason;

  /// 以剩餘比例記錄的項目：用掉後還剩多少。null 代表用完。
  final RemainingFraction? remainingAfter;
}

class FoodItemListGroupingChanged extends FoodItemListEvent {
  const FoodItemListGroupingChanged({required this.grouping});

  final FoodListGrouping grouping;
}

/// 位置有增刪改時重新載入，讓分群標題跟著更新。
class FoodItemListLocationsChanged extends FoodItemListEvent {
  const FoodItemListLocationsChanged();
}

/// 還原：以雲端資料整批取代本機。
class FoodItemListLoad extends FoodItemListEvent {
  const FoodItemListLoad({required this.foodItems});

  final List<FoodItem> foodItems;
}

class FoodItemListClear extends FoodItemListEvent {
  const FoodItemListClear();
}

class FoodItemListProcessingUpdate extends FoodItemListEvent {
  const FoodItemListProcessingUpdate({required this.updateIndex});

  final int updateIndex;
}

class FoodItemListProcessComplete extends FoodItemListEvent {
  const FoodItemListProcessComplete({this.wasteReason});

  final WasteReason? wasteReason;
}
