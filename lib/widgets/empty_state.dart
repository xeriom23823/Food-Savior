import 'package:flutter/material.dart';
import 'package:food_savior/theme/app_tokens.dart';

/// 空狀態。語氣不責備，且盡量帶一個可以立刻做的動作。
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.action,
    this.illustrationAsset,
  });

  final IconData icon;
  final String title;
  final String? description;
  final Widget? action;
  final String? illustrationAsset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (illustrationAsset != null)
              Semantics(
                image: true,
                label: title,
                child: Image.asset(
                  illustrationAsset!,
                  width: AppIllustrationSize.emptyState,
                  height: AppIllustrationSize.emptyState,
                  fit: BoxFit.contain,
                ),
              )
            else
              Icon(icon, size: 56, color: theme.colorScheme.outline),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            if (description != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
