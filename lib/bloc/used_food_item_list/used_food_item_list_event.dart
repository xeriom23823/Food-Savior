part of 'used_food_item_list_bloc.dart';

abstract class UsedFoodItemListEvent {}

class UsedFoodItemListLoadFromDevice extends UsedFoodItemListEvent {}

class UsedFoodItemListLoad extends UsedFoodItemListEvent {
  final List<UsedFoodItem> usedFoodItems;

  UsedFoodItemListLoad({required this.usedFoodItems});
}

class UsedFoodItemListAdd extends UsedFoodItemListEvent {
  final UsedFoodItem usedFoodItem;

  UsedFoodItemListAdd({required this.usedFoodItem});
}

class UsedFoodItemListRemove extends UsedFoodItemListEvent {
  final UsedFoodItem usedFoodItem;

  UsedFoodItemListRemove({required this.usedFoodItem});
}

class UsedFoodItemListUpdate extends UsedFoodItemListEvent {
  final UsedFoodItem originalUsedFoodItem;
  final UsedFoodItem updatedUsedFoodItem;

  UsedFoodItemListUpdate(
      {required this.originalUsedFoodItem, required this.updatedUsedFoodItem});
}

class UsedFoodItemListClear extends UsedFoodItemListEvent {}

class UsedFoodItemListLoadByDate extends UsedFoodItemListEvent {
  final DateTime date;

  UsedFoodItemListLoadByDate({required this.date});
}
