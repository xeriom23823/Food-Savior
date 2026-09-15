import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/cubits/theme_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('預設是淺色', () async {
    final cubit = ThemeCubit();
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, ThemeMode.light);
  });

  test('切換後變成深色並持久化', () async {
    final cubit = ThemeCubit();
    await Future<void>.delayed(Duration.zero);

    await cubit.switchTheme();

    expect(cubit.state, ThemeMode.dark);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('isDark'), isTrue);
  });

  test('重新建立時讀回已保存的深色設定', () async {
    SharedPreferences.setMockInitialValues({'isDark': true});

    final cubit = ThemeCubit();
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, ThemeMode.dark);
  });
}
