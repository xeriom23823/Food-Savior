import 'package:flutter/material.dart';
import 'package:food_savior/generated/l10n.dart';
import 'package:food_savior/theme/app_tokens.dart';

/// 破壞性動作的確認。一定說清楚「會發生什麼」，不只問「確定嗎」。
abstract final class ConfirmSheet {
  static Future<bool> show(
    BuildContext context, {
    required String title,
    String? message,
    String? confirmLabel,
    bool destructive = true,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
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
                Text(title, style: theme.textTheme.titleMedium),
                if (message != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                FilledButton(
                  style: destructive
                      ? FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.error,
                          foregroundColor: theme.colorScheme.onError,
                        )
                      : null,
                  onPressed: () => Navigator.of(sheetContext).pop(true),
                  child: Text(confirmLabel ?? S.of(sheetContext).confirm),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(false),
                  child: Text(S.of(sheetContext).cancel),
                ),
              ],
            ),
          ),
        );
      },
    );
    return result ?? false;
  }
}
