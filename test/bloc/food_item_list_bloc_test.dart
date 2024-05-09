import 'package:bloc_test/bloc_test.dart';
import 'package:food_savior/bloc/food_item_list_bloc.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

void main() {
  SharedPreferences.setMockInitialValues({});
  group('FoodItemListBloc', () {
    late FoodItemListBloc foodItemListBloc;
    final testFoodItem = FoodItem(
      id: '1',
      name: 'Apple',
      type: FoodItemType.fruit,
      quantity: 3,
      unit: Unit.piece,
      description: 'Fresh and juicy',
      storageDate: DateTime.now().subtract(const Duration(days: 1)),
      expirationDate: DateTime.now().add(const Duration(days: 2)),
      status: FoodItemStatus.nearExpired,
    );

    setUp(() {
      foodItemListBloc = FoodItemListBloc();
    });

    tearDown(() {
      foodItemListBloc.close();
    });

    test('initial state is FoodItemListLoading', () {
      expect(foodItemListBloc.state, const FoodItemListLoading());
    });

    blocTest<FoodItemListBloc, FoodItemListState>(
      'emits [FoodItemListLoading, FoodItemListLoaded] when FoodItemListAdd is added',
      build: () => foodItemListBloc,
      act: (bloc) => bloc.add(FoodItemListAdd(foodItem: testFoodItem)),
      expect: () => [
        const FoodItemListLoading(),
        FoodItemListLoaded(foodItems: [testFoodItem]),
      ],
    );

    blocTest<FoodItemListBloc, FoodItemListState>(
      'emits [FoodItemListLoading, FoodItemListLoaded] when FoodItemListRemove is added',
      build: () => foodItemListBloc,
      act: (bloc) => bloc.add(FoodItemListRemove(foodItem: testFoodItem)),
      expect: () => [
        const FoodItemListLoading(),
        const FoodItemListLoaded(foodItems: []),
      ],
    );
  });
}
