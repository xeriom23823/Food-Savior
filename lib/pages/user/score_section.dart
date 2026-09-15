import 'package:flutter/material.dart';
import 'package:food_savior/generated/l10n.dart';
import 'package:food_savior/models/food_points_summary.dart';
import 'package:food_savior/theme/app_tokens.dart';
import 'package:food_savior/theme/food_status_colors.dart';
import 'package:food_savior/theme/points_labels.dart';

/// 等級卡：等級名稱、進度條、距離下一級還差多少。
class LevelCard extends StatelessWidget {
  const LevelCard({super.key, required this.summary});

  final FoodPointsSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = S.of(context);
    final toNext = summary.pointsToNextLevel;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    '${summary.level.index + 1}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    summary.level.localizedName(context),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: LinearProgressIndicator(
                value: summary.levelProgress,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              toNext == null
                  ? strings.maxLevelReached
                  : strings.pointsToNextLevel(toNext),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 三個數字：累計、本週、距上次浪費。
class PointsStatRow extends StatelessWidget {
  const PointsStatRow({super.key, required this.summary});

  final FoodPointsSummary summary;

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final colors = context.foodStatusColors;
    final days = summary.daysSinceLastWaste;

    return Row(
      children: [
        Expanded(
          child: _Stat(
            label: strings.totalPoints,
            value: strings.signedPoints(summary.totalPoints),
            color: summary.totalPoints >= 0 ? colors.fresh : colors.expired,
          ),
        ),
        Expanded(
          child: _Stat(
            label: strings.weeklyNet,
            value: strings.signedPoints(summary.weeklyNet),
            color: summary.weeklyNet >= 0 ? colors.fresh : colors.expired,
          ),
        ),
        if (days != null)
          Expanded(
            child: _Stat(
              label: strings.daysSinceLastWaste,
              value: strings.daysCount(days),
            ),
          ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// 里程碑清單。未達成的用灰階 + 條件文字，不隱藏（design D4）。
class MilestoneList extends StatelessWidget {
  const MilestoneList({super.key, required this.summary});

  final FoodPointsSummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          for (final milestone in PointsMilestone.values)
            _MilestoneTile(
              milestone: milestone,
              achieved: summary.isAchieved(milestone),
              isLast: milestone == PointsMilestone.values.last,
            ),
        ],
      ),
    );
  }
}

class _MilestoneTile extends StatelessWidget {
  const _MilestoneTile({
    required this.milestone,
    required this.achieved,
    required this.isLast,
  });

  final PointsMilestone milestone;
  final bool achieved;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground =
        achieved ? theme.colorScheme.onSurface : theme.colorScheme.outline;

    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: achieved
                ? theme.colorScheme.secondaryContainer
                : theme.colorScheme.surfaceContainerHighest,
            child: Icon(
              milestone.icon,
              size: 20,
              color: achieved
                  ? theme.colorScheme.onSecondaryContainer
                  : theme.colorScheme.outline,
            ),
          ),
          title: Text(
            milestone.localizedName(context),
            style: theme.textTheme.titleSmall?.copyWith(color: foreground),
          ),
          subtitle: Text(
            milestone.localizedCondition(context),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          trailing: achieved
              ? Icon(Icons.check_circle, color: context.foodStatusColors.fresh)
              : null,
        ),
        if (!isLast) const Divider(height: 1, indent: AppSpacing.lg),
      ],
    );
  }
}
