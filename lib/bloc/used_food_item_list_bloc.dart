import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'used_food_item_list_event.dart';
part 'used_food_item_list_state.dart';

class UsedFoodItemListBloc
    extends Bloc<UsedFoodItemListEvent, UsedFoodItemListState> {
  UsedFoodItemListBloc() : super(const UsedFoodItemListInitial()) {
    on<UsedFoodItemListLoadFromDevice>((event, emit) async {
      emit(const UsedFoodItemListLoading());

      // 若 shared preferences 有使用過食物資料，則讀取並顯示
      List<UsedFoodItem> loadedUsedFoodItems =
          await SharedPreferences.getInstance().then(
        (prefs) {
          final List<String> usedFoodItemsJson =
              prefs.getStringList('usedFoodItems') ?? [];
          return usedFoodItemsJson
              .map((usedFoodItemsJson) =>
                  UsedFoodItem.fromJson(usedFoodItemsJson))
              .toList();
        },
      );

      if (loadedUsedFoodItems.isEmpty) {
        emit(const UsedFoodItemListLoaded(usedFoodItems: []));
        return;
      }

      emit(UsedFoodItemListLoaded(usedFoodItems: loadedUsedFoodItems));
    });

    on<UsedFoodItemListAdd>((event, emit) {
      if (state is UsedFoodItemListLoaded) {
        final List<UsedFoodItem> currentfoodItems =
            (state as UsedFoodItemListLoaded).usedFoodItems;
        emit(const UsedFoodItemListLoading());

        final List<UsedFoodItem> updatedUsedFoodItems =
            List.from(currentfoodItems)
              ..add(event.usedFoodItem)
              ..sort((a, b) => a.usedDate.compareTo(b.usedDate));
        emit(UsedFoodItemListLoaded(usedFoodItems: updatedUsedFoodItems));

        // 將新增的使用過食物存到 shared preferences
        SharedPreferences.getInstance().then((prefs) {
          prefs.setStringList(
            'usedFoodItems',
            updatedUsedFoodItems
                .map((usedFoodItem) => usedFoodItem.toJson())
                .toList(),
          );
        });
      }
    });

    on<UsedFoodItemListRemove>((event, emit) {
      if (state is UsedFoodItemListLoaded) {
        final List<UsedFoodItem> currentfoodItems =
            (state as UsedFoodItemListLoaded).usedFoodItems;
        emit(const UsedFoodItemListLoading());

        final List<UsedFoodItem> updatedUsedFoodItems =
            List.from(currentfoodItems)
              ..removeWhere((element) => element == event.usedFoodItem);
        emit(UsedFoodItemListLoaded(usedFoodItems: updatedUsedFoodItems));

        // 將刪除的使用過食物存到 shared preferences
        SharedPreferences.getInstance().then((prefs) {
          prefs.setStringList(
            'usedFoodItems',
            updatedUsedFoodItems
                .map((usedFoodItem) => usedFoodItem.toJson())
                .toList(),
          );
        });
      }
    });

    on<UsedFoodItemListUpdate>((event, emit) {
      if (state is UsedFoodItemListLoaded) {
        final List<UsedFoodItem> currentfoodItems =
            (state as UsedFoodItemListLoaded).usedFoodItems;
        emit(const UsedFoodItemListLoading());

        final List<UsedFoodItem> updatedUsedFoodItems =
            List.from(currentfoodItems)
              ..removeWhere((element) => element == event.originalUsedFoodItem)
              ..add(event.updatedUsedFoodItem)
              ..sort((a, b) => a.usedDate.compareTo(b.usedDate));
        emit(UsedFoodItemListLoaded(usedFoodItems: updatedUsedFoodItems));

        // 將更新的使用過食物存到 shared preferences
        SharedPreferences.getInstance().then((prefs) {
          prefs.setStringList(
            'usedFoodItems',
            updatedUsedFoodItems
                .map((usedFoodItem) => usedFoodItem.toJson())
                .toList(),
          );
        });
      }
    });

    add(UsedFoodItemListLoadFromDevice());
  }
}
