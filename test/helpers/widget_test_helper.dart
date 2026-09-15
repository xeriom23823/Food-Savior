import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:food_savior/generated/l10n.dart';
import 'package:food_savior/theme/app_theme.dart';

/// Widget test 的外殼：l10n delegates 與主題一次到位，
/// 每個測試都能指定語系與明暗，符合「明暗各一、zh／en 都測」的要求。
Widget wrapForTest(
  Widget child, {
  Locale locale = const Locale('zh', 'TW'),
  Brightness brightness = Brightness.light,
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: S.delegate.supportedLocales,
    theme: brightness == Brightness.dark ? AppTheme.dark : AppTheme.light,
    home: child,
  );
}
