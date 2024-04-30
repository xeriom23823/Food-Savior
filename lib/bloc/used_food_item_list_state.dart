part of 'used_food_item_list_bloc.dart';

abstract class UsedFoodItemListState extends Equatable {
  const UsedFoodItemListState();

  @override
  List<Object> get props => [];
}

final class UsedFoodItemListInitial extends UsedFoodItemListState {
  const UsedFoodItemListInitial();
}

final class UsedFoodItemListLoading extends UsedFoodItemListState {
  const UsedFoodItemListLoading();
}

final class UsedFoodItemListLoaded extends UsedFoodItemListState {
  final List<UsedFoodItem> usedFoodItems;
  const UsedFoodItemListLoaded({required this.usedFoodItems});

  @override
  List<Object> get props => [usedFoodItems];
}

final class UsedFoodItemListError extends UsedFoodItemListState {
  final String message;
  const UsedFoodItemListError({required this.message});

  @override
  List<Object> get props => [message];
}
