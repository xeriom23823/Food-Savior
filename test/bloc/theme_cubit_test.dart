import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/cubits/theme_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  group('ThemeCubit', () {
    late ThemeCubit themeCubit;

    setUp(() {
      themeCubit = ThemeCubit();
    });

    tearDown(() {
      themeCubit.close();
    });

    test('initial state is light theme', () {
      expect(themeCubit.state, equals(ThemeCubit.lightTheme));
    });

    test('switchTheme changes the theme from light to dark', () async {
      await themeCubit.switchTheme();

      expect(themeCubit.state, equals(ThemeCubit.darkTheme));
    });

    test('switchTheme changes the theme from dark to light', () async {
      await themeCubit.switchTheme();

      expect(themeCubit.state, equals(ThemeCubit.lightTheme));
    });
  });
}
