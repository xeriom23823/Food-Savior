part of 'food_item_list_bloc.dart';

/// 操作後要給使用者的回饋。[revision] 讓連續兩次相同操作仍是不同的 state。
class FoodItemFeedback extends Equatable {
  const FoodItemFeedback({
    required this.kind,
    required this.revision,
    this.itemName,
    this.records = const [],
  });

  final FoodItemFeedbackKind kind;
  final int revision;
  final String? itemName;

  /// 這次操作寫進使用紀錄的項目，供頁面顯示點數與刷新紀錄頁。
  final List<UsedFoodItem> records;

  @override
  List<Object?> get props => [kind, revision, itemName, records];
}

enum FoodItemFeedbackKind { added, updated, removed, consumed, wasted, mixed }

sealed class FoodItemListState extends Equatable {
  const FoodItemListState();

  @override
  List<Object?> get props => [];
}

final class FoodItemListInitial extends FoodItemListState {
  const FoodItemListInitial();
}

final class FoodItemListLoading extends FoodItemListState {
  const FoodItemListLoading();
}

/// 啟動時發現過期食物，先請使用者一筆一筆處理。
final class FoodItemListNeedProcessing extends FoodItemListState {
  const FoodItemListNeedProcessing({
    required this.remainFoodItems,
    required this.expiredFoodItems,
    required this.isConsumed,
  });

  final List<FoodItem> remainFoodItems;
  final List<FoodItem> expiredFoodItems;
  final List<bool> isConsumed;

  @override
  List<Object?> get props => [remainFoodItems, expiredFoodItems, isConsumed];
}

final class FoodItemListLoaded extends FoodItemListState {
  const FoodItemListLoaded({
    required this.foodItems,
    required this.sections,
    required this.grouping,
    required this.locations,
    this.feedback,
  });

  /// 全部項目，已依有效期限排序。
  final List<FoodItem> foodItems;

  /// 畫面上的分群區塊（已套用合併）。
  final List<FoodListSection> sections;

  final FoodListGrouping grouping;
  final List<StorageLocation> locations;
  final FoodItemFeedback? feedback;

  StorageLocation? locationOf(String? id) {
    if (id == null) return null;
    for (final location in locations) {
      if (location.id == id) return location;
    }
    return null;
  }

  @override
  List<Object?> get props => [foodItems, grouping, locations, feedback];
}

final class FoodItemListError extends FoodItemListState {
  const FoodItemListError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
