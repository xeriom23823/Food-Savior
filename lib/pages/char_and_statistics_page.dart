import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_savior/cubits/statistics_cubit.dart';
import 'package:food_savior/generated/l10n.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/repositories/used_food_item_repository.dart';
import 'package:food_savior/statistics/food_statistics.dart';
import 'package:food_savior/statistics/monthly_trend.dart';
import 'package:food_savior/theme/app_tokens.dart';
import 'package:food_savior/theme/app_assets.dart';
import 'package:food_savior/theme/food_status_colors.dart';
import 'package:food_savior/theme/localized_labels.dart';
import 'package:food_savior/widgets/app_scaffold.dart';
import 'package:food_savior/widgets/empty_state.dart';
import 'package:food_savior/widgets/section_header.dart';

/// 圖表頁。圓餅圖以「筆數」計量：點數加權後，點數佔比不再等於行為佔比。
class ChartAndStatisticsPage extends StatelessWidget {
  const ChartAndStatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StatisticsCubit(
        usedFoodItemRepository: context.read<UsedFoodItemRepository>(),
      ),
      child: const _ChartAndStatisticsView(),
    );
  }
}

class _ChartAndStatisticsView extends StatelessWidget {
  const _ChartAndStatisticsView();

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);

    return BlocBuilder<StatisticsCubit, StatisticsState>(
      builder: (context, state) {
        return AppScaffold(
          title: strings.chartAndStatisticsPageTitle,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => context.read<StatisticsCubit>().refresh(),
            ),
          ],
          body: !state.hasRecords
              ? EmptyState(
                  icon: Icons.insert_chart_outlined,
                  illustrationAsset: AppAssets.emptyStatistics,
                  title: strings.noData,
                )
              : ListView(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                  children: [
                    SectionHeader(title: strings.consumedFoodByType),
                    _card(_TypePie(counts: state.consumedByType)),
                    SectionHeader(title: strings.wastedFoodByType),
                    _card(_TypePie(counts: state.wastedByType)),
                    SectionHeader(title: strings.monthlyTrend),
                    _card(_MonthlyTrendChart(points: state.monthly)),
                    SectionHeader(title: strings.statisticsWasteRate),
                    _card(_WasteRateChart(points: state.wasteRate)),
                    SectionHeader(title: strings.statisticsTopWasted),
                    _card(_TopWastedList(ranks: state.topWasted)),
                    SectionHeader(title: strings.statisticsWasteReasons),
                    _card(_WasteReasonList(counts: state.wasteReasons)),
                    SectionHeader(title: strings.statisticsMoney),
                    _card(_MoneyCard(summary: state.money)),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 14,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              strings.pointsRuleChanged,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _card(Widget child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: child,
          ),
        ),
      );
}

class _TypePie extends StatelessWidget {
  const _TypePie({required this.counts});

  final Map<FoodItemType, int> counts;

  @override
  Widget build(BuildContext context) {
    if (counts.isEmpty) return _NoData();

    final scheme = Theme.of(context).colorScheme;
    final palette = <Color>[
      scheme.primary,
      scheme.tertiary,
      scheme.secondary,
      scheme.primaryContainer,
      scheme.tertiaryContainer,
      scheme.secondaryContainer,
      scheme.outline,
    ];
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: [
                for (var index = 0; index < entries.length; index++)
                  PieChartSectionData(
                    value: entries[index].value.toDouble(),
                    title: '${entries[index].value}',
                    color: palette[index % palette.length],
                    radius: 48,
                    titleStyle: Theme.of(context).textTheme.labelSmall,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.xs,
          children: [
            for (var index = 0; index < entries.length; index++)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: palette[index % palette.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    entries[index].key.localizedName(context),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

/// 月點數趨勢（statistics-charts 主規格）：食用與浪費兩條線。
class _MonthlyTrendChart extends StatelessWidget {
  const _MonthlyTrendChart({required this.points});

  final List<MonthlyTrendPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return _NoData();
    final colors = context.foodStatusColors;

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 44),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= points.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      points[index].label,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              isCurved: false,
              color: colors.fresh,
              barWidth: 2,
              spots: [
                for (var index = 0; index < points.length; index++)
                  FlSpot(index.toDouble(), points[index].consumed.toDouble()),
              ],
            ),
            LineChartBarData(
              isCurved: false,
              color: colors.expired,
              barWidth: 2,
              spots: [
                for (var index = 0; index < points.length; index++)
                  FlSpot(index.toDouble(), points[index].wasted.toDouble()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WasteRateChart extends StatelessWidget {
  const _WasteRateChart({required this.points});

  final List<WasteRatePoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return _NoData();
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 100,
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 52,
                interval: 25,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt()}%',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= points.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      points[index].label,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              isCurved: false,
              color: scheme.error,
              barWidth: 2,
              spots: [
                for (var index = 0; index < points.length; index++)
                  FlSpot(index.toDouble(), points[index].rate * 100),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TopWastedList extends StatelessWidget {
  const _TopWastedList({required this.ranks});

  final List<WastedFoodRank> ranks;

  @override
  Widget build(BuildContext context) {
    if (ranks.isEmpty) return _NoData();
    final strings = S.of(context);

    return Column(
      children: [
        for (final rank in ranks)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(child: Text(rank.name)),
                Text(
                  strings.wastedCountLabel(rank.count),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                if (rank.totalPrice != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    strings.priceLabel(rank.totalPrice!),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: context.foodStatusColors.expired,
                        ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _WasteReasonList extends StatelessWidget {
  const _WasteReasonList({required this.counts});

  final Map<WasteReason?, int> counts;

  @override
  Widget build(BuildContext context) {
    if (counts.isEmpty) return _NoData();
    final strings = S.of(context);
    final total = counts.values.fold<int>(0, (sum, value) => sum + value);
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        for (final entry in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                SizedBox(
                  width: 110,
                  child: Text(
                    entry.key?.localizedName(context) ?? strings.noWasteReason,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: LinearProgressIndicator(
                      value: total == 0 ? 0 : entry.value / total,
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '${entry.value}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _MoneyCard extends StatelessWidget {
  const _MoneyCard({required this.summary});

  final MoneySummary summary;

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);
    final colors = context.foodStatusColors;

    if (!summary.hasData) {
      return Column(
        children: [
          _NoData(),
          const SizedBox(height: AppSpacing.sm),
          Text(
            strings.addPriceHint,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(strings.moneySaved, style: theme.textTheme.labelMedium),
                  Text(
                    strings.priceLabel(summary.saved),
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(color: colors.fresh),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(strings.moneyLost, style: theme.textTheme.labelMedium),
                  Text(
                    strings.priceLabel(summary.lost),
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(color: colors.expired),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          strings.coverageLabel((summary.coverage * 100).round()),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _NoData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Center(
        child: Text(
          S.of(context).noData,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}
