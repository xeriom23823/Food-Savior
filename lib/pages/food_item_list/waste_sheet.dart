import 'package:flutter/material.dart';
import 'package:food_savior/generated/l10n.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/theme/app_tokens.dart';
import 'package:food_savior/theme/food_item_visuals.dart';
import 'package:food_savior/theme/localized_labels.dart';

class WasteChoice {
  const WasteChoice({required this.disposalMethod, this.wasteReason});

  final DisposalMethod disposalMethod;
  final WasteReason? wasteReason;
}

/// 丟棄前的輕量選擇。原因與處理方式都可以跳過——
/// 讓使用者因為怕麻煩而不記錄浪費，才是真正的損失。
class WasteSheet extends StatefulWidget {
  const WasteSheet({super.key});

  static Future<WasteChoice?> show(BuildContext context) {
    return showModalBottomSheet<WasteChoice>(
      context: context,
      builder: (_) => const WasteSheet(),
    );
  }

  @override
  State<WasteSheet> createState() => _WasteSheetState();
}

class _WasteSheetState extends State<WasteSheet> {
  static const List<DisposalMethod> _methods = [
    DisposalMethod.discarded,
    DisposalMethod.composted,
    DisposalMethod.givenAway,
  ];

  DisposalMethod _method = DisposalMethod.discarded;
  WasteReason? _reason;

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
            Text(strings.disposalMethod, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              children: _methods
                  .map((method) => ChoiceChip(
                        avatar: Icon(
                          FoodItemVisuals.disposalIconOf(method),
                          size: 16,
                        ),
                        label: Text(method.localizedName(context)),
                        selected: _method == method,
                        onSelected: (_) => setState(() => _method = method),
                      ))
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(strings.wasteReason, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: WasteReason.values
                  .map((reason) => ChoiceChip(
                        label: Text(reason.localizedName(context)),
                        selected: _reason == reason,
                        onSelected: (selected) =>
                            setState(() => _reason = selected ? reason : null),
                      ))
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(
                WasteChoice(disposalMethod: _method, wasteReason: _reason),
              ),
              child: Text(strings.confirm),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => Navigator.of(context).pop(
                const WasteChoice(disposalMethod: DisposalMethod.discarded),
              ),
              child: Text(strings.skip),
            ),
          ],
        ),
      ),
    );
  }
}
