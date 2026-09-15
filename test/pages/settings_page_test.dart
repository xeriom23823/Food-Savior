import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/cubits/locale_cubit.dart';
import 'package:food_savior/cubits/theme_cubit.dart';
import 'package:food_savior/pages/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/widget_test_helper.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pumpPage(
    WidgetTester tester, {
    Locale locale = const Locale('zh', 'TW'),
    Brightness brightness = Brightness.light,
  }) async {
    await tester.pumpWidget(wrapForTest(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeCubit()),
          BlocProvider(create: (_) => LocaleCubit()),
        ],
        child: const SettingsPage(),
      ),
      locale: locale,
      brightness: brightness,
    ));
    await tester.pump();
  }

  testWidgets('分區標題與項目都來自 l10n，沒有硬編碼字串', (tester) async {
    await pumpPage(tester);

    expect(find.text('偏好設定'), findsOneWidget);
    expect(find.text('關於'), findsOneWidget);
    expect(find.text('語言'), findsOneWidget);
    expect(find.text('黑夜模式'), findsOneWidget);
    expect(find.text('存放位置'), findsOneWidget);
    expect(find.text('版本'), findsOneWidget);
  });

  testWidgets('切換深色模式', (tester) async {
    await pumpPage(tester);

    expect(tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
        isFalse);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pump();

    expect(tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
        isTrue);
  });

  testWidgets('英文語系與深色主題都能渲染', (tester) async {
    await pumpPage(
      tester,
      locale: const Locale('en', 'US'),
      brightness: Brightness.dark,
    );

    expect(find.text('Preferences'), findsOneWidget);
    expect(find.text('Storage locations'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
