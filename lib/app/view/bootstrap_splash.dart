import 'package:flutter/material.dart';
import 'package:food_savior/theme/app_assets.dart';
import 'package:food_savior/theme/app_theme.dart';
import 'package:food_savior/theme/app_tokens.dart';

/// 在 Firebase／Auth／Hive 完成啟動前先繪製的品牌首幀。
///
/// 這個 surface 不持有 App 狀態，也不取代原生 launch theme；它只避免
/// Android 12 將 system splash 交給 Flutter 後，長初始化期間留下空白畫面。
class BootstrapSplash extends StatelessWidget {
  const BootstrapSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const _BootstrapSplashView(),
    );
  }
}

class _BootstrapSplashView extends StatelessWidget {
  const _BootstrapSplashView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background =
        isDark ? AppTheme.splashBackgroundDark : AppTheme.splashBackgroundLight;

    return Scaffold(
      backgroundColor: background,
      body: Center(
        child: SizedBox.square(
          dimension: AppIllustrationSize.splash,
          child: Image.asset(
            AppAssets.splashIllustration,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}
