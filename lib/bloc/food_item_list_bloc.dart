import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:food_savior/models/food_item.dart';

part 'food_item_list_event.dart';
part 'food_item_list_state.dart';

class FoodItemListBloc extends Bloc<FoodItemListEvent, FoodItemListState> {
  FoodItemListBloc() : super(const FoodItemListInitial()) {
    on<FoodItemListLoad>(
      (event, emit) {
        emit(const FoodItemListLoading());
        List<FoodItem> loadedFoodItems = [
          FoodItem(
            name: '胡蘿蔔',
            type: FoodItemType.vegetable,
            status: FoodItemStatus.fresh,
            description: '一個橙色的胡蘿蔔',
            storageDate: DateTime.now(),
            expirationDate: DateTime.now().add(const Duration(days: 10)),
          ),
          FoodItem(
            name: '蘋果',
            type: FoodItemType.fruit,
            status: FoodItemStatus.fresh,
            description: '一個紅色的蘋果',
            storageDate: DateTime.now(),
            expirationDate: DateTime.now().add(const Duration(days: 7)),
          ),
          FoodItem(
            name: '牛肉',
            type: FoodItemType.meat,
            status: FoodItemStatus.fresh,
            description: '一塊新鮮的牛肉',
            storageDate: DateTime.now(),
            expirationDate: DateTime.now().add(const Duration(days: 5)),
          ),
          FoodItem(
            name: '雞蛋',
            type: FoodItemType.eggAndMilk,
            status: FoodItemStatus.fresh,
            description: '一個新鮮的雞蛋',
            storageDate: DateTime.now(),
            expirationDate: DateTime.now().add(const Duration(days: 21)),
          ),
          FoodItem(
            name: '鮭魚',
            type: FoodItemType.seafood,
            status: FoodItemStatus.fresh,
            description: '一塊新鮮的鮭魚',
            storageDate: DateTime.now(),
            expirationDate: DateTime.now().add(const Duration(days: 3)),
          ),
          FoodItem(
            name: '罐頭豆',
            type: FoodItemType.cannedFood,
            status: FoodItemStatus.fresh,
            description: '一罐罐頭豆',
            storageDate: DateTime.now(),
            expirationDate: DateTime.now().add(const Duration(days: 365)),
          ),
          FoodItem(
            name: '炒飯',
            type: FoodItemType.cookedFood,
            status: FoodItemStatus.fresh,
            description: '一盤炒飯',
            storageDate: DateTime.now(),
            expirationDate: DateTime.now().add(const Duration(days: 2)),
          ),
          FoodItem(
            name: '橙汁',
            type: FoodItemType.drink,
            status: FoodItemStatus.fresh,
            description: '一瓶橙汁',
            storageDate: DateTime.now(),
            expirationDate: DateTime.now().add(const Duration(days: 14)),
          ),
          FoodItem(
            name: '薯片',
            type: FoodItemType.snack,
            status: FoodItemStatus.fresh,
            description: '一包薯片',
            storageDate: DateTime.now(),
            expirationDate: DateTime.now().add(const Duration(days: 60)),
          ),
          FoodItem(
            name: '麵包',
            type: FoodItemType.bread,
            status: FoodItemStatus.fresh,
            description: '一條麵包',
            storageDate: DateTime.now(),
            expirationDate: DateTime.now().add(const Duration(days: 5)),
          ),
          FoodItem(
            name: '調味料',
            type: FoodItemType.others,
            status: FoodItemStatus.fresh,
            description: '一瓶調味料',
            storageDate: DateTime.now(),
            expirationDate: DateTime.now().add(const Duration(days: 730)),
          ),
        ];

        // expiration date 小於 3 天的食物標記為即將過期
        loadedFoodItems = loadedFoodItems.map((foodItem) {
          if (foodItem.expirationDate.isBefore(
            DateTime.now().add(const Duration(days: 3)),
          )) {
            return foodItem.copyWith(status: FoodItemStatus.nearExpired);
          }
          return foodItem;
        }).toList();

        // 依照 expiration date 排序
        emit(
          FoodItemListLoaded(
            foodItems: loadedFoodItems
              ..sort((a, b) => a.expirationDate.compareTo(b.expirationDate)),
          ),
        );
      },
    );

    on<FoodItemListAdd>((event, emit) {
      if (state is FoodItemListLoaded) {
        final List<FoodItem> currentfoodItems =
            (state as FoodItemListLoaded).foodItems;
        emit(const FoodItemListLoading());

        // event.foodItem.expirationDate 小於 3 天的食物標記為即將過期
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
      }
    });

    on<FoodItemListUpdate>((event, emit) {
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

        emit(FoodItemListLoaded(foodItems: updatedFoodItems));
      }
    });
  }
}
