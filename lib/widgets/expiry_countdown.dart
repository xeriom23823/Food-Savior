import 'package:flutter/material.dart';
import 'package:food_savior/generated/l10n.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/theme/app_tokens.dart';
import 'package:food_savior/theme/food_status_colors.dart';
import 'package:food_savior/widgets/app_line_icon.dart';

/// 期限的呈現。近似期限（區間／只到月）用不同語氣，
/// 才不會讓使用者以為那是確定的日期（food-inventory 規格）。
class ExpiryCountdown extends StatelessWidget {
  const ExpiryCountdown({
    super.key,
    required this.item,
    required this.now,
    this.compact = false,
  });

  final FoodItem item;
  final DateTime now;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final status = item.statusAt(now);
    final color = context.foodStatusColors.of(status);
    final text = describe(context, item: item, now: now);

    if (compact) {
      return Text(
        text,
        style: Theme.of(context)
            .textTheme
            .labelMedium
            ?.copyWith(color: color, fontWeight: FontWeight.w600),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppLineIcon(
          kind: switch (item.expiryPrecision) {
            ExpiryPrecision.exact => AppLineIconKind.expiryExact,
            ExpiryPrecision.range => AppLineIconKind.expiryRange,
            ExpiryPrecision.monthOnly => AppLineIconKind.expiryMonthOnly,
            ExpiryPrecision.unknown => AppLineIconKind.expiryUnknown,
          },
          size: 16,
          color: color,
        ),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            text,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  static String describe(
    BuildContext context, {
    required FoodItem item,
    required DateTime now,
  }) {
    final expiry = item.effectiveExpiry;
    if (expiry == null) return S.of(context).expiryUnknown;

    final today = DateTime(now.year, now.month, now.day);
    final expiryDay = DateTime(expiry.year, expiry.month, expiry.day);
    final days = expiryDay.difference(today).inDays;

    if (days < 0) return S.of(context).expiredDaysAgo(-days);
    if (days == 0) return S.of(context).expireToday;

    final approximate = item.expiryPrecision == ExpiryPrecision.range ||
        item.expiryPrecision == ExpiryPrecision.monthOnly;
    return approximate
        ? S.of(context).expireApproximatelyInDays(days)
        : S.of(context).expireInDays(days);
  }
}
