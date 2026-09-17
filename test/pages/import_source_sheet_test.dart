import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/pages/import/import_source_sheet.dart';

import '../helpers/widget_test_helper.dart';

void main() {
  Future<Future<ImportSource?>> open(
    WidgetTester tester, {
    Locale locale = const Locale('zh', 'TW'),
    Brightness brightness = Brightness.light,
  }) async {
    late Future<ImportSource?> result;
    await tester.pumpWidget(wrapForTest(
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => result = ImportSourceSheet.show(context),
            child: const Text('open'),
          ),
        ),
      ),
      locale: locale,
      brightness: brightness,
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('兩個來源各有說明', (tester) async {
    await open(tester);

    expect(find.text('要匯入哪一種單據？'), findsOneWidget);
    expect(find.text('掃描電子發票'), findsOneWidget);
    expect(find.textContaining('兩個二維條碼'), findsOneWidget);
    expect(find.text('拍攝紙本收據'), findsOneWidget);
    expect(find.textContaining('逐項確認'), findsOneWidget);
  });

  testWidgets('選發票回傳 einvoice', (tester) async {
    final result = await open(tester);

    await tester.tap(find.text('掃描電子發票'));
    await tester.pumpAndSettle();
    expect(await result, ImportSource.einvoice);
  });

  testWidgets('選收據回傳 receipt', (tester) async {
    final result = await open(tester);

    await tester.tap(find.text('拍攝紙本收據'));
    await tester.pumpAndSettle();
    expect(await result, ImportSource.receipt);
  });

  testWidgets('滑掉回傳 null', (tester) async {
    final result = await open(tester);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(await result, isNull);
  });

  testWidgets('英文深色', (tester) async {
    await open(tester, locale: const Locale('en'), brightness: Brightness.dark);

    expect(find.text('Scan an e-invoice'), findsOneWidget);
    expect(find.text('Photograph a paper receipt'), findsOneWidget);
  });
}
