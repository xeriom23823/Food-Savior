import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/bloc/food_item_list_bloc.dart';
import 'package:food_savior/models/food_item.dart';

void main() {
  group('FoodItemListBloc', () {
    late FoodItemListBloc foodItemListBloc;

    setUp(() {
      foodItemListBloc = FoodItemListBloc();
    });

    tearDown(() {
      foodItemListBloc.close();
    });

    test('initial state is FoodItemListInitial', () {
      expect(foodItemListBloc.state, const FoodItemListInitial());
    });

    test('load food items and check the result', () {
      List<FoodItem> expectedFoodItems = [
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

      expectedFoodItems = expectedFoodItems.map((foodItem) {
        if (foodItem.expirationDate.isBefore(
          DateTime.now().add(const Duration(days: 3)),
        )) {
          return foodItem.copyWith(status: FoodItemStatus.nearExpired);
        }
        return foodItem;
      }).toList()
        ..sort((a, b) => a.expirationDate.compareTo(b.expirationDate));

      foodItemListBloc.add(FoodItemListLoadFromDevice());
      expectLater(
        foodItemListBloc.stream,
        emitsInOrder([
          const FoodItemListLoading(),
          FoodItemListLoaded(foodItems: expectedFoodItems),
        ]),
      );
    });
  });
}
