import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/repositories/used_food_item_repository.dart';

part 'used_food_item_list_event.dart';
part 'used_food_item_list_state.dart';

/// 使用紀錄。點數在寫入端（[FoodItemListBloc]）就算好了，
/// 這裡只負責瀏覽、篩選、刪除與補記原因。
class UsedFoodItemListBloc
    extends Bloc<UsedFoodItemListEvent, UsedFoodItemListState> {
  UsedFoodItemListBloc({
    required this.usedFoodItemRepository,
    DateTime Function()? now,
  })  : _now = now ?? DateTime.now,
        super(const UsedFoodItemListInitial()) {
    on<UsedFoodItemListStarted>((event, emit) => emit(_loaded(_selectedDate)));
    on<UsedFoodItemListRefresh>((event, emit) => emit(_loaded(_selectedDate)));

    on<UsedFoodItemListLoadByDate>((event, emit) {
      _selectedDate = event.date;
      emit(_loaded(_selectedDate));
    });

    on<UsedFoodItemListFilterChanged>((event, emit) {
      _filter = event.filter;
      emit(_loaded(_selectedDate));
    });

    on<UsedFoodItemListRemove>((event, emit) async {
      await usedFoodItemRepository.deleteUsedFoodItem(event.id);
      emit(_loaded(_selectedDate));
    });

    on<UsedFoodItemListSetWasteReason>((event, emit) async {
      final item = usedFoodItemRepository.getUsedFoodItem(event.id);
      if (item == null) return;
      // 補記原因不改點數：使用者只是事後說明，行為本身沒有改變。
      await usedFoodItemRepository
          .saveUsedFoodItem(item.copyWith(wasteReason: event.wasteReason));
      emit(_loaded(_selectedDate));
    });

    on<UsedFoodItemListLoad>((event, emit) async {
      emit(const UsedFoodItemListLoading());
      await usedFoodItemRepository.clearAll();
      await usedFoodItemRepository.saveUsedFoodItems(event.usedFoodItems);
      emit(_loaded(_selectedDate));
    });

    on<UsedFoodItemListClear>((event, emit) async {
      emit(const UsedFoodItemListLoading());
      await usedFoodItemRepository.clearAll();
      emit(_loaded(_selectedDate));
    });

    _selectedDate = _now();
  }

  final UsedFoodItemRepository usedFoodItemRepository;
  final DateTime Function() _now;

  late DateTime _selectedDate;
  UsedFoodFilter _filter = UsedFoodFilter.all;

  UsedFoodItemListLoaded _loaded(DateTime date) {
    final items = usedFoodItemRepository.filterByDate(date)
      ..sort((a, b) => a.usedDate.compareTo(b.usedDate));
    return UsedFoodItemListLoaded(
      usedFoodItems: items.where(_matchesFilter).toList(),
      selectedDate: date,
      filter: _filter,
    );
  }

  bool _matchesFilter(UsedFoodItem item) => switch (_filter) {
        UsedFoodFilter.all => true,
        UsedFoodFilter.consumed => !item.isWaste,
        UsedFoodFilter.wasted => item.isWaste,
      };
}
