part of 'used_food_item_list_bloc.dart';

/// 紀錄頁的篩選：只看食用、只看浪費，或全部。
enum UsedFoodFilter { all, consumed, wasted }

sealed class UsedFoodItemListEvent {
  const UsedFoodItemListEvent();
}

class UsedFoodItemListStarted extends UsedFoodItemListEvent {
  const UsedFoodItemListStarted();
}

/// 有新紀錄寫入時重新讀取當前日期（食物頁操作後會派這個）。
class UsedFoodItemListRefresh extends UsedFoodItemListEvent {
  const UsedFoodItemListRefresh();
}

class UsedFoodItemListLoadByDate extends UsedFoodItemListEvent {
  const UsedFoodItemListLoadByDate({required this.date});

  final DateTime date;
}

class UsedFoodItemListFilterChanged extends UsedFoodItemListEvent {
  const UsedFoodItemListFilterChanged({required this.filter});

  final UsedFoodFilter filter;
}

class UsedFoodItemListRemove extends UsedFoodItemListEvent {
  const UsedFoodItemListRemove({required this.id});

  final String id;
}

/// 事後補浪費原因。不改變該筆的點數。
class UsedFoodItemListSetWasteReason extends UsedFoodItemListEvent {
  const UsedFoodItemListSetWasteReason({
    required this.id,
    required this.wasteReason,
  });

  final String id;
  final WasteReason wasteReason;
}

/// 還原：保留備份中的點數，不重新計算。
class UsedFoodItemListLoad extends UsedFoodItemListEvent {
  const UsedFoodItemListLoad({required this.usedFoodItems});

  final List<UsedFoodItem> usedFoodItems;
}

class UsedFoodItemListClear extends UsedFoodItemListEvent {
  const UsedFoodItemListClear();
}
