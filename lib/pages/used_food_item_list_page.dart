import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_savior/bloc/used_food_item_list/used_food_item_list_bloc.dart';
import 'package:food_savior/generated/l10n.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/theme/app_tokens.dart';
import 'package:food_savior/theme/app_assets.dart';
import 'package:food_savior/theme/food_status_colors.dart';
import 'package:food_savior/theme/localized_labels.dart';
import 'package:food_savior/widgets/amount_label.dart';
import 'package:food_savior/widgets/confirm_sheet.dart';
import 'package:food_savior/widgets/empty_state.dart';
import 'package:food_savior/widgets/food_type_icon.dart';
import 'package:intl/intl.dart';

/// 使用紀錄：依日期瀏覽，可只看食用或只看浪費，並能事後補記浪費原因。
class UsedFoodItemListPage extends StatelessWidget {
  const UsedFoodItemListPage({super.key});

  static final DateFormat _dayFormat = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);

    return BlocBuilder<UsedFoodItemListBloc, UsedFoodItemListState>(
      builder: (context, state) {
        if (state is UsedFoodItemListError) {
          return Scaffold(
            appBar: AppBar(
              title: Text(strings.usedFoodItemListNavigationBarTitle),
            ),
            body: EmptyState(
              icon: Icons.cloud_off,
              title: strings.foodItemListError,
              action: FilledButton(
                onPressed: () => context
                    .read<UsedFoodItemListBloc>()
                    .add(const UsedFoodItemListRefresh()),
                child: Text(strings.refresh),
              ),
            ),
          );
        }
        if (state is! UsedFoodItemListLoaded) {
          return Scaffold(
            appBar: AppBar(
              title: Text(strings.usedFoodItemListNavigationBarTitle),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(strings.usedFoodItemListNavigationBarTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: () => _pickDate(context, state.selectedDate),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                _WeekStrip(selectedDate: state.selectedDate),
                _FilterBar(filter: state.filter),
                Expanded(
                  child: state.usedFoodItems.isEmpty
                      ? EmptyState(
                          icon: Icons.receipt_long_outlined,
                          illustrationAsset: state.filter == UsedFoodFilter.all
                              ? AppAssets.emptyUsedHistory
                              : AppAssets.emptyFilterNoResults,
                          title: state.filter == UsedFoodFilter.all
                              ? strings.emptyUsedFoodListTitle
                              : strings.noData,
                          description: state.filter == UsedFoodFilter.all
                              ? strings.emptyUsedFoodListDescription
                              : null,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            AppSpacing.sm,
                            AppSpacing.lg,
                            AppSpacing.xl,
                          ),
                          itemCount: state.usedFoodItems.length,
                          itemBuilder: (context, index) => _UsedFoodTile(
                            item: state.usedFoodItems[index],
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickDate(BuildContext context, DateTime selected) async {
    final bloc = context.read<UsedFoodItemListBloc>();
    final picked = await showDatePicker(
      context: context,
      initialDate: selected,
      firstDate: DateTime(2021),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      bloc.add(UsedFoodItemListLoadByDate(date: picked));
    }
  }

  static String formatDay(DateTime date) => _dayFormat.format(date);
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.selectedDate});

  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final monday = selectedDate.subtract(
      Duration(days: selectedDate.weekday - DateTime.monday),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: List.generate(7, (index) {
          final day = monday.add(Duration(days: index));
          final isSelected = _isSameDay(day, selectedDate);
          final isToday = _isSameDay(day, now);

          return Expanded(
            child: InkWell(
              borderRadius: AppRadius.card,
              onTap: () => context
                  .read<UsedFoodItemListBloc>()
                  .add(UsedFoodItemListLoadByDate(date: day)),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primaryContainer
                      : Colors.transparent,
                  borderRadius: AppRadius.card,
                  border: isToday && !isSelected
                      ? Border.all(color: theme.colorScheme.primary)
                      : null,
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat.E(Localizations.localeOf(context).toString())
                          .format(day),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isSelected
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${day.day}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: isSelected
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurface,
                        fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.filter});

  final UsedFoodFilter filter;

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          for (final entry in <(UsedFoodFilter, String)>[
            (UsedFoodFilter.all, strings.filterAll),
            (UsedFoodFilter.consumed, strings.filterConsumed),
            (UsedFoodFilter.wasted, strings.filterWasted),
          ])
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: ChoiceChip(
                label: Text(entry.$2),
                selected: filter == entry.$1,
                onSelected: (_) => context
                    .read<UsedFoodItemListBloc>()
                    .add(UsedFoodItemListFilterChanged(filter: entry.$1)),
              ),
            ),
        ],
      ),
    );
  }
}

class _UsedFoodTile extends StatelessWidget {
  const _UsedFoodTile({required this.item});

  final UsedFoodItem item;

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);
    final colors = context.foodStatusColors;
    final status =
        item.isWaste ? FoodItemStatus.wasted : FoodItemStatus.consumed;

    final details = <String>[
      AmountLabel.format(
        context,
        amount: item.amount,
        unit: item.unit,
        remainingFraction: item.remainingFraction,
      ),
      item.disposalMethod.localizedName(context),
      if (item.wasteReason != null) item.wasteReason!.localizedName(context),
      if (item.priceTotal != null) strings.priceLabel(item.priceTotal!),
    ].where((text) => text.isNotEmpty).toList();

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colors.containerOf(status),
          child: FoodTypeIcon(
            type: item.type,
            color: colors.of(status),
            size: 20,
          ),
        ),
        title: Text(item.name),
        subtitle: Text(details.join(' · ')),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              strings.pointsLabel(item.affectFoodPoint),
              style: theme.textTheme.labelMedium?.copyWith(
                color:
                    item.affectFoodPoint >= 0 ? colors.fresh : colors.expired,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              UsedFoodItemListPage.formatDay(item.usedDate),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        onTap: () => _showActions(context),
      ),
    );
  }

  Future<void> _showActions(BuildContext context) async {
    final bloc = context.read<UsedFoodItemListBloc>();
    final strings = S.of(context);

    await showModalBottomSheet<bool>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.isWaste) ...[
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.wasteReason,
                      style: Theme.of(sheetContext).textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      children: WasteReason.values
                          .map((reason) => ChoiceChip(
                                label: Text(reason.localizedName(sheetContext)),
                                selected: item.wasteReason == reason,
                                onSelected: (_) {
                                  bloc.add(UsedFoodItemListSetWasteReason(
                                    id: item.id,
                                    wasteReason: reason,
                                  ));
                                  Navigator.of(sheetContext).pop();
                                },
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
            ],
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(strings.delete),
              onTap: () => Navigator.of(sheetContext).pop(true),
            ),
          ],
        ),
      ),
    ).then((shouldDelete) async {
      if (shouldDelete != true || !context.mounted) return;
      final confirmed = await ConfirmSheet.show(
        context,
        title: strings.delete,
        message: item.name,
        confirmLabel: strings.delete,
      );
      if (confirmed) bloc.add(UsedFoodItemListRemove(id: item.id));
    });
  }
}
