import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/models/storage_location.dart';
import 'package:food_savior/pages/food_item_list/food_item_form_page.dart';
import 'package:food_savior/widgets/expiry_field.dart';
import 'package:food_savior/widgets/location_picker.dart';

import '../helpers/hive_test_helper.dart';
import '../helpers/widget_test_helper.dart';

void main() {
  Future<void> pumpForm(
    WidgetTester tester, {
    FoodItem? original,
    List<StorageLocation> locations = const [],
    Locale locale = const Locale('zh', 'TW'),
    Brightness brightness = Brightness.light,
  }) async {
    await tester.pumpWidget(wrapForTest(
      FoodItemFormPage(
        original: original,
        locations: locations,
        now: testNow,
      ),
      locale: locale,
      brightness: brightness,
    ));
    await tester.pump();
  }

  testWidgets('新增表單渲染出所有欄位，不是空白頁', (tester) async {
    await pumpForm(tester, locations: [makeLocation()]);

    expect(find.text('新增食物'), findsWidgets);
    expect(find.text('名稱'), findsOneWidget);
    expect(find.text('類型'), findsOneWidget);
    expect(find.text('份量'), findsOneWidget);
    expect(find.byType(LocationPicker), findsOneWidget);
    expect(find.byType(ExpiryField), findsOneWidget);
    expect(find.text('存放日期'), findsOneWidget);
    expect(find.text('儲存'), findsWidgets);
    expect(tester.takeException(), isNull);

    // 表單很長，下半部要捲到才會建立。
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pump();
    expect(find.text('已開封'), findsOneWidget);
    expect(find.text('金額（元）'), findsOneWidget);
  });

  testWidgets('沒有任何存放位置時仍然渲染（位置是選填）', (tester) async {
    await pumpForm(tester);

    expect(find.byType(LocationPicker), findsOneWidget);
    expect(find.text('未指定位置'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('名稱為空時擋下並顯示錯誤', (tester) async {
    await pumpForm(tester);

    // AppBar 上的儲存永遠看得到，不受捲動影響。
    await tester.tap(find.widgetWithText(TextButton, '儲存'));
    await tester.pump();

    expect(find.text('名稱不能為空'), findsOneWidget);
  });

  testWidgets('填名稱後送出回傳建立好的項目', (tester) async {
    FoodItem? result;
    await tester.pumpWidget(wrapForTest(
      Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            result = await Navigator.of(context).push<FoodItem>(
              MaterialPageRoute(
                builder: (_) => FoodItemFormPage(
                  locations: const [],
                  now: testNow,
                ),
              ),
            );
          },
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '牛奶');
    await tester.tap(find.widgetWithText(TextButton, '儲存'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.name, '牛奶');
    expect(result!.amount, 1);
    expect(result!.expiryPrecision, ExpiryPrecision.exact);
    expect(result!.expiryEarliest, daysFromNow(7));
  });

  testWidgets('切換成剩餘比例後份量欄位換成比例選項', (tester) async {
    await pumpForm(tester);

    await tester.tap(find.text('改用剩餘比例'));
    await tester.pump();

    expect(find.text('約一半'), findsOneWidget);
    expect(find.text('改用數量'), findsOneWidget);
  });

  testWidgets('期限可切換成「不知道」', (tester) async {
    await pumpForm(tester);

    await tester.tap(find.text('不知道'));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('編輯既有項目時帶入原值', (tester) async {
    await pumpForm(
      tester,
      original: makeFood(id: 'x', name: '優格', amount: 2, priceTotal: 45),
      locations: [makeLocation()],
    );

    expect(find.text('編輯食物'), findsWidgets);
    expect(find.text('優格'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pump();
    expect(find.text('45'), findsOneWidget);
  });

  testWidgets('英文語系與深色主題都能渲染', (tester) async {
    await pumpForm(
      tester,
      locale: const Locale('en', 'US'),
      brightness: Brightness.dark,
    );

    expect(find.text('Add food'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
