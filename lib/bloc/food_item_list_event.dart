part of 'food_item_list_bloc.dart';

abstract class FoodItemListEvent {}

class FoodItemListLoad extends FoodItemListEvent {}

class FoodItemListAdd extends FoodItemListEvent {
  final FoodItem foodItem;

  FoodItemListAdd(this.foodItem);
}

class FoodItemListRemove extends FoodItemListEvent {
  final FoodItem foodItem;

  FoodItemListRemove(this.foodItem);
}
