import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_savior/bloc/used_food_item_list/used_food_item_list_bloc.dart';
import 'package:food_savior/models/food_item.dart';

class ChartAndStatisticsPage extends StatefulWidget {
  const ChartAndStatisticsPage({super.key});

  @override
  State<ChartAndStatisticsPage> createState() => _ChartAndStatisticsPageState();
}

class _ChartAndStatisticsPageState extends State<ChartAndStatisticsPage> {
  List<MyPieChartData> _comsumedFoodPointsData = [];
  List<MyPieChartData> _wastedFoodPointsData = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsedFoodItemListBloc, UsedFoodItemListState>(
      builder: (context, state) {
        if (state is UsedFoodItemListLoaded) {
          _getPieChartData(state.usedFoodItems);
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(
              '圖表與統計',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: state is UsedFoodItemListLoaded
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          border: Border.all(),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              '食物點數消耗統計',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_comsumedFoodPointsData.isNotEmpty) ...[
                              SizedBox(
                                height: 200,
                                width: 200,
                                child: PieChart(
                                  PieChartData(
                                    sections: _comsumedFoodPointsData
                                        .map(
                                          (data) => PieChartSectionData(
                                            value: data.value.toDouble(),
                                            color: data.type.color,
                                            title:
                                                '${data.type.name(context)} (${data.value})',
                                            titleStyle: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            radius: 30,
                                          ),
                                        )
                                        .toList(),
                                    centerSpaceRadius: 70,
                                  ),
                                ),
                              ),
                            ] else ...[
                              const SizedBox(
                                height: 200,
                                width: 200,
                                child: Center(child: Text('尚未有食物點數消耗紀錄')),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          border: Border.all(),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              '食物點數浪費統計',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_wastedFoodPointsData.isNotEmpty) ...[
                              SizedBox(
                                height: 200,
                                width: 200,
                                child: PieChart(
                                  PieChartData(
                                    sections: _wastedFoodPointsData
                                        .map(
                                          (data) => PieChartSectionData(
                                            value: data.value.toDouble(),
                                            color: data.type.color,
                                            title:
                                                '${data.type.name(context)} (${data.value})',
                                            titleStyle: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            radius: 30,
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                              ),
                            ] else ...[
                              const SizedBox(
                                height: 200,
                                width: 200,
                                child: Center(child: Text('尚未有食物點數浪費紀錄')),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        );
      },
    );
  }

  void _getPieChartData(List<UsedFoodItem> usedFoodItems) {
    final Map<FoodItemType, int> comsumedTypeCount = {};
    final Map<FoodItemType, int> wastedTypeCount = {};
    for (var element in usedFoodItems) {
      if (element.status == FoodItemStatus.consumed) {
        comsumedTypeCount[element.type] =
            (comsumedTypeCount[element.type] ?? 0) + element.affectFoodPoint;
      } else if (element.status == FoodItemStatus.wasted) {
        wastedTypeCount[element.type] =
            (wastedTypeCount[element.type] ?? 0) - element.affectFoodPoint;
      }
    }

    _comsumedFoodPointsData = comsumedTypeCount.entries
        .map((entry) => MyPieChartData(entry.value, entry.key))
        .toList();

    _wastedFoodPointsData = wastedTypeCount.entries
        .map((entry) => MyPieChartData(entry.value, entry.key))
        .toList();
  }
}

class MyPieChartData {
  final int value;
  final FoodItemType type;

  MyPieChartData(this.value, this.type);
}
