import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/pages/char_and_statistics_page.dart';
import 'package:food_savior/repositories/used_food_item_repository.dart';
import 'package:hive_ce/hive.dart';

import '../helpers/hive_test_helper.dart';
import '../helpers/widget_test_helper.dart';

void main() {
  final env = HiveTestEnv();
  late Box<UsedFoodItem> box;
  late UsedFoodItemRepository repo;

  setUpAll(env.setUpAll);
  tearDownAll(env.tearDownAll);
  setUp(() async {
    box = await env.openBox<UsedFoodItem>('usedFoodItems');
    repo = UsedFoodItemRepository(usedFoodItemBox: box);
  });
  tearDown(() => box.deleteFromDisk());

  Future<void> pumpPage(
    WidgetTester tester, {
    Locale locale = const Locale('zh', 'TW'),
    Brightness brightness = Brightness.light,
  }) async {
    await tester.pumpWidget(wrapForTest(
      RepositoryProvider<UsedFoodItemRepository>.value(
        value: repo,
        child: const ChartAndStatisticsPage(),
      ),
      locale: locale,
      brightness: brightness,
    ));
    await tester.pump();
  }

  testWidgets('沒有紀錄時顯示空狀態', (tester) async {
    await pumpPage(tester);

    expect(find.text('尚無資料'), findsWidgets);
  });

  testWidgets('有紀錄時列出全部區塊並標示點數規則變更', (tester) async {
    await tester.runAsync(() => repo.saveUsedFoodItems([
          makeUsed(id: 'a', disposalMethod: DisposalMethod.eaten),
          makeUsed(id: 'b', disposalMethod: DisposalMethod.discarded),
        ]));

    await pumpPage(tester);

    expect(find.text('食用筆數分布'), findsOneWidget);

    // 圖表很長，逐段捲到才會建立。
    for (final title in [
      '浪費筆數分布',
      '每月趨勢',
      '浪費率趨勢',
      '最常浪費的食物',
      '浪費原因分佈',
      '金額損益',
    ]) {
      await tester.scrollUntilVisible(
        find.text(title),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(title), findsOneWidget);
    }

    await tester.scrollUntilVisible(
      find.textContaining('點數規則自 2026-09-15'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('點數規則自 2026-09-15'), findsOneWidget);
  });

  testWidgets('浪費率 Y 軸標籤帶 % 且不折行（回歸：100 被折成兩行）', (tester) async {
    await tester.runAsync(() => repo.saveUsedFoodItems([
          makeUsed(id: 'a', disposalMethod: DisposalMethod.eaten),
          makeUsed(id: 'b', disposalMethod: DisposalMethod.discarded),
        ]));

    await pumpPage(tester);
    await tester.scrollUntilVisible(
      find.text('浪費率趨勢'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    // 標題進來後圖表本體還在下面，再捲一段才會建立軸標籤。
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -200));
    await tester.pump();

    expect(find.text('100%'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);
  });

  testWidgets('沒有金額時金額區塊給補填引導而不是 0 元', (tester) async {
    await tester.runAsync(() => repo.saveUsedFoodItem(makeUsed(id: 'a')));

    await pumpPage(tester);
    await tester.scrollUntilVisible(
      find.text('填寫金額後就能看到這裡的統計'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('填寫金額後就能看到這裡的統計'), findsOneWidget);
  });
}
