part of 'food_item_list_bloc.dart';

abstract class FoodItemListState extends Equatable {
  const FoodItemListState();

  @override
  List<Object> get props => [];
}

final class FoodItemListInitial extends FoodItemListState {
  const FoodItemListInitial();
}

final class FoodItemListLoading extends FoodItemListState {
  const FoodItemListLoading();
}

final class FoodItemListLoaded extends FoodItemListState {
  final List<FoodItem> foodItems;
  const FoodItemListLoaded({required this.foodItems});

  @override
  List<Object> get props => [foodItems];
}

final class FoodItemListError extends FoodItemListState {
  final String message;
  final List<FoodItem> tempFoodItems;
  const FoodItemListError(
      {required this.message, this.tempFoodItems = const []});

  @override
  List<Object> get props => [message];
}
