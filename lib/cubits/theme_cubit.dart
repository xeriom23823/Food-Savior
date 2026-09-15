import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 只持有 [ThemeMode]。實際的 [ThemeData] 由 `AppTheme` 提供（design D1）。
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light) {
    _loadTheme();
  }

  static const String _key = 'isDark';

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    emit(prefs.getBool(_key) ?? false ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> switchTheme() async {
    final isDark = state == ThemeMode.dark;
    emit(isDark ? ThemeMode.light : ThemeMode.dark);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, !isDark);
  }
}
