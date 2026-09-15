import 'package:flutter/material.dart';
import 'package:food_savior/theme/app_tokens.dart';
import 'package:lottie/lottie.dart';

enum AppSnackBarKind { success, warning, error }

/// 所有回饋訊息的唯一入口。深色模式下不會出現白底黑字。
abstract final class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    AppSnackBarKind kind = AppSnackBarKind.success,
    SnackBarAction? action,
    String? lottieAsset,
    String? illustrationAsset,
  }) {
    final theme = Theme.of(context);
    final icon = switch (kind) {
      AppSnackBarKind.success => Icons.check_circle_outline,
      AppSnackBarKind.warning => Icons.info_outline,
      AppSnackBarKind.error => Icons.error_outline,
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              if (lottieAsset != null)
                _FeedbackLottie(asset: lottieAsset)
              else if (illustrationAsset != null)
                Image.asset(
                  illustrationAsset,
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                )
              else
                Icon(icon, size: 18, color: theme.colorScheme.onInverseSurface),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(message)),
            ],
          ),
          action: action,
          duration: const Duration(seconds: 3),
        ),
      );
  }
}

class _FeedbackLottie extends StatelessWidget {
  const _FeedbackLottie({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Lottie.asset(
        asset,
        repeat: false,
        animate: !MediaQuery.disableAnimationsOf(context),
        fit: BoxFit.contain,
      ),
    );
  }
}
