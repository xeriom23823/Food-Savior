import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/bloc/import/import_bloc.dart';
import 'package:food_savior/domain/import/food_item_draft.dart';
import 'package:food_savior/models/expiry.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/pages/import/import_drafts_page.dart';
import 'package:food_savior/pages/import/import_draft_sheet.dart';
import 'package:food_savior/widgets/empty_state.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/hive_test_helper.dart';
import '../helpers/widget_test_helper.dart';

class MockImportBloc extends MockBloc<ImportEvent, ImportState>
    implements ImportBloc {}

final DateTime issuedDate = DateTime(2026, 9, 15);

FoodItemDraft makeDraft({
  String name = '雞蛋',
  String? sourceLine,
  FoodItemType type = FoodItemType.eggAndMilk,
  double? amount = 1,
  Unit? unit = Unit.piece,
  int? priceTotal = 89,
  bool excluded = false,
  bool needsReview = false,
}) =>
    FoodItemDraft(
      sourceLine: sourceLine ?? name,
      name: name,
      type: type,
      expiry: ExpiryValue.exact(issuedDate.add(const Duration(days: 21))),
      storageDate: issuedDate,
      amount: amount,
      unit: unit,
      priceTotal: priceTotal,
      excluded: excluded,
      needsReview: needsReview,
    );

void main() {
  late MockImportBloc bloc;

  // captureAny 需要一個 fallback 實例才能用在 ImportEvent 這種自訂型別上。
  setUpAll(() => registerFallbackValue(const ImportSubmitted()));

  setUp(() => bloc = MockImportBloc());

  Future<void> pump(
    WidgetTester tester,
    ImportDrafts state, {
    Locale locale = const Locale('zh', 'TW'),
    Brightness brightness = Brightness.light,
  }) async {
    when(() => bloc.state).thenReturn(state);

    await tester.pumpWidget(wrapForTest(
      BlocProvider<ImportBloc>.value(
        value: bloc,
        child: Scaffold(body: ImportDraftsPage(state: state)),
      ),
      locale: locale,
      brightness: brightness,
    ));
    await tester.pump();
  }

  ImportDrafts draftsState(
    List<FoodItemDraft> drafts, {
    bool itemsIncomplete = false,
  }) =>
      ImportDrafts(
        invoiceNumber: 'AB12345678',
        drafts: drafts,
        itemsIncomplete: itemsIncomplete,
        locations: [makeLocation(id: 'fridge', name: '冷藏')],
        now: DateTime(2026, 9, 15),
      );

  testWidgets('每一列顯示名稱、類型與金額', (tester) async {
    await pump(tester, draftsState([makeDraft()]));

    expect(find.text('雞蛋'), findsOneWidget);
    expect(find.textContaining('蛋奶類'), findsOneWidget);
    expect(find.textContaining('NT\$89'), findsOneWidget);
  });

  testWidgets('原始品名一律顯示供對照發票', (tester) async {
    await pump(
      tester,
      draftsState([makeDraft(name: '優酪乳', sourceLine: '統一AB優酪乳400ML特價')]),
    );

    expect(find.text('發票品名：統一AB優酪乳400ML特價'), findsOneWidget);
  });

  testWidgets('沒命中建議的列標示待確認', (tester) async {
    await pump(
      tester,
      draftsState([
        makeDraft(name: '環保購物袋', type: FoodItemType.others, needsReview: true),
      ]),
    );

    expect(find.text('待確認'), findsOneWidget);
  });

  testWidgets('命中建議的列不顯示待確認', (tester) async {
    await pump(tester, draftsState([makeDraft()]));

    expect(find.text('待確認'), findsNothing);
  });

  testWidgets('按鈕顯示會被匯入的筆數，排除的不算', (tester) async {
    await pump(
      tester,
      draftsState([
        makeDraft(name: 'a'),
        makeDraft(name: 'b'),
        makeDraft(name: 'c', excluded: true),
      ]),
    );

    expect(find.text('全部加入（2）'), findsOneWidget);
  });

  testWidgets('全部排除時按鈕停用', (tester) async {
    await pump(
      tester,
      draftsState([
        makeDraft(name: 'a', excluded: true),
        makeDraft(name: 'b', excluded: true),
      ]),
    );

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('排除按鈕派發 toggle 事件', (tester) async {
    await pump(tester, draftsState([makeDraft()]));

    await tester.tap(find.byTooltip('排除這項'));
    verify(() => bloc.add(const ImportDraftToggled(index: 0))).called(1);
  });

  testWidgets('已排除的列提供加回', (tester) async {
    await pump(tester, draftsState([makeDraft(excluded: true)]));

    expect(find.byTooltip('加回這項'), findsOneWidget);
  });

  testWidgets('按下全部加入派發送出事件', (tester) async {
    await pump(tester, draftsState([makeDraft()]));

    await tester.tap(find.byType(FilledButton));
    verify(() => bloc.add(const ImportSubmitted())).called(1);
  });

  testWidgets('品項不完整時顯示提醒', (tester) async {
    await pump(
      tester,
      draftsState([makeDraft()], itemsIncomplete: true),
    );

    expect(find.text('發票上還有品項沒讀到，請自行補齊'), findsOneWidget);
  });

  testWidgets('沒有任何品項時顯示空狀態', (tester) async {
    await pump(tester, draftsState(const []));

    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text('這張發票沒有可匯入的品項'), findsOneWidget);
  });

  group('主題與語系', () {
    testWidgets('暗色主題可繪製', (tester) async {
      await pump(
        tester,
        draftsState([makeDraft(needsReview: true)]),
        brightness: Brightness.dark,
      );

      expect(tester.takeException(), isNull);
      expect(find.text('待確認'), findsOneWidget);
    });

    testWidgets('英文語系顯示英文字串', (tester) async {
      await pump(
        tester,
        draftsState([makeDraft(needsReview: true)]),
        locale: const Locale('en'),
      );

      expect(find.text('Check this'), findsOneWidget);
      expect(find.text('Add all (1)'), findsOneWidget);
    });
  });

  group('編輯入口（einvoice-import 規格：每一列可編輯六個欄位）', () {
    // 先前的實作只有名稱編輯，使用者因此「選不到」期限。
    testWidgets('點擊未排除的列會開啟編輯 sheet', (tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await pump(tester, draftsState([makeDraft()]));

      await tester.tap(find.text('雞蛋'));
      await tester.pumpAndSettle();

      expect(find.byType(ImportDraftSheet), findsOneWidget);
      // 六個欄位都要在同一張 sheet 裡。
      expect(find.text('今天'), findsOneWidget);
      expect(
          find.byType(DropdownButtonFormField<FoodItemType>), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<Unit>), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String?>), findsOneWidget);
    });

    testWidgets('已排除的列不開啟編輯', (tester) async {
      await pump(tester, draftsState([makeDraft(excluded: true)]));

      await tester.tap(find.text('雞蛋'));
      await tester.pumpAndSettle();

      expect(find.byType(ImportDraftSheet), findsNothing);
    });

    testWidgets('sheet 儲存後派發 ImportDraftChanged', (tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await pump(tester, draftsState([makeDraft(needsReview: true)]));

      await tester.tap(find.text('雞蛋'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('今天'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('今天'));
      await tester.pumpAndSettle();
      final save = find.text('儲存');
      await tester.ensureVisible(save);
      await tester.pumpAndSettle();
      await tester.tap(save);
      await tester.pumpAndSettle();

      final captured = verify(
        () => bloc.add(captureAny(that: isA<ImportDraftChanged>())),
      ).captured.single as ImportDraftChanged;

      expect(captured.index, 0);
      expect(captured.draft.expiry.earliest, DateTime(2026, 9, 15));
      // 使用者看過這一列了。
      expect(captured.draft.needsReview, isFalse);
    });
  });
}
