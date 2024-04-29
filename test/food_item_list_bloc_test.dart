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
      expect(foodItemListBloc.state, const FoodItemListInitial([]));
    });

    test(
        'emits FoodItemListLoading and FoodItemListLoaded when FoodItemListLoad event is added',
        () {
      final expectedStates = [
        const FoodItemListLoading([]),
        FoodItemListLoaded([
          FoodItem(
            name: 'Apple',
            type: FoodItemType.fruit,
            status: FoodItemStatus.fresh,
            description: 'A red apple',
            storageDate: DateTime.now(),
            expirationDate: DateTime.now().add(const Duration(days: 7)),
          ),
          FoodItem(
            name: 'Banana',
            type: FoodItemType.fruit,
            status: FoodItemStatus.fresh,
            description: 'A yellow banana',
            storageDate: DateTime.now(),
            expirationDate: DateTime.now().add(const Duration(days: 5)),
          ),
          FoodItem(
            name: 'Carrot',
            type: FoodItemType.vegetable,
            status: FoodItemStatus.fresh,
            description: 'An orange carrot',
            storageDate: DateTime.now(),
            expirationDate: DateTime.now().add(const Duration(days: 10)),
          ),
        ]),
      ];

      expectLater(foodItemListBloc.stream, emitsInOrder(expectedStates));

      foodItemListBloc.add(FoodItemListLoad());
    });

    test(
        'emits FoodItemListLoaded with updated food items when FoodItemListAdd event is added',
        () {
      final initialFoodItems = [
        FoodItem(
          name: 'Apple',
          type: FoodItemType.fruit,
          status: FoodItemStatus.fresh,
          description: 'A red apple',
          storageDate: DateTime.now(),
          expirationDate: DateTime.now().add(const Duration(days: 7)),
        ),
      ];

      final expectedStates = [
        FoodItemListLoaded(initialFoodItems),
        FoodItemListLoaded([
          ...initialFoodItems,
          FoodItem(
            name: 'Banana',
            type: FoodItemType.fruit,
            status: FoodItemStatus.fresh,
            description: 'A yellow banana',
            storageDate: DateTime.now(),
            expirationDate: DateTime.now().add(const Duration(days: 5)),
          ),
        ]),
      ];

      expectLater(foodItemListBloc.stream, emitsInOrder(expectedStates));

      foodItemListBloc.add(FoodItemListAdd(
        FoodItem(
          name: 'Banana',
          type: FoodItemType.fruit,
          status: FoodItemStatus.fresh,
          description: 'A yellow banana',
          storageDate: DateTime.now(),
          expirationDate: DateTime.now().add(const Duration(days: 5)),
        ),
      ));
    });
  });
}
