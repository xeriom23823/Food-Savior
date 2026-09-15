import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/models/expiry.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/pages/food_item_list/food_item_detail_sheet.dart';

import '../helpers/hive_test_helper.dart';
import '../helpers/widget_test_helper.dart';

void main() {
  Future<void> pumpSheet(WidgetTester tester, FoodItem item) async {
    await tester.pumpWidget(wrapForTest(
      Scaffold(
        body: FoodItemDetailSheet(
          item: item,
          now: testNow,
          location: makeLocation(name: '蔬果室'),
        ),
      ),
    ));
    await tester.pump();
  }

  testWidgets('欄位標籤正確：類型不會被標成描述', (tester) async {
    await pumpSheet(
      tester,
      makeFood(
        id: 'x',
        name: '牛奶',
        type: FoodItemType.eggAndMilk,
        amount: 1,
        unit: Unit.bottle,
        storageLocationId: 'loc',
      ),
    );

    expect(find.text('類型'), findsOneWidget);
    expect(find.text('蛋奶類'), findsOneWidget);
    // 沒填描述時不顯示描述列。
    expect(find.text('描述'), findsNothing);
    expect(find.text('蔬果室'), findsOneWidget);
  });

  testWidgets('區間期限顯示兩個日期', (tester) async {
    await pumpSheet(
      tester,
      makeFood(
        id: 'x',
        expiry: ExpiryValue.range(daysFromNow(3), daysFromNow(6)),
      ),
    );

    expect(find.textContaining('~'), findsOneWidget);
  });

  testWidgets('期限未知時顯示未知而不是空白', (tester) async {
    await pumpSheet(tester, makeFood(id: 'x', daysToExpire: null));

    // 狀態 chip 與期限欄位都會顯示「期限未知」。
    expect(find.text('期限未知'), findsNWidgets(2));
    expect(find.text('補期限'), findsOneWidget);
  });

  testWidgets('已開封時顯示開封日與開封後天數', (tester) async {
    await pumpSheet(
      tester,
      makeFood(
        id: 'x',
        daysToExpire: 10,
        openedDate: testNow,
        shelfLifeAfterOpenDays: 3,
      ),
    );

    expect(find.textContaining('開封後 3 天'), findsOneWidget);
    expect(find.text('標記開封'), findsNothing);
  });
}
