import 'package:flutter/material.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/theme/localized_labels.dart';

/// 份量的顯示：數量加單位，或剩餘比例（design D13）。
///
/// 整數不顯示 `.0`，否則「1.0 瓶牛奶」看起來像實驗室紀錄。
class AmountLabel extends StatelessWidget {
  const AmountLabel({
    super.key,
    this.amount,
    this.unit,
    this.remainingFraction,
    this.style,
  });

  factory AmountLabel.of(FoodItem item, {TextStyle? style}) => AmountLabel(
        amount: item.amount,
        unit: item.unit,
        remainingFraction: item.remainingFraction,
        style: style,
      );

  final double? amount;
  final Unit? unit;
  final RemainingFraction? remainingFraction;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(
      format(context,
          amount: amount, unit: unit, remainingFraction: remainingFraction),
      style: style ?? Theme.of(context).textTheme.bodyMedium,
    );
  }

  static String format(
    BuildContext context, {
    double? amount,
    Unit? unit,
    RemainingFraction? remainingFraction,
  }) {
    if (amount != null) {
      final number = formatNumber(amount);
      return unit == null ? number : '$number ${unit.localizedName(context)}';
    }
    if (remainingFraction != null) {
      return remainingFraction.localizedName(context);
    }
    return '';
  }

  /// 1.0 → 「1」、0.5 → 「0.5」、0.25 → 「0.25」。
  static String formatNumber(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    final text = value.toStringAsFixed(2);
    return text
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }
}
