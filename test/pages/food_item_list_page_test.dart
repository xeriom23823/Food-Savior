import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/bloc/food_item_list/food_item_list_bloc.dart';
import 'package:food_savior/bloc/used_food_item_list/used_food_item_list_bloc.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/models/food_list_grouping.dart';
import 'package:food_savior/pages/food_item_list/food_item_list_page.dart';
import 'package:food_savior/widgets/empty_state.dart';
import 'package:food_savior/widgets/food_item_group_card.dart';
import 'package:food_savior/widgets/section_header.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/hive_test_helper.dart';
import '../helpers/widget_test_helper.dart';

/// 頁面測試用假 Bloc：真實 Bloc 會做 Hive 磁碟 I/O，
/// 而 `testWidgets` 的 fake async 不會讓那些 Future 完成。
class MockFoodItemListBloc
    extends MockBloc<FoodItemListEvent, FoodItemListState>
    implements FoodItemListBloc {}

class MockUsedFoodItemListBloc
    extends MockBloc<UsedFoodItemListEvent, UsedFoodItemListState>
    implements UsedFoodItemListBloc {}

FoodItemListLoaded loadedWith(List<FoodItem> items) => FoodItemListLoaded(
      foodItems: items,
      grouping: FoodListGrouping.urgency,
      locations: const [],
      sections: buildSections(
        items: items,
        grouping: FoodListGrouping.urgency,
        now: testNow,
      ),
    );

void main() {
  late MockFoodItemListBloc bloc;
  late MockUsedFoodItemListBloc usedBloc;

  setUpAll(() {
    registerFallbackValue(const FoodItemListStarted());
    registerFallbackValue(const UsedFoodItemListStarted());
  });

  setUp(() {
    bloc = MockFoodItemListBloc();
    usedBloc = MockUsedFoodItemListBloc();
    when(() => usedBloc.state).thenReturn(
      UsedFoodItemListLoaded(usedFoodItems: const [], selectedDate: testNow),
    );
  });

  Future<void> pumpPage(
    WidgetTester tester, {
    required FoodItemListState state,
    Locale locale = const Locale('zh', 'TW'),
    Brightness brightness = Brightness.light,
  }) async {
    when(() => bloc.state).thenReturn(state);

    await tester.pumpWidget(wrapForTest(
      MultiBlocProvider(
        providers: [
          BlocProvider<FoodItemListBloc>.value(value: bloc),
          BlocProvider<UsedFoodItemListBloc>.value(value: usedBloc),
        ],
        child: const FoodItemListPage(),
      ),
      locale: locale,
      brightness: brightness,
    ));
    await tester.pump();
  }

  testWidgets('清單為空時顯示引導而不是空白', (tester) async {
    await pumpPage(tester, state: loadedWith(const []));

    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text('冰箱還空著'), findsOneWidget);
  });

  testWidgets('依急迫度分群並顯示每群筆數，空的分群不出現', (tester) async {
    await pumpPage(
      tester,
      state: loadedWith([
        makeFood(id: 'soon', name: '牛奶', daysToExpire: 1),
        makeFood(id: 'plenty', name: '罐頭', daysToExpire: 30),
        makeFood(id: 'unknown', name: '不明物體', daysToExpire: null),
      ]),
    );

    expect(find.byType(SectionHeader), findsNWidgets(3));
    expect(find.text('3 天內'), findsOneWidget);
    expect(find.text('充裕'), findsOneWidget);
    expect(find.text('期限未知'), findsOneWidget);
    expect(find.text('已過期'), findsNothing);
    expect(find.byType(FoodItemGroupCard), findsNWidgets(3));
  });

  testWidgets('待補期限的項目帶徽章', (tester) async {
    await pumpPage(
      tester,
      state: loadedWith([
        makeFood(id: 'x', name: '不明物體', daysToExpire: null),
      ]),
    );

    expect(find.text('待補期限'), findsOneWidget);
  });

  testWidgets('快速新增只打名稱就派出事件，且輸入列清空', (tester) async {
    await pumpPage(tester, state: loadedWith(const []));

    await tester.enterText(find.byType(TextField), '香蕉');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    final captured = verify(() => bloc.add(captureAny())).captured;
    expect(
      captured.whereType<FoodItemListQuickAdd>().single.name,
      '香蕉',
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      isEmpty,
    );
  });

  testWidgets('連續快速新增：送出後輸入列保持聚焦', (tester) async {
    await pumpPage(tester, state: loadedWith(const []));

    await tester.enterText(find.byType(TextField), '香蕉');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    final focusNode =
        tester.widget<TextField>(find.byType(TextField)).focusNode;
    expect(focusNode?.hasFocus, isTrue);
  });

  testWidgets('過期處理可以選浪費原因，並帶進完成事件', (tester) async {
    await pumpPage(
      tester,
      state: FoodItemListNeedProcessing(
        remainFoodItems: const [],
        expiredFoodItems: [makeFood(id: 'old', name: '舊優格', daysToExpire: -2)],
        isConsumed: const [false],
      ),
    );

    await tester.tap(find.text('忘記吃'));
    await tester.pump();
    await tester.tap(find.text('處理完成'));
    await tester.pump();

    final captured = verify(() => bloc.add(captureAny())).captured;
    expect(
      captured.whereType<FoodItemListProcessComplete>().single.wasteReason,
      WasteReason.forgotten,
    );
  });

  testWidgets('同名批次收合成一張卡', (tester) async {
    await pumpPage(
      tester,
      state: loadedWith([
        makeFood(id: 'a', name: '雞蛋', amount: 10, daysToExpire: 1),
        makeFood(id: 'b', name: '雞蛋', amount: 8, daysToExpire: 10),
      ]),
    );

    expect(find.byType(FoodItemGroupCard), findsOneWidget);
    expect(find.textContaining('2 批'), findsOneWidget);
  });

  testWidgets('深色主題與英文語系都能渲染', (tester) async {
    await pumpPage(
      tester,
      state: loadedWith([makeFood(id: 'a', name: 'Milk', daysToExpire: 2)]),
      locale: const Locale('en', 'US'),
      brightness: Brightness.dark,
    );

    expect(find.text('Within 3 days'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('有過期項目時先進入過期處理頁', (tester) async {
    await pumpPage(
      tester,
      state: FoodItemListNeedProcessing(
        remainFoodItems: const [],
        expiredFoodItems: [makeFood(id: 'old', name: '舊優格', daysToExpire: -2)],
        isConsumed: const [false],
      ),
    );

    expect(find.text('過期食物清單'), findsOneWidget);
    expect(find.text('舊優格'), findsOneWidget);
    expect(find.text('處理完成'), findsOneWidget);
  });

  testWidgets('載入失敗時可以重試', (tester) async {
    await pumpPage(
      tester,
      state: const FoodItemListError(message: 'boom'),
    );

    expect(find.text('載入失敗，請重試'), findsOneWidget);
    await tester.tap(find.text('重新整理'));
    await tester.pump();

    final captured = verify(() => bloc.add(captureAny())).captured;
    expect(captured.whereType<FoodItemListStarted>(), hasLength(1));
  });
}
