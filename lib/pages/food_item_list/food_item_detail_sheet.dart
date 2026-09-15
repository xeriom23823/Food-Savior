import 'package:flutter/material.dart';
import 'package:food_savior/generated/l10n.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/models/storage_location.dart';
import 'package:food_savior/theme/app_tokens.dart';
import 'package:food_savior/theme/localized_labels.dart';
import 'package:food_savior/widgets/amount_label.dart';
import 'package:food_savior/widgets/app_line_icon.dart';
import 'package:food_savior/widgets/status_chip.dart';
import 'package:intl/intl.dart';

enum FoodItemDetailAction { edit, markOpened, fillExpiry, delete }

/// 食物詳情。期限依精度呈現，使用者才知道那個日期有多可靠。
class FoodItemDetailSheet extends StatelessWidget {
  const FoodItemDetailSheet({
    super.key,
    required this.item,
    required this.now,
    this.location,
  });

  final FoodItem item;
  final DateTime now;
  final StorageLocation? location;

  static final DateFormat _dayFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _monthFormat = DateFormat('yyyy-MM');

  static Future<FoodItemDetailAction?> show(
    BuildContext context, {
    required FoodItem item,
    required DateTime now,
    StorageLocation? location,
  }) {
    return showModalBottomSheet<FoodItemDetailAction>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          FoodItemDetailSheet(item: item, now: now, location: location),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(item.name, style: theme.textTheme.titleLarge),
                ),
                StatusChip(status: item.statusAt(now)),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _row(context, strings.foodType, item.type.localizedName(context)),
            _row(
              context,
              strings.amount,
              AmountLabel.format(
                context,
                amount: item.amount,
                unit: item.unit,
                remainingFraction: item.remainingFraction,
              ),
            ),
            _row(context, strings.storageLocation,
                location?.name ?? strings.noLocation),
            _row(context, strings.storageDate,
                _dayFormat.format(item.storageDate)),
            _row(context, strings.expirationDate, _describeExpiry(context)),
            if (item.openedDate != null)
              _row(
                context,
                strings.openedDate,
                item.shelfLifeAfterOpenDays == null
                    ? _dayFormat.format(item.openedDate!)
                    : '${_dayFormat.format(item.openedDate!)} · '
                        '${strings.afterOpenDaysLabel(item.shelfLifeAfterOpenDays!)}',
              ),
            if (item.priceTotal != null)
              _row(
                  context, strings.price, strings.priceLabel(item.priceTotal!)),
            if (item.description.isNotEmpty)
              _row(context, strings.description, item.description),
            const SizedBox(height: AppSpacing.xl),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () =>
                      Navigator.of(context).pop(FoodItemDetailAction.edit),
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(strings.edit),
                ),
                if (item.needsExpiryCompletion)
                  FilledButton.tonalIcon(
                    onPressed: () => Navigator.of(context)
                        .pop(FoodItemDetailAction.fillExpiry),
                    icon: const AppLineIcon(
                      kind: AppLineIconKind.expiryUnknown,
                      size: 18,
                    ),
                    label: Text(strings.fillExpiry),
                  ),
                if (!item.isOpened)
                  FilledButton.tonalIcon(
                    onPressed: () => Navigator.of(context)
                        .pop(FoodItemDetailAction.markOpened),
                    icon: const AppLineIcon(
                      kind: AppLineIconKind.openedPackage,
                      size: 18,
                    ),
                    label: Text(strings.markOpened),
                  ),
                TextButton.icon(
                  onPressed: () =>
                      Navigator.of(context).pop(FoodItemDetailAction.delete),
                  icon: const Icon(Icons.delete_outline),
                  label: Text(strings.delete),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _describeExpiry(BuildContext context) {
    final strings = S.of(context);
    switch (item.expiryPrecision) {
      case ExpiryPrecision.exact:
        return _dayFormat.format(item.expiryEarliest!);
      case ExpiryPrecision.range:
        return '${_dayFormat.format(item.expiryEarliest!)} ~ '
            '${_dayFormat.format(item.expiryLatest!)}';
      case ExpiryPrecision.monthOnly:
        return _monthFormat.format(item.expiryEarliest!);
      case ExpiryPrecision.unknown:
        return strings.expiryUnknown;
    }
  }

  Widget _row(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
