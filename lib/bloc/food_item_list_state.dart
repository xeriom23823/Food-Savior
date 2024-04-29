part of 'food_item_list_bloc.dart';

abstract class FoodItemListState extends Equatable {
  final List<FoodItem> foodItems;
  const FoodItemListState(this.foodItems);

  @override
  List<Object> get props => [foodItems];
}

final class FoodItemListInitial extends FoodItemListState {
  const FoodItemListInitial(super.foodItems);
}

final class FoodItemListLoading extends FoodItemListState {
  const FoodItemListLoading(super.foodItems);
}

final class FoodItemListLoaded extends FoodItemListState {
  const FoodItemListLoaded(super.foodItems);
}
