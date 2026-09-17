import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_savior/bloc/food_item_list/food_item_list_bloc.dart';
import 'package:food_savior/generated/l10n.dart';
import 'package:food_savior/theme/app_tokens.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/theme/food_status_colors.dart';
import 'package:food_savior/theme/localized_labels.dart';
import 'package:food_savior/widgets/amount_label.dart';
import 'package:food_savior/widgets/food_type_icon.dart';
import 'package:intl/intl.dart';

/// 啟動時的過期處理：逐筆說明「吃掉了」還是「丟掉了」。
///
/// 預設是丟掉，因為那才是過期後最常發生的事；語氣保持中性，不責備。
class ExpiredProcessingView extends StatefulWidget {
  const ExpiredProcessingView({super.key, required this.state});

  final FoodItemListNeedProcessing state;

  @override
  State<ExpiredProcessingView> createState() => _ExpiredProcessingViewState();
}

class _ExpiredProcessingViewState extends State<ExpiredProcessingView> {
  static final DateFormat _dayFormat = DateFormat('yyyy-MM-dd');

  /// 沒勾「已食用」的都會被記成丟棄，這個原因套用到那些項目；可以不選。
  WasteReason? _wasteReason;

  FoodItemListNeedProcessing get state => widget.state;

  bool get _hasWaste => state.isConsumed.any((consumed) => !consumed);

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);
    final colors = context.foodStatusColors;

    return Scaffold(
      appBar: AppBar(title: Text(strings.expiredFoodListTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: state.expiredFoodItems.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final item = state.expiredFoodItems[index];
                  final isConsumed = state.isConsumed[index];
                  return Card(
                    child: SwitchListTile(
                      value: isConsumed,
                      onChanged: (_) => context
                          .read<FoodItemListBloc>()
                          .add(FoodItemListProcessingUpdate(
                            updateIndex: index,
                          )),
                      secondary: CircleAvatar(
                        backgroundColor: colors.expiredContainer,
                        child: FoodTypeIcon(
                          type: item.type,
                          color: colors.expired,
                          size: 20,
                        ),
                      ),
                      title: Text(item.name),
                      subtitle: Text(
                        '${AmountLabel.format(
                          context,
                          amount: item.amount,
                          unit: item.unit,
                          remainingFraction: item.remainingFraction,
                        )} · ${item.effectiveExpiry == null ? strings.expiryUnknown : _dayFormat.format(item.effectiveExpiry!)}',
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_hasWaste) ...[
                    Text(
                      strings.wasteReason,
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (final reason in WasteReason.values)
                            Padding(
                              padding:
                                  const EdgeInsets.only(right: AppSpacing.sm),
                              child: ChoiceChip(
                                label: Text(reason.localizedName(context)),
                                selected: _wasteReason == reason,
                                onSelected: (selected) => setState(
                                  () => _wasteReason = selected ? reason : null,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => context.read<FoodItemListBloc>().add(
                            FoodItemListProcessComplete(
                              wasteReason: _wasteReason,
                            ),
                          ),
                      child: Text(strings.processComplete),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
