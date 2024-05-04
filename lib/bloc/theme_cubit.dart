import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeData> {
  ThemeCubit() : super(lightTheme) {
    _loadTheme();
  }

  // 將主題定義在這
  static final lightTheme = ThemeData(
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0097A7),
      elevation: 4,
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF0097A7),
      secondary: Color(0xFF009688),
      background: Color(0xFFE0F2F1),
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF212121),
      elevation: 4,
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF0097A7),
      secondary: Color(0xFF009688),
      background: Color(0xFF424242),
      onPrimary: Colors.blueGrey,
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
