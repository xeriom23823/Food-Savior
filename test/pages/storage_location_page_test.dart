import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/cubits/storage_location_cubit.dart';
import 'package:food_savior/models/storage_location.dart';
import 'package:food_savior/pages/storage_location_page.dart';
import 'package:food_savior/widgets/empty_state.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/hive_test_helper.dart';
import '../helpers/widget_test_helper.dart';

class MockStorageLocationCubit extends MockCubit<StorageLocationState>
    implements StorageLocationCubit {}

void main() {
  late MockStorageLocationCubit cubit;

  setUpAll(() => registerFallbackValue(makeLocation()));

  setUp(() {
    cubit = MockStorageLocationCubit();
    when(() => cubit.itemCountOf(any())).thenReturn(0);
  });

  Future<void> pumpPage(
    WidgetTester tester, {
    required List<StorageLocation> locations,
    Locale locale = const Locale('zh', 'TW'),
    Brightness brightness = Brightness.light,
  }) async {
    when(() => cubit.state)
        .thenReturn(StorageLocationState(locations: locations));

    await tester.pumpWidget(wrapForTest(
      BlocProvider<StorageLocationCubit>.value(
        value: cubit,
        child: const StorageLocationPage(),
      ),
      locale: locale,
      brightness: brightness,
    ));
    await tester.pump();
  }

  testWidgets('沒有位置時顯示引導', (tester) async {
    await pumpPage(tester, locations: const []);

    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text('還沒有存放位置'), findsOneWidget);
  });

  testWidgets('列出位置並顯示存放方式', (tester) async {
    await pumpPage(tester, locations: [
      makeLocation(id: 'a', name: '蔬果室'),
      makeLocation(id: 'b', name: '冷凍庫', kind: LocationKind.frozen),
    ]);

    expect(find.text('蔬果室'), findsOneWidget);
    expect(find.text('冷凍庫'), findsOneWidget);
    expect(find.text('冷藏'), findsOneWidget);
    expect(find.text('冷凍'), findsOneWidget);
  });

  testWidgets('從別的頁面 push 過來時能取得 Cubit（回歸：Provider not found）', (tester) async {
    when(() => cubit.state)
        .thenReturn(StorageLocationState(locations: [makeLocation()]));

    await tester.pumpWidget(wrapForTest(
      BlocProvider<StorageLocationCubit>.value(
        value: cubit,
        child: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              // 頁面用同樣的方式把 Cubit 帶進推出去的路由。
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<StorageLocationCubit>(),
                    child: const StorageLocationPage(),
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('存放位置'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('英文語系與深色主題都能渲染', (tester) async {
    await pumpPage(
      tester,
      locations: [makeLocation(name: 'Top shelf')],
      locale: const Locale('en', 'US'),
      brightness: Brightness.dark,
    );

    expect(find.text('Top shelf'), findsOneWidget);
    expect(find.text('Add location'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
