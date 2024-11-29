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
  List<MyPieChartData> _consumedFoodPointsData = [];
  List<MyPieChartData> _wastedFoodPointsData = [];
  List<FlSpot> _monthlyConsumedTrend = [];
  List<FlSpot> _monthlyWastedTrend = [];

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
          _getMonthlyTrendData(state.usedFoodItems);
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
              ? SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      children: [
                        _buildChartCard(
                          '食物點數消耗統計',
                          _buildPieChart(_consumedFoodPointsData),
                        ),
                        _buildChartCard(
                          '食物點數浪費統計',
                          _buildPieChart(_wastedFoodPointsData),
                        ),
                        _buildChartCard(
                          '每月趨勢',
                          _buildLineChart(),
                        ),
                      ],
                    ),
                  ),
                )
              : const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final chartHeight = availableWidth * 0.6;

        return Container(
          width: availableWidth,
          height: chartHeight,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: chart,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPieChart(List<MyPieChartData> data) {
    if (data.isEmpty) {
      return const Center(child: Text('尚無資料'));
    }
    return PieChart(
      PieChartData(
        sections: data
            .map(
              (data) => PieChartSectionData(
                value: data.value.toDouble(),
                color: data.type.color,
                title: '${data.type.name(context)}\n(${data.value})',
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                radius: 80, // 增加半徑
                titlePositionPercentageOffset: 0.6, // 調整文字位置
              ),
            )
            .toList(),
        centerSpaceRadius: 0, // 移除中心空白
        sectionsSpace: 2, // 添加間距
      ),
    );
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: _monthlyConsumedTrend,
            color: Colors.green,
            barWidth: 2,
            dotData: FlDotData(show: true),
          ),
          LineChartBarData(
            spots: _monthlyWastedTrend,
            color: Colors.red,
            barWidth: 2,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  void _getPieChartData(List<UsedFoodItem> usedFoodItems) {
    final Map<FoodItemType, int> consumedTypeCount = {};
    final Map<FoodItemType, int> wastedTypeCount = {};
    for (var element in usedFoodItems) {
      if (element.status == FoodItemStatus.consumed) {
        consumedTypeCount[element.type] =
            (consumedTypeCount[element.type] ?? 0) + element.affectFoodPoint;
      } else if (element.status == FoodItemStatus.wasted) {
        wastedTypeCount[element.type] =
            (wastedTypeCount[element.type] ?? 0) - element.affectFoodPoint;
      }
    }

    _consumedFoodPointsData = consumedTypeCount.entries
        .map((entry) => MyPieChartData(entry.value, entry.key))
        .toList();

    _wastedFoodPointsData = wastedTypeCount.entries
        .map((entry) => MyPieChartData(entry.value, entry.key))
        .toList();
  }

  void _getMonthlyTrendData(List<UsedFoodItem> usedFoodItems) {
    final Map<int, int> consumedByMonth = {};
    final Map<int, int> wastedByMonth = {};

    for (var item in usedFoodItems) {
      final monthKey = item.usedDate.month;
      if (item.status == FoodItemStatus.consumed) {
        consumedByMonth[monthKey] =
            (consumedByMonth[monthKey] ?? 0) + item.affectFoodPoint;
      } else if (item.status == FoodItemStatus.wasted) {
        wastedByMonth[monthKey] =
            (wastedByMonth[monthKey] ?? 0) + item.affectFoodPoint;
      }
    }

    _monthlyConsumedTrend = consumedByMonth.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
        .toList();
    _monthlyWastedTrend = wastedByMonth.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
        .toList();
  }
}

class MyPieChartData {
  final int value;
  final FoodItemType type;

  MyPieChartData(this.value, this.type);
}
