import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/repositories/used_food_item_repository.dart';
import 'package:food_savior/statistics/food_statistics.dart';
import 'package:food_savior/statistics/monthly_trend.dart';

class StatisticsState extends Equatable {
  const StatisticsState({
    this.consumedByType = const {},
    this.wastedByType = const {},
    this.monthly = const [],
    this.wasteRate = const [],
    this.topWasted = const [],
    this.wasteReasons = const {},
    this.money = const MoneySummary(saved: 0, lost: 0, withPrice: 0, total: 0),
    this.hasRecords = false,
  });

  final Map<FoodItemType, int> consumedByType;
  final Map<FoodItemType, int> wastedByType;
  final List<MonthlyTrendPoint> monthly;
  final List<WasteRatePoint> wasteRate;
  final List<WastedFoodRank> topWasted;
  final Map<WasteReason?, int> wasteReasons;
  final MoneySummary money;
  final bool hasRecords;

  @override
  List<Object?> get props => [
        consumedByType,
        wastedByType,
        monthly,
        wasteRate,
        topWasted,
        wasteReasons,
        money,
        hasRecords,
      ];
}

/// 統計頁的資料來源。圖表只吃算好的結果，頁面不做任何彙總。
class StatisticsCubit extends Cubit<StatisticsState> {
  StatisticsCubit({required this.usedFoodItemRepository})
      : super(const StatisticsState()) {
    refresh();
  }

  final UsedFoodItemRepository usedFoodItemRepository;

  void refresh() {
    final items = usedFoodItemRepository.getAllUsedFoodItems();
    emit(StatisticsState(
      consumedByType: countByType(items, waste: false),
      wastedByType: countByType(items, waste: true),
      monthly: monthlyTrend(items),
      wasteRate: wasteRateTrend(items),
      topWasted: topWastedFoods(items),
      wasteReasons: wasteReasonBreakdown(items),
      money: moneySummary(items),
      hasRecords: items.isNotEmpty,
    ));
  }
}
