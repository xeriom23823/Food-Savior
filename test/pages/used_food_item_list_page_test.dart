import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/bloc/used_food_item_list/used_food_item_list_bloc.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/pages/used_food_item_list_page.dart';
import 'package:food_savior/widgets/empty_state.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/hive_test_helper.dart';
import '../helpers/widget_test_helper.dart';

class MockUsedFoodItemListBloc
    extends MockBloc<UsedFoodItemListEvent, UsedFoodItemListState>
    implements UsedFoodItemListBloc {}

void main() {
  late MockUsedFoodItemListBloc bloc;

  setUpAll(() => registerFallbackValue(const UsedFoodItemListStarted()));
  setUp(() => bloc = MockUsedFoodItemListBloc());

  Future<void> pumpPage(
    WidgetTester tester, {
    required List<UsedFoodItem> items,
    UsedFoodFilter filter = UsedFoodFilter.all,
    Locale locale = const Locale('zh', 'TW'),
    Brightness brightness = Brightness.light,
  }) async {
    when(() => bloc.state).thenReturn(UsedFoodItemListLoaded(
      usedFoodItems: items,
      selectedDate: testNow,
      filter: filter,
    ));

    await tester.pumpWidget(wrapForTest(
      BlocProvider<UsedFoodItemListBloc>.value(
        value: bloc,
        child: const UsedFoodItemListPage(),
      ),
      locale: locale,
      brightness: brightness,
    ));
    await tester.pump();
  }

  testWidgets('這天沒有紀錄時顯示空狀態', (tester) async {
    await pumpPage(tester, items: const []);

    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text('這天沒有紀錄'), findsOneWidget);
  });

  testWidgets('紀錄列顯示處理方式、原因、金額與點數', (tester) async {
    await pumpPage(tester, items: [
      makeUsed(
        id: 'x',
        name: '牛奶',
        disposalMethod: DisposalMethod.discarded,
        wasteReason: WasteReason.forgotten,
        priceTotal: 45,
        affectFoodPoint: -2,
      ),
    ]);

    expect(find.text('牛奶'), findsOneWidget);
    expect(find.textContaining('丟棄'), findsOneWidget);
    expect(find.textContaining('忘記吃'), findsOneWidget);
    expect(find.textContaining('45 元'), findsOneWidget);
    expect(find.text('-2 點'), findsOneWidget);
  });

  testWidgets('沒填的欄位不佔版面', (tester) async {
    await pumpPage(tester, items: [makeUsed(id: 'x', name: '蘋果')]);

    expect(find.textContaining('未填原因'), findsNothing);
    expect(find.textContaining('元'), findsNothing);
  });

  testWidgets('切換篩選會派出事件', (tester) async {
    await pumpPage(tester, items: const []);

    await tester.tap(find.text('浪費'));
    await tester.pump();

    final captured = verify(() => bloc.add(captureAny())).captured;
    expect(
      captured.whereType<UsedFoodItemListFilterChanged>().single.filter,
      UsedFoodFilter.wasted,
    );
  });

  testWidgets('深色主題與英文語系都能渲染', (tester) async {
    await pumpPage(
      tester,
      items: [makeUsed(id: 'x', name: 'Milk')],
      locale: const Locale('en', 'US'),
      brightness: Brightness.dark,
    );

    expect(find.text('Milk'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
