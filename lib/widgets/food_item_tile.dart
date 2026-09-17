import 'package:flutter/material.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/theme/app_tokens.dart';
import 'package:food_savior/theme/food_status_colors.dart';
import 'package:food_savior/widgets/amount_label.dart';
import 'package:food_savior/widgets/expiry_countdown.dart';
import 'package:food_savior/widgets/food_type_icon.dart';
import 'package:food_savior/widgets/status_chip.dart';

/// 單一食物列。清單、過期處理頁、批次展開都用這一個元件。
class FoodItemTile extends StatelessWidget {
  const FoodItemTile({
    super.key,
    required this.item,
    required this.now,
    this.locationName,
    this.onTap,
    this.onFillExpiry,
    this.trailing,
    this.dense = false,
  });

  final FoodItem item;
  final DateTime now;
  final String? locationName;
  final VoidCallback? onTap;
  final VoidCallback? onFillExpiry;
  final Widget? trailing;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = item.statusAt(now);
    final statusColor = context.foodStatusColors.of(status);

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.card,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: dense ? AppSpacing.sm : AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: dense ? 32 : 40,
              height: dense ? 32 : 40,
              decoration: BoxDecoration(
                color: context.foodStatusColors.containerOf(status),
                shape: BoxShape.circle,
              ),
              child: FoodTypeIcon(
                type: item.type,
                size: dense ? 16 : 20,
                color: statusColor,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.name,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      if (item.isOpened) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Icon(Icons.lock_open,
                            size: 12, color: theme.colorScheme.outline),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      AmountLabel.of(
                        item,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (locationName != null) ...[
                        Text(
                          ' · ',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            locationName!,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            if (trailing != null)
              trailing!
            else if (item.needsExpiryCompletion)
              PendingExpiryBadge(onTap: onFillExpiry)
            else
              ExpiryCountdown(item: item, now: now, compact: true),
          ],
        ),
      ),
    );
  }
}
