part of 'used_food_item_list_bloc.dart';

sealed class UsedFoodItemListState extends Equatable {
  const UsedFoodItemListState();

  @override
  List<Object?> get props => [];
}

final class UsedFoodItemListInitial extends UsedFoodItemListState {
  const UsedFoodItemListInitial();
}

final class UsedFoodItemListLoading extends UsedFoodItemListState {
  const UsedFoodItemListLoading();
}

final class UsedFoodItemListLoaded extends UsedFoodItemListState {
  const UsedFoodItemListLoaded({
    required this.usedFoodItems,
    required this.selectedDate,
    this.filter = UsedFoodFilter.all,
  });

  /// 已套用篩選、依使用時間排序的當日紀錄。
  final List<UsedFoodItem> usedFoodItems;
  final DateTime selectedDate;
  final UsedFoodFilter filter;

  @override
  List<Object?> get props => [usedFoodItems, selectedDate, filter];
}

final class UsedFoodItemListError extends UsedFoodItemListState {
  const UsedFoodItemListError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
