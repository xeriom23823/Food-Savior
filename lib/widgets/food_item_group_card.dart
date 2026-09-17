import 'package:flutter/material.dart';
import 'package:food_savior/generated/l10n.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/models/food_item_group.dart';
import 'package:food_savior/theme/app_tokens.dart';
import 'package:food_savior/theme/food_status_colors.dart';
import 'package:food_savior/widgets/amount_label.dart';
import 'package:food_savior/widgets/expiry_countdown.dart';
import 'package:food_savior/widgets/food_item_tile.dart';
import 'package:food_savior/widgets/food_type_icon.dart';
import 'package:food_savior/widgets/status_chip.dart';

/// 合併卡片：同名同位置同單位的多批食物收合成一張（design D18）。
///
/// 單筆時退化成一般的 [FoodItemTile]，使用者不會看到多餘的展開箭頭。
class FoodItemGroupCard extends StatefulWidget {
  const FoodItemGroupCard({
    super.key,
    required this.group,
    required this.now,
    this.locationName,
    this.onTapItem,
    this.onFillExpiry,
  });

  final FoodItemGroup group;
  final DateTime now;
  final String? locationName;
  final void Function(FoodItem item)? onTapItem;
  final void Function(FoodItem item)? onFillExpiry;

  @override
  State<FoodItemGroupCard> createState() => _FoodItemGroupCardState();
}

class _FoodItemGroupCardState extends State<FoodItemGroupCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final group = widget.group;

    if (group.isSingle) {
      return FoodItemTile(
        item: group.first,
        now: widget.now,
        locationName: widget.locationName,
        onTap: () => widget.onTapItem?.call(group.first),
        onFillExpiry: () => widget.onFillExpiry?.call(group.first),
      );
    }

    final theme = Theme.of(context);
    final status = group.statusAt(widget.now);
    final colors = context.foodStatusColors;
    final total = group.totalAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: AppRadius.card,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.containerOf(status),
                    shape: BoxShape.circle,
                  ),
                  child: FoodTypeIcon(
                    type: group.type,
                    size: 20,
                    color: colors.of(status),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            total == null
                                ? ''
                                : AmountLabel.format(
                                    context,
                                    amount: total,
                                    unit: group.unit,
                                  ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            ' · ${S.of(context).batchCount(group.items.length)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                if (group.hasPendingExpiry && group.earliestExpiry == null)
                  const PendingExpiryBadge()
                else
                  ExpiryCountdown(
                    item: group.first,
                    now: widget.now,
                    compact: true,
                  ),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  color: theme.colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
        // 收合時不建立批次列：一張卡可能有十幾批，沒必要先蓋好再藏起來。
        // 使用者關閉系統動畫時直接跳到結果，不做展開動畫。
        AnimatedSize(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : AppDurations.short,
          curve: AppDurations.curve,
          alignment: Alignment.topCenter,
          child: _expanded
              ? Column(
                  children: [
                    const Divider(
                        indent: AppSpacing.lg, endIndent: AppSpacing.lg),
                    for (final item in group.items)
                      Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.xl),
                        child: FoodItemTile(
                          item: item,
                          now: widget.now,
                          dense: true,
                          onTap: () => widget.onTapItem?.call(item),
                          onFillExpiry: () => widget.onFillExpiry?.call(item),
                        ),
                      ),
                  ],
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
