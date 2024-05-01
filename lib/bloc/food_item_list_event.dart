part of 'food_item_list_bloc.dart';

abstract class FoodItemListEvent {}

class FoodItemListLoadFromDevice extends FoodItemListEvent {}

class FoodItemListAdd extends FoodItemListEvent {
  final FoodItem foodItem;

  FoodItemListAdd({required this.foodItem});
}

class FoodItemListRemove extends FoodItemListEvent {
  final FoodItem foodItem;

  FoodItemListRemove({required this.foodItem});
}

class FoodItemListUpdate extends FoodItemListEvent {
  final FoodItem originalFoodItem;
  final FoodItem updatedFoodItem;

  FoodItemListUpdate(
      {required this.originalFoodItem, required this.updatedFoodItem});
}
