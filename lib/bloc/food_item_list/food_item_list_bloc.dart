import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/repositories/food_item_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      // expiration date 小於 3 天的食物標記為即將過期並排序
      List<FoodItem> loadedFoodItems = event.foodItems
          .map((foodItem) => foodItem.expirationDate.isBefore(
                DateTime.now().add(const Duration(days: 3)),
              )
                  ? foodItem.copyWith(
                      id: foodItem.id, status: FoodItemStatus.nearExpired)
                  : foodItem)
          .toList()
        ..sort((a, b) => a.expirationDate.compareTo(b.expirationDate));

      // 標記過期的食物為已過期
      final List<FoodItem> expiredFoodItems = loadedFoodItems
          .where((foodItem) => foodItem.status == FoodItemStatus.expired)
          .toList();

      // 將 food item list 存到 Hive 中
      await foodItemRepository.replaceAllFoodItems(loadedFoodItems);

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

        // 將所有食物存到 shared preferences
        await SharedPreferences.getInstance().then((prefs) {
          prefs.setStringList(
            'foodItems',
            updatedFoodItems
                .map((foodItem) => foodItem.toJsonString())
                .toList(),
          );
        });

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

        // 將所有食物存到 shared preferences
        await SharedPreferences.getInstance().then((prefs) {
          prefs.setStringList(
            'foodItems',
            updatedFoodItems
                .map((foodItem) => foodItem.toJsonString())
                .toList(),
          );
        });

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

        // 將所有食物存到 shared preferences
        await SharedPreferences.getInstance().then((prefs) {
          prefs.setStringList(
            'foodItems',
            updatedFoodItems
                .map((foodItem) => foodItem.toJsonString())
                .toList(),
          );
        });

        emit(FoodItemListLoaded(foodItems: updatedFoodItems));
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
        final List<FoodItem> remainFoodItems =
            (state as FoodItemListNeedProcessing).remainFoodItems;
        emit(const FoodItemListLoading());

        // 將所有食物存到 shared preferences
        await SharedPreferences.getInstance().then((prefs) {
          prefs.setStringList(
            'foodItems',
            remainFoodItems.map((foodItem) => foodItem.toJsonString()).toList(),
          );
        });

        emit(FoodItemListLoaded(foodItems: remainFoodItems));
      }
    });

    add(LoadFoodItemListFromDevice());
  }
}
