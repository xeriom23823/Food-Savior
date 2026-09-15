import 'package:flutter/material.dart';
import 'package:food_savior/generated/l10n.dart';
import 'package:food_savior/models/expiry.dart';
import 'package:food_savior/models/expiry_quick_pick.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/theme/app_tokens.dart';
import 'package:food_savior/theme/localized_labels.dart';
import 'package:food_savior/widgets/app_line_icon.dart';
import 'package:intl/intl.dart';

/// 四種期限精度的輸入（design D10）。
///
/// 「不知道」是平等的選項而不是錯誤狀態——使用者常常真的不知道，
/// 逼他填一個假日期只會讓資料變髒。
class ExpiryField extends StatefulWidget {
  const ExpiryField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.now,
    this.errorText,
  });

  final ExpiryValue value;
  final ValueChanged<ExpiryValue> onChanged;
  final DateTime now;
  final String? errorText;

  @override
  State<ExpiryField> createState() => _ExpiryFieldState();
}

class _ExpiryFieldState extends State<ExpiryField> {
  static final DateFormat _dayFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _monthFormat = DateFormat('yyyy-MM');

  ExpiryValue get _value => widget.value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).expirationDate,
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        SegmentedButton<ExpiryPrecision>(
          segments: ExpiryPrecision.values
              .map((precision) => ButtonSegment<ExpiryPrecision>(
                    value: precision,
                    icon: AppLineIcon(
                      kind: switch (precision) {
                        ExpiryPrecision.exact => AppLineIconKind.expiryExact,
                        ExpiryPrecision.range => AppLineIconKind.expiryRange,
                        ExpiryPrecision.monthOnly =>
                          AppLineIconKind.expiryMonthOnly,
                        ExpiryPrecision.unknown =>
                          AppLineIconKind.expiryUnknown,
                      },
                      size: 18,
                    ),
                    label: Text(precision.localizedName(context)),
                  ))
              .toList(),
          selected: {_value.precision},
          showSelectedIcon: false,
          onSelectionChanged: (selection) =>
              _onPrecisionChanged(selection.first),
        ),
        const SizedBox(height: AppSpacing.md),
        ..._inputsFor(_value.precision),
        if (widget.errorText != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            widget.errorText!,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.error),
          ),
        ],
      ],
    );
  }

  List<Widget> _inputsFor(ExpiryPrecision precision) {
    switch (precision) {
      case ExpiryPrecision.exact:
        return [
          // 快速選項只在「精確到日」出現：區間與只到月的使用者本來就處於
          // 「我不確定」的狀態，給他精確捷徑沒有意義（design D1）。
          _QuickPicks(
            selected: ExpiryQuickPick.matching(_value.earliest, widget.now),
            onPick: (pick) => widget.onChanged(pick.expiryFrom(widget.now)),
          ),
          const SizedBox(height: AppSpacing.sm),
          _DateButton(
            label: S.of(context).expirationDate,
            value: _value.earliest,
            format: _dayFormat,
            onPick: () => _pickDate(_value.earliest, (date) {
              widget.onChanged(ExpiryValue.exact(date));
            }),
          ),
        ];
      case ExpiryPrecision.range:
        return [
          _DateButton(
            label: S.of(context).expiryEarliest,
            value: _value.earliest,
            format: _dayFormat,
            onPick: () => _pickDate(_value.earliest, (date) {
              widget.onChanged(ExpiryValue.range(
                date,
                _value.latest ?? date.add(const Duration(days: 2)),
              ));
            }),
          ),
          const SizedBox(height: AppSpacing.sm),
          _DateButton(
            label: S.of(context).expiryLatest,
            value: _value.latest,
            format: _dayFormat,
            onPick: () => _pickDate(_value.latest, (date) {
              widget.onChanged(ExpiryValue.range(
                _value.earliest ?? date,
                date,
              ));
            }),
          ),
        ];
      case ExpiryPrecision.monthOnly:
        final anchor = _value.earliest ?? widget.now;
        return [
          _DateButton(
            label: S.of(context).expiryPrecisionMonthOnly,
            value: _value.earliest,
            format: _monthFormat,
            onPick: () => _pickMonth(anchor),
          ),
        ];
      case ExpiryPrecision.unknown:
        return [
          Row(
            children: [
              AppLineIcon(
                kind: AppLineIconKind.expiryUnknown,
                size: 16,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  S.of(context).quickAddHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),
        ];
    }
  }

  void _onPrecisionChanged(ExpiryPrecision precision) {
    final anchor = _value.earliest ?? widget.now.add(const Duration(days: 7));
    switch (precision) {
      case ExpiryPrecision.exact:
        widget.onChanged(ExpiryValue.exact(anchor));
      case ExpiryPrecision.range:
        widget.onChanged(
            ExpiryValue.range(anchor, anchor.add(const Duration(days: 3))));
      case ExpiryPrecision.monthOnly:
        widget.onChanged(ExpiryValue.month(anchor.year, anchor.month));
      case ExpiryPrecision.unknown:
        widget.onChanged(const ExpiryValue.unknown());
    }
  }

  Future<void> _pickDate(
    DateTime? initial,
    ValueChanged<DateTime> onPicked,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? widget.now,
      firstDate: DateTime(widget.now.year - 5),
      lastDate: DateTime(widget.now.year + 10),
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _pickMonth(DateTime anchor) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: anchor,
      firstDate: DateTime(widget.now.year - 5),
      lastDate: DateTime(widget.now.year + 10),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      widget.onChanged(ExpiryValue.month(picked.year, picked.month));
    }
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.value,
    required this.format,
    required this.onPick,
  });

  final String label;
  final DateTime? value;
  final DateFormat format;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPick,
      borderRadius: AppRadius.field,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value == null ? '—' : format.format(value!),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            AppLineIcon(
              kind: AppLineIconKind.expiryExact,
              size: 18,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

/// 一排期限快速選項（design D2）。
///
/// 選中狀態以**日期相等**判定，不是記住使用者按了哪一顆——後者在重新進入畫面後
/// 就失真了（例如從清單再次打開同一項食物）。
class _QuickPicks extends StatelessWidget {
  const _QuickPicks({required this.selected, required this.onPick});

  final ExpiryQuickPick? selected;
  final ValueChanged<ExpiryQuickPick> onPick;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // 單行橫向捲動：六個選項在窄螢幕放不下，但換行會把日期按鈕擠下去。
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final pick in ExpiryQuickPick.values) ...[
            ChoiceChip(
              label: Text(pick.localizedName(context)),
              selected: pick == selected,
              onSelected: (_) => onPick(pick),
            ),
            if (pick != ExpiryQuickPick.values.last)
              const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}
