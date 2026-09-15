import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_savior/models/food_points_summary.dart';
import 'package:food_savior/repositories/used_food_item_repository.dart';

/// 用戶頁的成績。每次進頁面重算，不快取也不持久化（design D1）。
class FoodPointsCubit extends Cubit<FoodPointsSummary> {
  FoodPointsCubit({
    required this.usedFoodItemRepository,
    DateTime Function()? now,
  })  : _now = now ?? DateTime.now,
        super(FoodPointsSummary.empty) {
    refresh();
  }

  final UsedFoodItemRepository usedFoodItemRepository;
  final DateTime Function() _now;

  void refresh() {
    emit(FoodPointsSummary.from(
      usedFoodItemRepository.getAllUsedFoodItems(),
      now: _now(),
    ));
  }
}
