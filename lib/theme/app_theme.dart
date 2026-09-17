import 'package:flutter/material.dart';
import 'package:food_savior/theme/app_tokens.dart';
import 'package:food_savior/theme/food_status_colors.dart';

/// 明暗兩套主題的唯一來源（design D1）。
///
/// 頁面與元件只引用 `ColorScheme` / `TextTheme` 與 token，不寫死顏色與字級。
abstract final class AppTheme {
  /// 品牌綠（沉穩綠）。改這一個值，全 App 一致變色。
  static const Color seed = Color(0xFF3E8E5A);

  /// 暖黃強調色，M3 產生器不會給出足夠暖的 tertiary，所以手動覆寫。
  static const Color accent = Color(0xFFE0A100);

  /// 原生與 Flutter bootstrap splash 共用的背景色。
  static const Color splashBackgroundLight = seed;
  static const Color splashBackgroundDark = Color(0xFF1F4D31);

  static const String fontFamily = 'NotoSansTC';

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
    ).copyWith(
      tertiary: accent,
      onTertiary: brightness == Brightness.light
          ? const Color(0xFF3A2A00)
          : const Color(0xFF3A2A00),
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: colorScheme.surface,
    );

    return base.copyWith(
      textTheme: _textTheme(base.textTheme),
      extensions: <ThemeExtension<dynamic>>[
        brightness == Brightness.light
            ? FoodStatusColors.light
            : FoodStatusColors.dark,
      ],
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: _textTheme(base.textTheme).titleLarge,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: colorScheme.surfaceContainerLow,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide.none,
        labelStyle: _textTheme(base.textTheme).labelMedium,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.field),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.field),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: const OutlineInputBorder(
          borderRadius: AppRadius.field,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.field,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.field,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),
      listTileTheme: const ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        indicatorColor: colorScheme.secondaryContainer,
        elevation: 0,
        labelTextStyle: WidgetStatePropertyAll(
          _textTheme(base.textTheme).labelMedium,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: _textTheme(base.textTheme).bodyMedium?.copyWith(
              color: colorScheme.onInverseSurface,
            ),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
        showDragHandle: true,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        space: 1,
        thickness: 1,
      ),
    );
  }

  /// 數字一律用等寬數字，清單裡的天數與份量才不會左右跳動。
  static TextTheme _textTheme(TextTheme base) {
    const tabular = [FontFeature.tabularFigures()];
    return base.copyWith(
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      bodyMedium: base.bodyMedium?.copyWith(height: 1.5),
      bodySmall: base.bodySmall?.copyWith(height: 1.4),
      labelLarge: base.labelLarge?.copyWith(fontFeatures: tabular),
      labelMedium: base.labelMedium?.copyWith(fontFeatures: tabular),
      headlineSmall: base.headlineSmall?.copyWith(fontFeatures: tabular),
    );
  }
}
