import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:food_savior/models/food_item.dart';

part 'food_item_list_event.dart';
part 'food_item_list_state.dart';

class FoodItemListBloc extends Bloc<FoodItemListEvent, FoodItemListState> {
  FoodItemListBloc() : super(const FoodItemListInitial([])) {
    on<FoodItemListLoad>((event, emit) {
      emit(const FoodItemListLoading([]));
      emit(FoodItemListLoaded([
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
      ]));
    });

    on<FoodItemListAdd>((event, emit) {
      final List<FoodItem> updatedFoodItems = List.from(state.foodItems)
        ..add(event.foodItem);
      emit(FoodItemListLoaded(updatedFoodItems));
    });
  }
}
