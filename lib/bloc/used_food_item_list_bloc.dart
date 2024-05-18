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

    on<UsedFoodItemListLoad>((event, emit) async {
      await SharedPreferences.getInstance().then((prefs) {
        prefs.setStringList(
          'usedFoodItems',
          event.usedFoodItems.map((foodItem) => foodItem.toJson()).toList(),
        );
      });

      emit(UsedFoodItemListLoaded(usedFoodItems: event.usedFoodItems));
    });

    on<UsedFoodItemListAdd>((event, emit) async {
      if (state is UsedFoodItemListLoaded) {
        final List<UsedFoodItem> currentfoodItems =
            (state as UsedFoodItemListLoaded).usedFoodItems;
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

        final List<UsedFoodItem> updatedUsedFoodItems =
            List.from(currentfoodItems)
              ..add(event.usedFoodItem.copyWith(
                id: event.usedFoodItem.id,
                affectFoodPoint:
                    event.usedFoodItem.status == FoodItemStatus.consumed
                        ? consumedDateFoodPoint >= 10
                            ? 0
                            : 1
                        : -1,
              ))
              ..sort((a, b) => a.usedDate.compareTo(b.usedDate));

        // 將新增的使用過食物存到 shared preferences
        await SharedPreferences.getInstance().then((prefs) {
          prefs.setStringList(
            'usedFoodItems',
            updatedUsedFoodItems
                .map((usedFoodItem) => usedFoodItem.toJson())
                .toList(),
          );
        });

        emit(UsedFoodItemListLoaded(usedFoodItems: updatedUsedFoodItems));
      }
    });

    on<UsedFoodItemListAddMultiple>((event, emit) async {
      if (state is UsedFoodItemListLoaded) {
        final List<UsedFoodItem> currentfoodItems =
            (state as UsedFoodItemListLoaded).usedFoodItems;
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

        updatedUsedFoodItems.sort((a, b) => a.usedDate.compareTo(b.usedDate));

        // 將新增的使用過食物存到 shared preferences
        await SharedPreferences.getInstance().then((prefs) {
          prefs.setStringList(
            'usedFoodItems',
            updatedUsedFoodItems
                .map((usedFoodItem) => usedFoodItem.toJson())
                .toList(),
          );
        });

        emit(UsedFoodItemListLoaded(usedFoodItems: updatedUsedFoodItems));
      }
    });

    on<UsedFoodItemListRemove>((event, emit) async {
      if (state is UsedFoodItemListLoaded) {
        final List<UsedFoodItem> currentfoodItems =
            (state as UsedFoodItemListLoaded).usedFoodItems;
        emit(const UsedFoodItemListLoading());

        final List<UsedFoodItem> updatedUsedFoodItems =
            List.from(currentfoodItems)
              ..removeWhere((element) => element == event.usedFoodItem);

        // 將刪除的使用過食物存到 shared preferences
        await SharedPreferences.getInstance().then((prefs) {
          prefs.setStringList(
            'usedFoodItems',
            updatedUsedFoodItems
                .map((usedFoodItem) => usedFoodItem.toJson())
                .toList(),
          );
        });

        emit(UsedFoodItemListLoaded(usedFoodItems: updatedUsedFoodItems));
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
