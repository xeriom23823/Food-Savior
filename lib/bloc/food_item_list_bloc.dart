import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'food_item_list_event.dart';
part 'food_item_list_state.dart';

class FoodItemListBloc extends Bloc<FoodItemListEvent, FoodItemListState> {
  FoodItemListBloc() : super(const FoodItemListInitial()) {
    on<FoodItemListLoadFromDevice>(
      (event, emit) async {
        emit(const FoodItemListLoading());

        // 若 shared preferences 有食物資料，則讀取並顯示
        List<FoodItem> loadedFoodItems =
            await SharedPreferences.getInstance().then(
          (prefs) {
            final List<String> foodItemsJson =
                prefs.getStringList('foodItems') ?? <String>[];
            return foodItemsJson
                .map((foodItemJson) => FoodItem.fromJson(foodItemJson))
                .toList();
          },
        );

        if (loadedFoodItems.isEmpty) {
          emit(const FoodItemListLoaded(foodItems: []));
          return;
        }

        // expiration date 小於 3 天的食物標記為即將過期並排序
        loadedFoodItems = loadedFoodItems.map((foodItem) {
          if (foodItem.expirationDate.isBefore(
            DateTime.now().add(const Duration(days: 3)),
          )) {
            return foodItem.copyWith(status: FoodItemStatus.nearExpired);
          }
          return foodItem;
        }).toList()
          ..sort((a, b) => a.expirationDate.compareTo(b.expirationDate));

        // 標記過期的食物為已過期
        loadedFoodItems = loadedFoodItems.map((foodItem) {
          if (foodItem.expirationDate.isBefore(DateTime.now())) {
            return foodItem.copyWith(status: FoodItemStatus.expired);
          }
          return foodItem;
        }).toList();

        emit(
          FoodItemListLoaded(
            foodItems: loadedFoodItems,
          ),
        );

        // 將讀取的所有食物存到 shared preferences
        SharedPreferences.getInstance().then((prefs) {
          prefs.setStringList(
            'foodItems',
            loadedFoodItems.map((foodItem) => foodItem.toJson()).toList(),
          );
        });
      },
    );

    on<FoodItemListAdd>((event, emit) {
      if (state is FoodItemListLoaded) {
        final List<FoodItem> currentfoodItems =
            (state as FoodItemListLoaded).foodItems;
        emit(const FoodItemListLoading());

        // 小於 3 天的食物標記為即將過期
        final FoodItem newFoodItem = event.foodItem.expirationDate.isBefore(
          DateTime.now().add(const Duration(days: 3)),
        )
            ? event.foodItem.copyWith(status: FoodItemStatus.nearExpired)
            : event.foodItem;

        // 新增食物後重新排序
        final List<FoodItem> updatedFoodItems = List.from(currentfoodItems)
          ..add(newFoodItem)
          ..sort((a, b) => a.expirationDate.compareTo(b.expirationDate));
        emit(FoodItemListLoaded(foodItems: updatedFoodItems));

        // 將所有食物存到 shared preferences
        SharedPreferences.getInstance().then((prefs) {
          prefs.setStringList(
            'foodItems',
            updatedFoodItems.map((foodItem) => foodItem.toJson()).toList(),
          );
        });
      }
    });

    on<FoodItemListRemove>((event, emit) {
      if (state is FoodItemListLoaded) {
        final List<FoodItem> currentfoodItems =
            (state as FoodItemListLoaded).foodItems;
        emit(const FoodItemListLoading());

        List<FoodItem> updatedFoodItems = currentfoodItems
            .where((foodItem) => foodItem != event.foodItem)
            .toList();
        emit(FoodItemListLoaded(foodItems: updatedFoodItems));

        // 將所有食物存到 shared preferences
        SharedPreferences.getInstance().then((prefs) {
          prefs.setStringList(
            'foodItems',
            updatedFoodItems.map((foodItem) => foodItem.toJson()).toList(),
          );
        });
      }
    });

    on<FoodItemListUpdate>((event, emit) {
      if (state is FoodItemListLoaded) {
        emit(const FoodItemListLoading());
        final List<FoodItem> currentfoodItems =
            (state as FoodItemListLoaded).foodItems;
        emit(const FoodItemListLoading());

        List<FoodItem> updatedFoodItems = currentfoodItems
            .map((foodItem) => foodItem == event.originalFoodItem
                ? event.updatedFoodItem
                : foodItem)
            .toList()
          ..sort((a, b) => a.expirationDate.compareTo(b.expirationDate));

        emit(FoodItemListLoaded(foodItems: updatedFoodItems));

        // 將所有食物存到 shared preferences
        SharedPreferences.getInstance().then((prefs) {
          prefs.setStringList(
            'foodItems',
            updatedFoodItems.map((foodItem) => foodItem.toJson()).toList(),
          );
        });
      }
    });

    add(FoodItemListLoadFromDevice());
  }
}
