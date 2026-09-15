import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/models/food_item_group.dart';
import 'package:food_savior/widgets/amount_label.dart';
import 'package:food_savior/widgets/food_item_group_card.dart';
import 'package:food_savior/widgets/food_item_tile.dart';
import 'package:food_savior/widgets/status_chip.dart';

import '../helpers/hive_test_helper.dart';
import '../helpers/widget_test_helper.dart';

void main() {
  group('AmountLabel', () {
    test('整數不顯示 .0', () {
      expect(AmountLabel.formatNumber(1), '1');
      expect(AmountLabel.formatNumber(0.5), '0.5');
      expect(AmountLabel.formatNumber(2.25), '2.25');
    });

    testWidgets('以剩餘比例記錄時顯示文字而非數字', (tester) async {
      await tester.pumpWidget(wrapForTest(
        Scaffold(
          body: AmountLabel.of(makeFood(
            amount: null,
            unit: null,
            remainingFraction: RemainingFraction.half,
          )),
        ),
      ));

      expect(find.text('約一半'), findsOneWidget);
    });
  });

  group('FoodItemTile', () {
    testWidgets('期限未知時顯示待補期限徽章', (tester) async {
      await tester.pumpWidget(wrapForTest(
        Scaffold(
          body: FoodItemTile(
            item: makeFood(id: 'x', name: '不明物體', daysToExpire: null),
            now: testNow,
          ),
        ),
      ));

      expect(find.text('不明物體'), findsOneWidget);
      expect(find.byType(PendingExpiryBadge), findsOneWidget);
    });

    testWidgets('有期限時顯示剩餘天數，深色主題也能渲染', (tester) async {
      await tester.pumpWidget(wrapForTest(
        Scaffold(
          body: FoodItemTile(
            item: makeFood(id: 'x', name: '牛奶', daysToExpire: 5),
            now: testNow,
          ),
        ),
        brightness: Brightness.dark,
      ));

      expect(find.text('5 天後到期'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('近似期限用不同語氣', (tester) async {
      await tester.pumpWidget(wrapForTest(
        Scaffold(
          body: FoodItemTile(
            item: makeFood(
              id: 'x',
              expiry: null,
              daysToExpire: 5,
            ).copyWith(expiryPrecision: ExpiryPrecision.range),
            now: testNow,
          ),
        ),
      ));

      expect(find.text('約 5 天後到期'), findsOneWidget);
    });

    testWidgets('英文語系不溢出', (tester) async {
      await tester.pumpWidget(wrapForTest(
        Scaffold(
          body: FoodItemTile(
            item:
                makeFood(id: 'x', name: 'Organic whole milk', daysToExpire: 5),
            now: testNow,
          ),
        ),
        locale: const Locale('en', 'US'),
      ));

      expect(find.text('Expires in 5 days'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('FoodItemGroupCard', () {
    testWidgets('單筆時退化成一般列，多筆時可展開看批次', (tester) async {
      final group = FoodItemGroup.groupAll([
        makeFood(id: 'a', name: '雞蛋', amount: 10, daysToExpire: 1),
        makeFood(id: 'b', name: '雞蛋', amount: 8, daysToExpire: 10),
      ]).single;

      await tester.pumpWidget(wrapForTest(
        Scaffold(body: FoodItemGroupCard(group: group, now: testNow)),
      ));

      expect(find.text('雞蛋'), findsOneWidget);
      expect(find.textContaining('18'), findsOneWidget);
      expect(find.textContaining('2 批'), findsOneWidget);

      await tester.tap(find.text('雞蛋'));
      await tester.pumpAndSettle();

      expect(find.byType(FoodItemTile), findsNWidgets(2));
    });
  });
}
