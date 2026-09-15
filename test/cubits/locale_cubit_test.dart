import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/cubits/locale_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const zhTW = Locale('zh', 'TW');
  const enUS = Locale('en', 'US');

  LocaleCubit build() =>
      LocaleCubit(preferences: SharedPreferences.getInstance());

  group('LocaleCubit（app-settings：語言切換與持久化）', () {
    test('首次啟動預設 zh_TW，且沒有偏好時不另外 emit', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = build();
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state, zhTW);
      await cubit.close();
    });

    test('切換到 en_US 立即生效並寫入語言碼', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = build();
      await cubit.setLocale(enUS);
      expect(cubit.state, enUS);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(LocaleCubit.localeKey), 'en');
      await cubit.close();
    });

    test('以既有偏好建立時還原為完整的 en_US', () async {
      SharedPreferences.setMockInitialValues({LocaleCubit.localeKey: 'en'});
      final cubit = build();
      await cubit.stream.firstWhere((l) => l == enUS);
      expect(cubit.state, enUS);
      await cubit.close();
    });

    test('只有語言碼的 Locale 會正規化成支援清單中的完整 Locale', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = build();
      await cubit.setLocale(const Locale('en'));
      expect(cubit.state, enUS);
      await cubit.close();
    });

    test('不支援的語系被忽略且不寫入', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = build();
      await cubit.setLocale(const Locale('fr', 'FR'));
      expect(cubit.state, zhTW);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(LocaleCubit.localeKey), isNull);
      expect(cubit.isSupported(const Locale('fr')), isFalse);
      expect(cubit.isSupported(const Locale('zh')), isTrue);
      await cubit.close();
    });

    test('載入完成前使用者已切換 → 不被儲存的舊值覆蓋', () async {
      SharedPreferences.setMockInitialValues({LocaleCubit.localeKey: 'zh'});
      final cubit = build();
      await cubit.setLocale(enUS);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state, enUS);
      await cubit.close();
    });
  });
}
