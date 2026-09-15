import 'package:flutter/material.dart';
import 'package:food_savior/generated/l10n.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/theme/app_tokens.dart';
import 'package:food_savior/theme/food_item_visuals.dart';
import 'package:food_savior/theme/food_status_colors.dart';
import 'package:food_savior/theme/localized_labels.dart';
import 'package:food_savior/widgets/app_line_icon.dart';

/// 狀態標籤。永遠同時有圖示與文字，不只靠顏色（design-system 規格）。
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status, this.dense = false});

  final FoodItemStatus status;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final colors = context.foodStatusColors;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? AppSpacing.sm : AppSpacing.md,
        vertical: dense ? 2 : AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.containerOf(status),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            FoodItemVisuals.statusIconOf(status),
            size: dense ? 12 : 14,
            color: colors.of(status),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            status.localizedName(context),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.of(status),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

/// 待補期限徽章。點一下就能補，這是它存在的理由（food-inventory 規格）。
class PendingExpiryBadge extends StatelessWidget {
  const PendingExpiryBadge({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.foodStatusColors;
    return Material(
      color: colors.unknownContainer,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppLineIcon(
                kind: AppLineIconKind.expiryUnknown,
                size: 14,
                color: colors.unknown,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                S.of(context).pendingExpiry,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colors.unknown,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
