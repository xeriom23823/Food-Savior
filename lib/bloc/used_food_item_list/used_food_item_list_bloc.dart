import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/repositories/used_food_item_repository.dart';

part 'used_food_item_list_event.dart';
part 'used_food_item_list_state.dart';

class UsedFoodItemListBloc
    extends Bloc<UsedFoodItemListEvent, UsedFoodItemListState> {
  final UsedFoodItemRepository usedFoodItemRepository;
  UsedFoodItemListBloc({required this.usedFoodItemRepository})
      : super(const UsedFoodItemListInitial()) {
    on<UsedFoodItemListLoadFromDevice>((event, emit) async {
      emit(const UsedFoodItemListLoading());
      final loadedUsedFoodItems = usedFoodItemRepository.getAllUsedFoodItems();
      emit(UsedFoodItemListLoaded(usedFoodItems: loadedUsedFoodItems));
    });

    on<UsedFoodItemListLoad>((event, emit) async {
      for (var item in event.usedFoodItems) {
        await usedFoodItemRepository.saveUsedFoodItem(item);
      }
      emit(UsedFoodItemListLoaded(usedFoodItems: event.usedFoodItems));
    });

    on<UsedFoodItemListAdd>((event, emit) async {
      if (state is UsedFoodItemListLoaded) {
        final List<UsedFoodItem> currentfoodItems =
            usedFoodItemRepository.getAllUsedFoodItems();
        emit(const UsedFoodItemListLoading());

        // 確認當日的食物點數是否已經達到上限
        final consumedDate = event.usedFoodItem.usedDate;
        int consumedDateFoodPoint = 0;
        for (var foodItem in currentfoodItems) {
          if (foodItem.usedDate.year == consumedDate.year &&
              foodItem.usedDate.month == consumedDate.month &&
              foodItem.usedDate.day == consumedDate.day) {
            consumedDateFoodPoint += foodItem.affectFoodPoint;
          }
        }

        final updatedItem = event.usedFoodItem.copyWith(
          id: event.usedFoodItem.id,
          affectFoodPoint: event.usedFoodItem.status == FoodItemStatus.consumed
              ? consumedDateFoodPoint >= 10
                  ? 0
                  : 1
              : -1,
        );

        await usedFoodItemRepository.saveUsedFoodItem(updatedItem);
        final updatedUsedFoodItems = usedFoodItemRepository
            .getAllUsedFoodItems()
          ..sort((a, b) => a.usedDate.compareTo(b.usedDate));

        emit(UsedFoodItemListLoaded(usedFoodItems: updatedUsedFoodItems));
      }
    });

    on<UsedFoodItemListAddMultiple>((event, emit) async {
      if (state is UsedFoodItemListLoaded) {
        final List<UsedFoodItem> currentfoodItems =
            usedFoodItemRepository.getAllUsedFoodItems();
        emit(const UsedFoodItemListLoading());

        // 確認當日的食物點數是否已經達到上限並添加至使用過食物列表
        List<UsedFoodItem> updatedUsedFoodItems = [];
        for (var usedFoodItem in event.usedFoodItems) {
          final consumedDate = usedFoodItem.usedDate;
          int consumedDateFoodPoint = 0;
          for (var foodItem in currentfoodItems) {
            if (foodItem.usedDate.year == consumedDate.year &&
                foodItem.usedDate.month == consumedDate.month &&
                foodItem.usedDate.day == consumedDate.day) {
              consumedDateFoodPoint += foodItem.affectFoodPoint;
            }
          }

          updatedUsedFoodItems.add(usedFoodItem.copyWith(
            id: usedFoodItem.id,
            affectFoodPoint: usedFoodItem.status == FoodItemStatus.consumed
                ? consumedDateFoodPoint >= 10
                    ? 0
                    : 1
                : -1,
          ));
        }

        for (var item in updatedUsedFoodItems) {
          await usedFoodItemRepository.saveUsedFoodItem(item);
        }

        final finalUsedFoodItems = usedFoodItemRepository.getAllUsedFoodItems()
          ..sort((a, b) => a.usedDate.compareTo(b.usedDate));

        emit(UsedFoodItemListLoaded(usedFoodItems: finalUsedFoodItems));
      }
    });

    on<UsedFoodItemListRemove>((event, emit) async {
      if (state is UsedFoodItemListLoaded) {
        emit(const UsedFoodItemListLoading());

        await usedFoodItemRepository.deleteUsedFoodItem(event.usedFoodItem.id);
        final updatedUsedFoodItems =
            usedFoodItemRepository.getAllUsedFoodItems();

        emit(UsedFoodItemListLoaded(usedFoodItems: updatedUsedFoodItems));
      }
    });

    on<UsedFoodItemListUpdate>((event, emit) async {
      if (state is UsedFoodItemListLoaded) {
        emit(const UsedFoodItemListLoading());

        await usedFoodItemRepository
            .saveUsedFoodItem(event.updatedUsedFoodItem);
        final updatedUsedFoodItems = usedFoodItemRepository
            .getAllUsedFoodItems()
          ..sort((a, b) => a.usedDate.compareTo(b.usedDate));

        emit(UsedFoodItemListLoaded(usedFoodItems: updatedUsedFoodItems));
      }
    });

    add(UsedFoodItemListLoadFromDevice());
  }
}
