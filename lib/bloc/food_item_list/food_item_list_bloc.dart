import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/repositories/food_item_repository.dart';

part 'food_item_list_event.dart';
part 'food_item_list_state.dart';

class FoodItemListBloc extends Bloc<FoodItemListEvent, FoodItemListState> {
  final FoodItemRepository foodItemRepository;

  FoodItemListBloc({required this.foodItemRepository})
      : super(const FoodItemListInitial()) {
    on<LoadFoodItemListFromDevice>(
      (event, emit) async {
        emit(const FoodItemListLoading());

        // 更新 foodItemBox 中所有食物的狀態
        await foodItemRepository.updateAllFoodItemsStatus();

        // 從 Hive 取得所有食物項目
        List<FoodItem> loadedFoodItems =
            foodItemRepository.getNonExpiredFoodItems();

        List<FoodItem> expiredFoodItems =
            foodItemRepository.getExpiredFoodItems();

        // 有過期的食物
        if (expiredFoodItems.isNotEmpty) {
          loadedFoodItems = loadedFoodItems
              .where((foodItem) => foodItem.status != FoodItemStatus.expired)
              .toList();
          emit(FoodItemListNeedProcessing(
            remainFoodItems: loadedFoodItems,
            tempFoodItems: expiredFoodItems,
            isConsumed: List.filled(expiredFoodItems.length, false),
          ));
          return;
        }

        emit(
          FoodItemListLoaded(
            foodItems: loadedFoodItems,
          ),
        );
      },
    );

    on<FoodItemListLoad>((event, emit) async {
      List<FoodItem> loadedFoodItems = event.foodItems;
      emit(const FoodItemListLoading());

      // 標記 expirationDate 小於今天的食物為 expired
      final List<FoodItem> expiredFoodItems = loadedFoodItems
          .where((foodItem) => foodItem.expirationDate.isBefore(DateTime.now()))
          .map((foodItem) => foodItem.copyWith(status: FoodItemStatus.expired))
          .toList();

      // 紀錄 expirationDate 大於等於今天的食物
      List<FoodItem> remainFoodItems = loadedFoodItems
          .where((foodItem) => foodItem.expirationDate.isAfter(DateTime.now()))
          .toList();

      // 將 remainFoodItems 中 expirationDate 小於 3 天的食物標記為 nearExpired
      remainFoodItems = remainFoodItems.map((foodItem) {
        if (foodItem.expirationDate.isBefore(
          DateTime.now().add(const Duration(days: 3)),
        )) {
          return foodItem.copyWith(status: FoodItemStatus.nearExpired);
        }
        return foodItem;
      }).toList();

      // 將沒過期的 food item 存到 Hive 中
      await foodItemRepository.saveFoodItems(remainFoodItems);

      if (expiredFoodItems.isNotEmpty) {
        loadedFoodItems = loadedFoodItems
            .where((foodItem) => foodItem.status != FoodItemStatus.expired)
            .toList();
        emit(FoodItemListNeedProcessing(
          remainFoodItems: remainFoodItems,
          tempFoodItems: expiredFoodItems,
          isConsumed: List.filled(expiredFoodItems.length, false),
        ));
        return;
      }

      emit(FoodItemListLoaded(foodItems: loadedFoodItems));
    });

    on<FoodItemListAdd>((event, emit) async {
      if (state is FoodItemListLoaded) {
        final List<FoodItem> currentfoodItems =
            (state as FoodItemListLoaded).foodItems;
        emit(const FoodItemListLoading());

        // 小於 3 天的食物標記為即將過期
        final FoodItem newFoodItem = event.foodItem.expirationDate.isBefore(
          DateTime.now().add(const Duration(days: 3)),
        )
            ? event.foodItem.copyWith(
                id: event.foodItem.id, status: FoodItemStatus.nearExpired)
            : event.foodItem;

        // 新增食物後重新排序
        final List<FoodItem> updatedFoodItems = List.from(currentfoodItems)
          ..add(newFoodItem)
          ..sort((a, b) => a.expirationDate.compareTo(b.expirationDate));

        // 使用 repository 儲存資料
        await foodItemRepository.saveFoodItem(newFoodItem);

        emit(FoodItemListLoaded(foodItems: updatedFoodItems));
      }
    });

    on<FoodItemListRemove>((event, emit) async {
      if (state is FoodItemListLoaded) {
        final List<FoodItem> currentfoodItems =
            (state as FoodItemListLoaded).foodItems;
        emit(const FoodItemListLoading());

        List<FoodItem> updatedFoodItems = currentfoodItems
            .where((foodItem) => foodItem != event.foodItem)
            .toList();

        // 使用 repository 刪除資料
        await foodItemRepository.deleteFoodItem(event.foodItem.id);

        emit(FoodItemListLoaded(foodItems: updatedFoodItems));
      }
    });

    on<FoodItemListUpdate>((event, emit) async {
      if (state is FoodItemListLoaded) {
        final List<FoodItem> currentfoodItems =
            (state as FoodItemListLoaded).foodItems;
        emit(const FoodItemListLoading());

        List<FoodItem> updatedFoodItems = currentfoodItems
            .map((foodItem) => foodItem == event.originalFoodItem
                ? event.updatedFoodItem
                : foodItem)
            .toList()
          ..sort((a, b) => a.expirationDate.compareTo(b.expirationDate));

        // 使用 repository 更新資料
        await foodItemRepository.saveFoodItem(event.updatedFoodItem);

        emit(FoodItemListLoaded(foodItems: updatedFoodItems));
      }
    });

    on<FoodItemListClear>((event, emit) async {
      if (state is FoodItemListLoaded) {
        emit(const FoodItemListLoading());

        // 使用 repository 清空資料
        await foodItemRepository.clearAll();

        emit(const FoodItemListLoaded(foodItems: []));
      }
    });

    on<FoodItemListProcessingUpdate>((event, emit) async {
      if (state is FoodItemListNeedProcessing) {
        final List<FoodItem> remainFoodItems =
            (state as FoodItemListNeedProcessing).remainFoodItems;
        final List<FoodItem> tempFoodItems =
            (state as FoodItemListNeedProcessing).tempFoodItems;
        List<bool> isConsumed =
            (state as FoodItemListNeedProcessing).isConsumed;
        emit(const FoodItemListLoading());

        isConsumed[event.updateIndex] = !isConsumed[event.updateIndex];

        emit(FoodItemListNeedProcessing(
          remainFoodItems: remainFoodItems,
          tempFoodItems: tempFoodItems,
          isConsumed: isConsumed,
        ));
      }
    });

    on<FoodItemListProcessComplete>((event, emit) async {
      if (state is FoodItemListNeedProcessing) {
        List<FoodItem> remainFoodItems =
            (state as FoodItemListNeedProcessing).remainFoodItems;

        emit(const FoodItemListLoading());

        remainFoodItems = foodItemRepository.getNonExpiredFoodItems();
        emit(FoodItemListLoaded(foodItems: remainFoodItems));
      }
    });

    add(LoadFoodItemListFromDevice());
  }
}
