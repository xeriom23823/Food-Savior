import 'package:flutter/material.dart';
import 'package:food_savior/generated/l10n.dart';
import 'package:food_savior/models/expiry.dart';
import 'package:food_savior/theme/app_tokens.dart';
import 'package:food_savior/widgets/expiry_field.dart';

/// 只補期限的輕量入口：不必為了填一個日期而打開整張表單
/// （food-inventory 規格）。
class ExpirySheet extends StatefulWidget {
  const ExpirySheet({super.key, required this.initial, required this.now});

  final ExpiryValue initial;
  final DateTime now;

  static Future<ExpiryValue?> show(
    BuildContext context, {
    required ExpiryValue initial,
    required DateTime now,
  }) {
    return showModalBottomSheet<ExpiryValue>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ExpirySheet(initial: initial, now: now),
    );
  }

  @override
  State<ExpirySheet> createState() => _ExpirySheetState();
}

class _ExpirySheetState extends State<ExpirySheet> {
  late ExpiryValue _value = widget.initial.isKnown
      ? widget.initial
      : ExpiryValue.exact(widget.now.add(const Duration(days: 7)));

  @override
  Widget build(BuildContext context) {
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
            ExpiryField(
              value: _value,
              now: widget.now,
              onChanged: (value) => setState(() => _value = value),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(_value),
              child: Text(S.of(context).save),
            ),
          ],
        ),
      ),
    );
  }
}
