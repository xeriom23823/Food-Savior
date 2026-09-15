import 'package:flutter/material.dart';
import 'package:food_savior/domain/import/food_item_draft.dart';
import 'package:food_savior/generated/l10n.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/models/storage_location.dart';
import 'package:food_savior/theme/app_tokens.dart';
import 'package:food_savior/theme/food_item_visuals.dart';
import 'package:food_savior/theme/localized_labels.dart';
import 'package:food_savior/widgets/expiry_field.dart';
import 'package:food_savior/widgets/location_picker.dart';

/// 草稿列的編輯（design D4）。
///
/// 一列塞六個可點區域在手機上會變成一排按不準的小東西，還會蓋掉「這一列是什麼」，
/// 所以改成點整列開一張 sheet，六個欄位一次改完。
class ImportDraftSheet extends StatefulWidget {
  const ImportDraftSheet({
    super.key,
    required this.draft,
    required this.locations,
    required this.now,
  });

  final FoodItemDraft draft;
  final List<StorageLocation> locations;
  final DateTime now;

  static Future<FoodItemDraft?> show(
    BuildContext context, {
    required FoodItemDraft draft,
    required List<StorageLocation> locations,
    required DateTime now,
  }) {
    return showModalBottomSheet<FoodItemDraft>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ImportDraftSheet(
        draft: draft,
        locations: locations,
        now: now,
      ),
    );
  }

  @override
  State<ImportDraftSheet> createState() => _ImportDraftSheetState();
}

class _ImportDraftSheetState extends State<ImportDraftSheet> {
  late final TextEditingController _name =
      TextEditingController(text: widget.draft.name);
  late final TextEditingController _amount = TextEditingController(
    text:
        widget.draft.amount == null ? '' : _formatAmount(widget.draft.amount!),
  );
  late FoodItemDraft _draft = widget.draft;

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  static String _formatAmount(double value) =>
      value == value.roundToDouble() ? value.toInt().toString() : '$value';

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                strings.einvoiceEditDraft,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              // 原始品名要留著，使用者才能對照發票確認改對了東西。
              Text(
                strings.einvoiceSourceLine(widget.draft.sourceLine),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _name,
                decoration: InputDecoration(labelText: strings.name),
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<FoodItemType>(
                initialValue: _draft.type,
                isExpanded: true,
                decoration: InputDecoration(labelText: strings.foodType),
                items: FoodItemType.values
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Row(
                            children: [
                              Icon(FoodItemVisuals.iconOf(type), size: 18),
                              const SizedBox(width: AppSpacing.sm),
                              Flexible(
                                child: Text(
                                  type.localizedName(context),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (type) {
                  if (type == null) return;
                  setState(() => _draft = _draft.copyWith(type: type));
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _amount,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: strings.amount),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: DropdownButtonFormField<Unit>(
                      initialValue: _draft.unit,
                      isExpanded: true,
                      decoration: InputDecoration(labelText: strings.unit),
                      items: Unit.values
                          .map((unit) => DropdownMenuItem(
                                value: unit,
                                child: Text(
                                  unit.localizedName(context),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                      onChanged: (unit) {
                        if (unit != null) {
                          setState(() => _draft = _draft.copyWith(unit: unit));
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              LocationPicker(
                locations: widget.locations,
                selectedId: _draft.storageLocationId,
                onChanged: (id) => setState(() {
                  _draft = id == null
                      ? _draft.copyWith(clearStorageLocation: true)
                      : _draft.copyWith(storageLocationId: id);
                }),
              ),
              const SizedBox(height: AppSpacing.lg),
              ExpiryField(
                value: _draft.expiry,
                now: widget.now,
                onChanged: (expiry) =>
                    setState(() => _draft = _draft.copyWith(expiry: expiry)),
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(_result()),
                child: Text(strings.save),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 使用者按了儲存，就代表他看過這一列了——清掉待確認標示。
  FoodItemDraft _result() {
    final raw = _amount.text.trim();
    final amount = double.tryParse(raw);
    return _draft.copyWith(
      name: _name.text.trim(),
      amount: amount,
      // 把數量清空是有意義的操作（例如「一包」這種不好數的東西），
      // 不能因為 copyWith 的 ?? 而被默默忽略。
      clearAmount: raw.isEmpty,
      needsReview: false,
    );
  }
}
