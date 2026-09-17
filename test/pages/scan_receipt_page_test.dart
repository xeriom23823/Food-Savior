import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/bloc/receipt_import/receipt_import_bloc.dart';
import 'package:food_savior/domain/import/food_item_draft.dart';
import 'package:food_savior/models/expiry.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/pages/import/import_drafts_page.dart';
import 'package:food_savior/pages/import/scan_receipt_page.dart';
import 'package:food_savior/services/ocr/receipt_image_picker.dart';
import 'package:food_savior/services/scanner/app_settings_opener.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/widget_test_helper.dart';

class MockReceiptImportBloc
    extends MockBloc<ReceiptImportEvent, ReceiptImportState>
    implements ReceiptImportBloc {}

/// 記錄有沒有被呼叫到，取代真正的系統設定跳轉。
class RecordingSettingsOpener extends AppSettingsOpener {
  RecordingSettingsOpener()
      : super(channel: const MethodChannel('test/app_settings'));

  int calls = 0;

  @override
  Future<bool> open() async {
    calls++;
    return true;
  }
}

final DateTime fixedNow = DateTime(2026, 9, 18, 10);

FoodItemDraft draft(String name) => FoodItemDraft(
      name: name,
      sourceLine: name,
      type: FoodItemType.others,
      amount: 1,
      unit: Unit.piece,
      storageDate: DateTime(2026, 9, 10),
      expiry: ExpiryValue.exact(DateTime(2026, 9, 17)),
      needsReview: true,
    );

void main() {
  late MockReceiptImportBloc bloc;
  late RecordingSettingsOpener settingsOpener;

  setUp(() {
    bloc = MockReceiptImportBloc();
    settingsOpener = RecordingSettingsOpener();
  });

  Future<void> pump(
    WidgetTester tester,
    ReceiptImportState state, {
    Locale locale = const Locale('zh', 'TW'),
    Brightness brightness = Brightness.light,
  }) async {
    when(() => bloc.state).thenReturn(state);

    await tester.pumpWidget(wrapForTest(
      BlocProvider<ReceiptImportBloc>.value(
        value: bloc,
        child: ScanReceiptPage(settingsOpener: settingsOpener),
      ),
      locale: locale,
      brightness: brightness,
    ));
    await tester.pump();
  }

  group('來源選擇', () {
    testWidgets('顯示拍照提示與兩個來源', (tester) async {
      await pump(tester, const ReceiptImportChoosingSource());

      expect(find.text('拍攝收據'), findsOneWidget);
      expect(find.textContaining('整張入鏡'), findsOneWidget);
      expect(find.text('拍照'), findsOneWidget);
      expect(find.text('從相簿選擇'), findsOneWidget);
    });

    testWidgets('按拍照派發 camera 來源', (tester) async {
      await pump(tester, const ReceiptImportChoosingSource());

      await tester.tap(find.text('拍照'));
      verify(() => bloc.add(
            const ReceiptImportSourceChosen(ReceiptImageSource.camera),
          )).called(1);
    });

    testWidgets('按相簿派發 gallery 來源', (tester) async {
      await pump(tester, const ReceiptImportChoosingSource());

      await tester.tap(find.text('從相簿選擇'));
      verify(() => bloc.add(
            const ReceiptImportSourceChosen(ReceiptImageSource.gallery),
          )).called(1);
    });

    testWidgets('英文版', (tester) async {
      await pump(
        tester,
        const ReceiptImportChoosingSource(),
        locale: const Locale('en'),
      );

      expect(find.text('Photograph receipt'), findsOneWidget);
      expect(find.text('Take photo'), findsOneWidget);
      expect(find.text('Choose from gallery'), findsOneWidget);
    });
  });

  group('辨識中', () {
    testWidgets('顯示進度與文字', (tester) async {
      await pump(tester, const ReceiptImportRecognizing());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('辨識中…'), findsOneWidget);
    });
  });

  group('不可用', () {
    testWidgets('權限被拒：前往設定與手動新增', (tester) async {
      await pump(
        tester,
        const ReceiptImportBlocked(
          reason: ReceiptImportBlock.permissionDenied,
        ),
      );

      expect(find.textContaining('需要相機或相簿'), findsOneWidget);
      expect(find.text('改為手動新增'), findsOneWidget);

      await tester.tap(find.text('前往設定'));
      await tester.pump();
      expect(settingsOpener.calls, 1);
    });

    testWidgets('辨識器未就緒：重試與手動新增', (tester) async {
      await pump(
        tester,
        const ReceiptImportBlocked(
          reason: ReceiptImportBlock.recognizerNotReady,
        ),
      );

      expect(find.textContaining('還在準備中'), findsOneWidget);
      expect(find.text('前往設定'), findsNothing);
      expect(find.text('改為手動新增'), findsOneWidget);

      await tester.tap(find.text('重試'));
      verify(() => bloc.add(const ReceiptImportRetried())).called(1);
    });

    testWidgets('英文版辨識器未就緒', (tester) async {
      await pump(
        tester,
        const ReceiptImportBlocked(
          reason: ReceiptImportBlock.recognizerNotReady,
        ),
        locale: const Locale('en'),
      );

      expect(find.textContaining('still getting ready'), findsOneWidget);
    });
  });

  group('空結果', () {
    testWidgets('沒有文字：重拍', (tester) async {
      await pump(
        tester,
        const ReceiptImportEmpty(kind: ReceiptImportEmptyKind.noText),
      );

      expect(find.textContaining('找不到任何文字'), findsOneWidget);
      await tester.tap(find.text('重拍'));
      verify(() => bloc.add(const ReceiptImportRetried())).called(1);
    });

    testWidgets('沒有品項：重拍或手動新增', (tester) async {
      await pump(
        tester,
        const ReceiptImportEmpty(kind: ReceiptImportEmptyKind.noItems),
      );

      expect(find.textContaining('看不出這張收據'), findsOneWidget);
      expect(find.text('重拍'), findsOneWidget);
      expect(find.text('改為手動新增'), findsOneWidget);
    });

    testWidgets('深色主題可渲染', (tester) async {
      await pump(
        tester,
        const ReceiptImportEmpty(kind: ReceiptImportEmptyKind.noItems),
        brightness: Brightness.dark,
      );

      expect(find.text('重拍'), findsOneWidget);
    });
  });

  group('草稿', () {
    testWidgets('重用 ImportDraftsPage 並顯示收據專屬提示', (tester) async {
      await pump(
        tester,
        ReceiptImportDrafts(
          drafts: [draft('鮮奶'), draft('雞蛋')],
          receiptDate: DateTime(2026, 9, 10),
          now: fixedNow,
        ),
      );

      expect(find.byType(ImportDraftsPage), findsOneWidget);
      expect(find.text('確認匯入的食物'), findsOneWidget);
      expect(find.textContaining('可能認錯字'), findsOneWidget);
      expect(find.text('鮮奶'), findsOneWidget);
      expect(find.text('雞蛋'), findsOneWidget);
    });

    testWidgets('排除與送出都派發到 ReceiptImportBloc', (tester) async {
      await pump(
        tester,
        ReceiptImportDrafts(
          drafts: [draft('鮮奶'), draft('雞蛋')],
          receiptDate: DateTime(2026, 9, 10),
          now: fixedNow,
        ),
      );

      await tester.tap(find.byIcon(Icons.remove_circle_outline).first);
      verify(() => bloc.add(const ReceiptImportDraftToggled(index: 0)))
          .called(1);

      await tester.tap(find.byIcon(Icons.playlist_add_check));
      verify(() => bloc.add(const ReceiptImportSubmitted())).called(1);
    });
  });
}
