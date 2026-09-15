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
      usedFoodItemRepository.saveUsedFoodItems(event.usedFoodItems);
      emit(UsedFoodItemListLoaded(usedFoodItems: event.usedFoodItems));
    });

    on<UsedFoodItemListAdd>((event, emit) async {
      if (state is UsedFoodItemListLoaded) {
        emit(const UsedFoodItemListLoading());

        final existing = usedFoodItemRepository.getAllUsedFoodItems();
        final updatedItem = event.usedFoodItem.copyWith(
          affectFoodPoint: _pointFor(event.usedFoodItem, existing),
        );

        await usedFoodItemRepository.saveUsedFoodItem(updatedItem);
        emit(UsedFoodItemListLoaded(usedFoodItems: _allSortedByUsedDate()));
      }
    });

    // 批次新增（過期處理）：逐筆套用點數規則，前一筆計入後一筆的當日總和。
    // 還原流程請用 UsedFoodItemListLoad，它保留備份中的點數不重算。
    on<UsedFoodItemListAddAll>((event, emit) async {
      emit(const UsedFoodItemListLoading());

      final existing = usedFoodItemRepository.getAllUsedFoodItems();
      for (final usedFoodItem in event.usedFoodItems) {
        final updatedItem = usedFoodItem.copyWith(
          affectFoodPoint: _pointFor(usedFoodItem, existing),
        );
        await usedFoodItemRepository.saveUsedFoodItem(updatedItem);
        existing.add(updatedItem);
      }

      emit(UsedFoodItemListLoaded(usedFoodItems: _allSortedByUsedDate()));
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

    on<UsedFoodItemListClear>((event, emit) async {
      emit(const UsedFoodItemListLoading());

      await usedFoodItemRepository.clearAll();
      emit(const UsedFoodItemListLoaded(usedFoodItems: []));
    });

    on<UsedFoodItemListLoadByDate>((event, emit) {
      emit(const UsedFoodItemListLoading());
      final loadedUsedFoodItems =
          usedFoodItemRepository.filterByDate(event.date);
      emit(UsedFoodItemListLoaded(usedFoodItems: loadedUsedFoodItems));
    });

    add(UsedFoodItemListLoadFromDevice());
  }

  /// food-points：食用 +1、浪費 -1；同一日曆日既有點數總和已達 10 時，食用為 0。
  int _pointFor(UsedFoodItem item, List<UsedFoodItem> existing) {
    if (item.status != FoodItemStatus.consumed) return -1;
    final day = item.usedDate;
    final dailyTotal = existing
        .where((e) =>
            e.usedDate.year == day.year &&
            e.usedDate.month == day.month &&
            e.usedDate.day == day.day)
        .fold<int>(0, (sum, e) => sum + e.affectFoodPoint);
    return dailyTotal >= 10 ? 0 : 1;
  }

  List<UsedFoodItem> _allSortedByUsedDate() =>
      usedFoodItemRepository.getAllUsedFoodItems()
        ..sort((a, b) => a.usedDate.compareTo(b.usedDate));
}
