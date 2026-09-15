import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/app/bloc/app_bloc.dart';
import 'package:food_savior/bloc/used_food_item_list/used_food_item_list_bloc.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/models/food_points_summary.dart';
import 'package:food_savior/pages/user_page.dart';
import 'package:food_savior/repositories/backup_repository.dart';
import 'package:food_savior/repositories/used_food_item_repository.dart';
import 'package:food_savior/widgets/empty_state.dart';
import 'package:hive_ce/hive.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/hive_test_helper.dart';
import '../helpers/widget_test_helper.dart';

class MockAppBloc extends MockBloc<AppEvent, AppState> implements AppBloc {}

class MockUsedFoodItemListBloc
    extends MockBloc<UsedFoodItemListEvent, UsedFoodItemListState>
    implements UsedFoodItemListBloc {}

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

class MockBackupRepository extends Mock implements BackupRepository {}

void main() {
  final env = HiveTestEnv();
  late Box<UsedFoodItem> box;
  late UsedFoodItemRepository repo;
  late MockAppBloc appBloc;
  late MockUsedFoodItemListBloc usedBloc;
  late MockAuthenticationRepository authRepository;

  setUpAll(env.setUpAll);
  tearDownAll(env.tearDownAll);

  setUp(() async {
    box = await env.openBox<UsedFoodItem>('usedFoodItems');
    repo = UsedFoodItemRepository(usedFoodItemBox: box);
    appBloc = MockAppBloc();
    usedBloc = MockUsedFoodItemListBloc();
    authRepository = MockAuthenticationRepository();

    when(() => usedBloc.state).thenReturn(
      UsedFoodItemListLoaded(usedFoodItems: const [], selectedDate: testNow),
    );
  });

  tearDown(() => box.deleteFromDisk());

  void givenUser({String? name, String? email = 'a@b.c'}) {
    when(() => appBloc.state).thenReturn(
      AppState.authenticated(User(id: 'uid', email: email, name: name)),
    );
  }

  Future<void> pumpPage(
    WidgetTester tester, {
    FoodPointsSummary? summary,
    Locale locale = const Locale('zh', 'TW'),
    Brightness brightness = Brightness.light,
  }) async {
    await tester.pumpWidget(wrapForTest(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<UsedFoodItemRepository>.value(value: repo),
          RepositoryProvider<AuthenticationRepository>.value(
            value: authRepository,
          ),
          RepositoryProvider<BackupRepository>.value(
            value: MockBackupRepository(),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AppBloc>.value(value: appBloc),
            BlocProvider<UsedFoodItemListBloc>.value(value: usedBloc),
          ],
          child: const UserPage(),
        ),
      ),
      locale: locale,
      brightness: brightness,
    ));
    await tester.pump();
  }

  testWidgets('沒有紀錄時成績區是引導而不是 0 分', (tester) async {
    givenUser(name: '小明');

    await pumpPage(tester);

    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text('還沒有成績可以看'), findsOneWidget);
    // 沒有紀錄就不該出現等級卡與里程碑
    expect(find.text('里程碑'), findsNothing);
  });

  testWidgets('有紀錄時顯示等級、三個數字與里程碑', (tester) async {
    await tester.runAsync(() => repo.saveUsedFoodItems([
          makeUsed(id: 'a', affectFoodPoint: 3),
          makeUsed(id: 'b', affectFoodPoint: 2),
        ]));
    givenUser(name: '小明');

    await pumpPage(tester);

    expect(find.text('我的成績'), findsOneWidget);
    expect(find.text('食物見習生'), findsOneWidget);
    expect(find.text('累計點數'), findsOneWidget);
    expect(find.text('本週'), findsOneWidget);
    // 累計與本週都是 5，所以會出現兩次。
    expect(find.text('5 點'), findsNWidgets(2));
    await tester.scrollUntilVisible(
      find.text('踏出第一步'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('踏出第一步'), findsOneWidget);
    // 未達成的里程碑也要看得見
    expect(find.text('五百俱樂部'), findsOneWidget);
  });

  testWidgets('沒有顯示名稱時提示去設定，而不是一片空白', (tester) async {
    givenUser(name: null);

    await pumpPage(tester);

    expect(find.text('設定名稱'), findsOneWidget);
    expect(find.text('a@b.c'), findsOneWidget);
  });

  testWidgets('帳號區有備份、還原、重設密碼、登出、刪除帳號', (tester) async {
    givenUser(name: '小明');

    await pumpPage(tester);

    for (final label in ['備份', '還原', '重設密碼', '登出', '刪除帳號']) {
      await tester.scrollUntilVisible(
        find.text(label),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('刪除帳號要先確認，取消就不刪', (tester) async {
    givenUser(name: '小明');

    await pumpPage(tester);
    final deleteTile = find.byKey(const Key('UserPage_delete_account_button'));
    await tester.scrollUntilVisible(
      deleteTile,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    // scrollUntilVisible 只保證在可視範圍邊緣，還要完全露出來才點得到。
    await tester.ensureVisible(deleteTile);
    await tester.pumpAndSettle();
    await tester.tap(deleteTile);
    await tester.pumpAndSettle();

    expect(find.textContaining('無法復原'), findsOneWidget);
    expect(find.textContaining('不會被刪除'), findsOneWidget);

    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();

    verifyNever(() => authRepository.deleteAccount());
  });

  testWidgets('英文語系與深色主題都能渲染', (tester) async {
    await tester.runAsync(
      () => repo.saveUsedFoodItem(makeUsed(id: 'a', affectFoodPoint: 2)),
    );
    givenUser(name: 'Ming');

    await pumpPage(
      tester,
      locale: const Locale('en', 'US'),
      brightness: Brightness.dark,
    );

    expect(find.text('My progress'), findsOneWidget);
    expect(find.text('Rookie'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Delete account'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Delete account'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
