import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_savior/bloc/used_food_item_list/used_food_item_list_bloc.dart';
import 'package:food_savior/generated/l10n.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/statistics/monthly_trend.dart';

class ChartAndStatisticsPage extends StatefulWidget {
  const ChartAndStatisticsPage({super.key});

  @override
  State<ChartAndStatisticsPage> createState() => _ChartAndStatisticsPageState();
}

class _ChartAndStatisticsPageState extends State<ChartAndStatisticsPage> {
  List<MyPieChartData> _consumedFoodPointsData = [];
  List<MyPieChartData> _wastedFoodPointsData = [];
  List<MonthlyTrendPoint> _monthlyTrend = [];

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
              S.of(context).chartAndStatisticsPageTitle,
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
                          S.of(context).consumedFoodPointsByType,
                          _buildPieChart(_consumedFoodPointsData),
                        ),
                        _buildChartCard(
                          S.of(context).wastedFoodPointsByType,
                          _buildPieChart(_wastedFoodPointsData),
                        ),
                        _buildChartCard(
                          S.of(context).monthlyTrend,
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

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 12),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: availableWidth,
                  height: chartHeight,
                  child: chart,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPieChart(List<MyPieChartData> data) {
    if (data.isEmpty) {
      return Center(child: Text(S.of(context).noData));
    }
    return PieChart(
      PieChartData(
        sections: data
            .map(
              (data) => PieChartSectionData(
                value: data.value.toDouble(),
                color: data.type.color,
                title: '${data.type.localizedName(context)}\n(${data.value})',
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
    if (_monthlyTrend.isEmpty) {
      return Center(child: Text(S.of(context).noData));
    }
    // X 軸用索引，刻度文字取 yyyy/MM；點數多時每隔幾個才標，避免重疊
    final labelStep = (_monthlyTrend.length / 6).ceil();
    List<FlSpot> spots(int Function(MonthlyTrendPoint p) value) => [
          for (var i = 0; i < _monthlyTrend.length; i++)
            FlSpot(i.toDouble(), value(_monthlyTrend[i]).toDouble()),
        ];
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        minX: 0,
        maxX: (_monthlyTrend.length - 1).clamp(1, 1 << 20).toDouble(),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 32),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.round();
                final isTick = (value - index).abs() < 0.001;
                final inRange = index >= 0 && index < _monthlyTrend.length;
                final isLast = index == _monthlyTrend.length - 1;
                if (!isTick ||
                    !inRange ||
                    (index % labelStep != 0 && !isLast)) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    _monthlyTrend[index].label,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots((p) => p.consumed),
            color: Colors.green,
            barWidth: 2,
            dotData: FlDotData(show: true),
          ),
          LineChartBarData(
            spots: spots((p) => p.wasted),
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
    // statistics-charts：年月粒度、補 0、最近 12 個月（純函式，可測試）
    _monthlyTrend = monthlyTrend(usedFoodItems);
  }
}

class MyPieChartData {
  final int value;
  final FoodItemType type;

  MyPieChartData(this.value, this.type);
}
