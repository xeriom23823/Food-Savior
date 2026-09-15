import 'package:flutter/material.dart';
import 'package:food_savior/generated/l10n.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/models/food_item_form_validator.dart';
import 'package:food_savior/theme/app_tokens.dart';
import 'package:food_savior/theme/localized_labels.dart';
import 'package:food_savior/widgets/amount_label.dart';
import 'package:intl/intl.dart';

/// 部分處理的結果：一次操作可以同時記食用與丟棄（food-consumption 規格）。
class PartialUseResult {
  const PartialUseResult({
    required this.consumedAmount,
    required this.wastedAmount,
    required this.usedDate,
    this.wasteReason,
    this.remainingAfter,
  });

  final double consumedAmount;
  final double wastedAmount;
  final DateTime usedDate;
  final WasteReason? wasteReason;
  final RemainingFraction? remainingAfter;
}

/// 「吃了 3 個、丟了 2 個」是一次操作、兩筆紀錄。
class UseSheet extends StatefulWidget {
  const UseSheet({
    super.key,
    required this.available,
    required this.unit,
    required this.byFraction,
    required this.now,
  });

  final double? available;
  final Unit? unit;

  /// 以剩餘比例記錄的項目改問「用掉後還剩多少」。
  final bool byFraction;
  final DateTime now;

  static Future<PartialUseResult?> show(
    BuildContext context, {
    required double? available,
    required Unit? unit,
    required bool byFraction,
    required DateTime now,
  }) {
    return showModalBottomSheet<PartialUseResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: UseSheet(
          available: available,
          unit: unit,
          byFraction: byFraction,
          now: now,
        ),
      ),
    );
  }

  @override
  State<UseSheet> createState() => _UseSheetState();
}

class _UseSheetState extends State<UseSheet> {
  static const FoodItemFormValidator _validator = FoodItemFormValidator();
  static final DateFormat _dayFormat = DateFormat('yyyy-MM-dd');

  final _consumedController = TextEditingController();
  final _wastedController = TextEditingController(text: '0');

  late DateTime _usedDate = widget.now;
  WasteReason? _wasteReason;
  RemainingFraction? _remainingAfter;
  FoodFormError? _error;

  @override
  void initState() {
    super.initState();
    _consumedController.text = widget.available == null
        ? ''
        : AmountLabel.formatNumber(widget.available!);
  }

  @override
  void dispose() {
    _consumedController.dispose();
    _wastedController.dispose();
    super.dispose();
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(strings.useFoodItem, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.lg),
            if (widget.byFraction)
              _buildFractionPicker(strings)
            else
              _buildAmountFields(strings),
            const SizedBox(height: AppSpacing.lg),
            InkWell(
              onTap: _pickDate,
              borderRadius: AppRadius.field,
              child: InputDecorator(
                decoration: InputDecoration(labelText: strings.usedDate),
                child: Text(_dayFormat.format(_usedDate)),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(strings.wasteReason, style: theme.textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: WasteReason.values
                  .map((reason) => ChoiceChip(
                        label: Text(reason.localizedName(context)),
                        selected: _wasteReason == reason,
                        onSelected: (selected) => setState(
                          () => _wasteReason = selected ? reason : null,
                        ),
                      ))
                  .toList(),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _error!.localizedMessage(context),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.error),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            FilledButton(onPressed: _submit, child: Text(strings.confirm)),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountFields(S strings) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _consumedController,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: strings.consumedAmount,
              suffixText: widget.unit?.localizedName(context),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: TextField(
            controller: _wastedController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: strings.wastedAmount,
              suffixText: widget.unit?.localizedName(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFractionPicker(S strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(strings.remaining, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            ChoiceChip(
              label: Text(strings.useAll),
              selected: _remainingAfter == null,
              onSelected: (_) => setState(() => _remainingAfter = null),
            ),
            ...RemainingFraction.values.map(
              (fraction) => ChoiceChip(
                label: Text(fraction.localizedName(context)),
                selected: _remainingAfter == fraction,
                onSelected: (_) => setState(() => _remainingAfter = fraction),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _usedDate,
      firstDate: DateTime(widget.now.year - 5),
      lastDate: widget.now,
    );
    if (picked != null) setState(() => _usedDate = picked);
  }

  void _submit() {
    if (widget.byFraction) {
      Navigator.of(context).pop(PartialUseResult(
        consumedAmount: 0,
        wastedAmount: 0,
        usedDate: _usedDate,
        wasteReason: _wasteReason,
        remainingAfter: _remainingAfter,
      ));
      return;
    }

    final error = _validator.validatePortion(
      rawConsumed: _consumedController.text,
      rawWasted: _wastedController.text,
      available: widget.available,
    );
    setState(() => _error = error);
    if (error != null) return;

    Navigator.of(context).pop(PartialUseResult(
      consumedAmount: double.tryParse(_consumedController.text.trim()) ?? 0,
      wastedAmount: double.tryParse(_wastedController.text.trim()) ?? 0,
      usedDate: _usedDate,
      wasteReason: _wasteReason,
    ));
  }
}
