import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeData> {
  ThemeCubit() : super(lightTheme) {
    _loadTheme();
  }

  // 將主題定義在這
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    fontFamily: 'NotoSansTC',
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF4CAF50), // 更鮮明的綠色
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'NotoSansTC',
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF4CAF50), // 主要綠色
      secondary: Color(0xFF8BC34A), // 次要淺綠
      tertiary: Color(0xFFFFC107), // 強調色黃色
      surface: Color(0xFFF8F9FA), // 淺灰背景
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF212121),
      outline: Color(0xFFE0E0E0),
    ),
    cardTheme: const CardThemeData(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.white,
    ),
    listTileTheme: const ListTileThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    fontFamily: 'NotoSansTC',
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1B5E20), // 深綠
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'NotoSansTC',
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF4CAF50),
      secondary: Color(0xFF8BC34A),
      tertiary: Color(0xFFFFC107),
      surface: Color(0xFF121212),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white70,
      outline: Color(0xFF424242),
    ),
    cardTheme: const CardThemeData(
      elevation: 4,
      shadowColor: Colors.black45,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
    ),
    listTileTheme: const ListTileThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  );

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDark') ?? false;
    emit(isDark ? darkTheme : lightTheme);
  }

  Future<void> switchTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = state.brightness == Brightness.dark;
    await prefs.setBool('isDark', !isDark);
    emit(
      state.brightness == Brightness.dark ? lightTheme : darkTheme,
    );
  }
}
