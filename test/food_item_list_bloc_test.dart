import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/bloc/food_item_list_bloc.dart';

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
  });
}
