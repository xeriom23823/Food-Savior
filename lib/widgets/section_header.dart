import 'package:flutter/material.dart';
import 'package:food_savior/theme/app_tokens.dart';

/// 分群標題。標題旁一定帶筆數，使用者才知道「這一群有多少」。
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.count,
    this.color,
    this.icon,
    this.leading,
    this.trailing,
  });

  final String title;
  final String? count;
  final Color? color;
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = color ?? theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          if (icon != null || leading != null) ...[
            if (leading != null)
              IconTheme.merge(
                data: IconThemeData(color: foreground, size: 16),
                child: leading!,
              )
            else
              Icon(icon, size: 16, color: foreground),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (count != null)
            Text(
              count!,
              style: theme.textTheme.labelMedium?.copyWith(color: foreground),
            ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.sm),
            trailing!,
          ],
        ],
      ),
    );
  }
}
