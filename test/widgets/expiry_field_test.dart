import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/models/expiry.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/widgets/expiry_field.dart';

import '../helpers/widget_test_helper.dart';

void main() {
  final now = DateTime(2026, 9, 15, 14, 30);

  Future<List<ExpiryValue>> pump(
    WidgetTester tester, {
    required ExpiryValue value,
    Locale locale = const Locale('zh', 'TW'),
    Brightness brightness = Brightness.light,
  }) async {
    final changes = <ExpiryValue>[];

    await tester.pumpWidget(wrapForTest(
      Scaffold(
        body: SingleChildScrollView(
          child: ExpiryField(
            value: value,
            now: now,
            onChanged: changes.add,
          ),
        ),
      ),
      locale: locale,
      brightness: brightness,
    ));
    await tester.pump();

    return changes;
  }

  group('快速選項', () {
    testWidgets('精確到日時顯示六個選項', (tester) async {
      await pump(tester, value: ExpiryValue.exact(DateTime(2026, 9, 20)));

      for (final label in ['今天', '明天', '3 天後', '1 週後', '2 週後', '1 個月後']) {
        expect(find.text(label), findsOneWidget, reason: '缺少「$label」');
      }
    });

    // 使用者回報的情境：今天就要喝掉的飲料，原本要開日期選擇器按四下。
    testWidgets('點「今天」直接把期限設為今天', (tester) async {
      final changes =
          await pump(tester, value: ExpiryValue.exact(DateTime(2026, 9, 22)));

      await tester.tap(find.text('今天'));

      expect(changes, hasLength(1));
      expect(changes.single.earliest, DateTime(2026, 9, 15));
      expect(changes.single.precision, ExpiryPrecision.exact);
    });

    testWidgets('點「1 週後」設為七天後', (tester) async {
      final changes =
          await pump(tester, value: ExpiryValue.exact(DateTime(2026, 9, 15)));

      await tester.tap(find.text('1 週後'));

      expect(changes.single.earliest, DateTime(2026, 9, 22));
    });

    testWidgets('點選項不需要開啟日期選擇器', (tester) async {
      await pump(tester, value: ExpiryValue.exact(DateTime(2026, 9, 22)));

      await tester.tap(find.text('今天'));
      await tester.pump();

      // 完整選擇器會出現 OK／取消，這裡不該有。
      expect(find.byType(DatePickerDialog), findsNothing);
    });
  });

  group('選中狀態', () {
    ChoiceChip chipFor(WidgetTester tester, String label) => tester.widget(
          find.ancestor(
            of: find.text(label),
            matching: find.byType(ChoiceChip),
          ),
        );

    testWidgets('目前值等於某個選項時該選項選中', (tester) async {
      await pump(tester, value: ExpiryValue.exact(DateTime(2026, 9, 16)));

      expect(chipFor(tester, '明天').selected, isTrue);
      expect(chipFor(tester, '今天').selected, isFalse);
      expect(chipFor(tester, '1 週後').selected, isFalse);
    });

    testWidgets('目前值不等於任何選項時全部未選中', (tester) async {
      await pump(tester, value: ExpiryValue.exact(DateTime(2026, 9, 17)));

      for (final label in ['今天', '明天', '3 天後', '1 週後', '2 週後', '1 個月後']) {
        expect(chipFor(tester, label).selected, isFalse,
            reason: '「$label」不該選中');
      }
    });

    testWidgets('過去的日期不會讓任何選項選中', (tester) async {
      await pump(tester, value: ExpiryValue.exact(DateTime(2026, 9, 1)));

      expect(chipFor(tester, '今天').selected, isFalse);
    });
  });

  group('其他精度不顯示快速選項', () {
    testWidgets('區間', (tester) async {
      await pump(
        tester,
        value: ExpiryValue.range(DateTime(2026, 9, 20), DateTime(2026, 9, 23)),
      );

      expect(find.byType(ChoiceChip), findsNothing);
    });

    testWidgets('只到月', (tester) async {
      await pump(tester, value: ExpiryValue.month(2026, 10));

      expect(find.byType(ChoiceChip), findsNothing);
    });

    testWidgets('不知道', (tester) async {
      await pump(tester, value: const ExpiryValue.unknown());

      expect(find.byType(ChoiceChip), findsNothing);
    });
  });

  group('完整日期選擇器仍可用', () {
    testWidgets('點日期按鈕會開啟選擇器', (tester) async {
      await pump(tester, value: ExpiryValue.exact(DateTime(2026, 9, 20)));

      await tester.tap(find.text('2026-09-20'));
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerDialog), findsOneWidget);
    });
  });

  group('主題與語系', () {
    testWidgets('暗色主題可繪製', (tester) async {
      await pump(
        tester,
        value: ExpiryValue.exact(DateTime(2026, 9, 15)),
        brightness: Brightness.dark,
      );

      expect(tester.takeException(), isNull);
      expect(find.text('今天'), findsOneWidget);
    });

    testWidgets('英文語系顯示英文標籤', (tester) async {
      await pump(
        tester,
        value: ExpiryValue.exact(DateTime(2026, 9, 15)),
        locale: const Locale('en'),
      );

      expect(find.text('Today'), findsOneWidget);
      expect(find.text('In 1 week'), findsOneWidget);
    });
  });
}
