import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/bloc/import/import_bloc.dart';
import 'package:food_savior/domain/einvoice/einvoice_parse_failure.dart';
import 'package:food_savior/generated/l10n.dart';
import 'package:food_savior/pages/import/scan_invoice_page.dart';
import 'package:food_savior/services/scanner/app_settings_opener.dart';
import 'package:food_savior/services/scanner/scanner_service.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/widget_test_helper.dart';

class MockImportBloc extends MockBloc<ImportEvent, ImportState>
    implements ImportBloc {}

/// 相機預覽的替身。Widget test 不能建立真正的 `MobileScanner`（需要平台通道），
/// 所以頁面把預覽做成注入點（design D9）。
const Key previewKey = Key('preview');

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

void main() {
  late MockImportBloc bloc;
  late RecordingSettingsOpener settingsOpener;

  setUp(() {
    bloc = MockImportBloc();
    settingsOpener = RecordingSettingsOpener();
  });

  Future<void> pump(
    WidgetTester tester,
    ImportState state, {
    Locale locale = const Locale('zh', 'TW'),
    Brightness brightness = Brightness.light,
  }) async {
    when(() => bloc.state).thenReturn(state);

    await tester.pumpWidget(wrapForTest(
      BlocProvider<ImportBloc>.value(
        value: bloc,
        child: ScanInvoicePage(
          previewBuilder: _previewBuilder,
          settingsOpener: settingsOpener,
        ),
      ),
      locale: locale,
      brightness: brightness,
    ));
    await tester.pump();
  }

  group('掃描進度', () {
    testWidgets('兩個碼都沒掃到時各顯示待掃描', (tester) async {
      await pump(tester, const ImportScanning());

      expect(find.byKey(previewKey), findsOneWidget);
      expect(find.text('左側條碼：待掃描'), findsOneWidget);
      expect(find.text('右側條碼：待掃描'), findsOneWidget);
    });

    testWidgets('掃到左碼後只剩右碼待掃描', (tester) async {
      await pump(tester, const ImportScanning(hasLeftCode: true));

      expect(find.text('左側條碼：已取得'), findsOneWidget);
      expect(find.text('右側條碼：待掃描'), findsOneWidget);
    });

    testWidgets('掃到別張發票的碼時顯示提示但不離開掃描', (tester) async {
      await pump(
        tester,
        const ImportScanning(
          hasLeftCode: true,
          notice: ImportNotice.codeMismatch,
        ),
      );

      expect(find.byKey(previewKey), findsOneWidget);
      expect(find.text('這是另一張發票的條碼，請掃描同一張的另一側'), findsOneWidget);
    });
  });

  group('相機不可用', () {
    testWidgets('權限被拒時同時給「前往設定」與「改為手動新增」', (tester) async {
      await pump(
        tester,
        const ImportPermissionBlocked(permission: ScannerPermission.denied),
      );

      expect(find.text('需要相機權限才能掃描發票'), findsOneWidget);
      expect(find.text('前往設定'), findsOneWidget);
      // 只給「前往設定」等於把人關在門外。
      expect(find.text('改為手動新增'), findsOneWidget);
      expect(find.byKey(previewKey), findsNothing);
    });

    // 永久拒絕（Android USER_FIXED）之後叫不出權限對話框，重試沒有意義，
    // 這顆按鈕必須真的把人送到系統設定。
    testWidgets('前往設定會開啟系統設定，而不是重試', (tester) async {
      await pump(
        tester,
        const ImportPermissionBlocked(permission: ScannerPermission.denied),
      );

      await tester.tap(find.text('前往設定'));
      await tester.pump();

      expect(settingsOpener.calls, 1);
      verifyNever(() => bloc.add(const ImportRestarted()));
    });

    // unbundled-scanner-model：模型改由 Play Services 動態下載後，
    // 「還在準備中」是一個真實會發生、而且**可以重試**的狀態。
    testWidgets('掃描元件尚未就緒時同時給重試與手動新增', (tester) async {
      await pump(
        tester,
        const ImportPermissionBlocked(
          permission: ScannerPermission.scannerUnavailable,
        ),
      );

      expect(find.text('掃描功能還在準備中，請稍後再試'), findsOneWidget);
      expect(find.text('重新掃描'), findsOneWidget);
      expect(find.text('改為手動新增'), findsOneWidget);
      // 相機是好的，不該講成沒有相機。
      expect(find.text('這台裝置沒有可用的相機'), findsNothing);
      expect(find.text('前往設定'), findsNothing);
    });

    testWidgets('尚未就緒的重試會派發 ImportRestarted', (tester) async {
      await pump(
        tester,
        const ImportPermissionBlocked(
          permission: ScannerPermission.scannerUnavailable,
        ),
      );

      await tester.tap(find.text('重新掃描'));
      verify(() => bloc.add(const ImportRestarted())).called(1);
    });

    testWidgets('沒有相機時不提供重試：重試無論如何都不會成功', (tester) async {
      await pump(
        tester,
        const ImportPermissionBlocked(permission: ScannerPermission.noCamera),
      );

      expect(find.text('重新掃描'), findsNothing);
      expect(find.text('改為手動新增'), findsOneWidget);
    });

    testWidgets('沒有相機時不顯示前往設定', (tester) async {
      await pump(
        tester,
        const ImportPermissionBlocked(permission: ScannerPermission.noCamera),
      );

      expect(find.text('這台裝置沒有可用的相機'), findsOneWidget);
      expect(find.text('前往設定'), findsNothing);
      expect(find.text('改為手動新增'), findsOneWidget);
    });
  });

  group('失敗與重複', () {
    testWidgets('Big5 發票顯示編碼不支援並提供手動新增', (tester) async {
      await pump(
        tester,
        const ImportFailure(reason: ParseFailureReason.unsupportedBig5),
      );

      expect(find.text('這張發票使用的文字編碼無法解讀，請改為手動新增'), findsOneWidget);
      expect(find.text('改為手動新增'), findsOneWidget);
    });

    testWidgets('一般解析失敗可重新掃描', (tester) async {
      await pump(
        tester,
        const ImportFailure(reason: ParseFailureReason.malformed),
      );

      expect(find.text('讀不到發票內容，請再試一次'), findsOneWidget);

      await tester.tap(find.text('重新掃描'));
      verify(() => bloc.add(const ImportRestarted())).called(1);
    });

    testWidgets('重複發票要使用者明確選擇', (tester) async {
      await pump(
        tester,
        const ImportDuplicateWarning(invoiceNumber: 'AB12345678'),
      );

      expect(find.text('這張發票已經匯入過了'), findsOneWidget);
      expect(find.text('AB12345678'), findsOneWidget);

      await tester.tap(find.text('仍要匯入'));
      verify(() => bloc.add(const ImportDuplicateConfirmed())).called(1);
    });
  });

  group('主題與語系', () {
    testWidgets('暗色主題可繪製', (tester) async {
      await pump(
        tester,
        const ImportScanning(hasLeftCode: true),
        brightness: Brightness.dark,
      );

      expect(tester.takeException(), isNull);
      expect(find.text('左側條碼：已取得'), findsOneWidget);
    });

    testWidgets('英文語系顯示英文字串', (tester) async {
      await pump(
        tester,
        const ImportScanning(),
        locale: const Locale('en'),
      );

      expect(find.text('Left code: not scanned'), findsOneWidget);
      expect(find.text('Right code: not scanned'), findsOneWidget);
    });

    testWidgets('英文語系的權限說明也已翻譯', (tester) async {
      await pump(
        tester,
        const ImportPermissionBlocked(permission: ScannerPermission.denied),
        locale: const Locale('en'),
      );

      expect(find.text('Camera access is needed to scan receipts'),
          findsOneWidget);
      expect(find.text('Add manually instead'), findsOneWidget);
    });
  });

  testWidgets('標題在草稿階段換成確認匯入', (tester) async {
    await pump(tester, const ImportScanning());
    expect(find.text(S.current.einvoiceScanTitle), findsOneWidget);
  });

  // 實機上抓到的迴歸：預覽如果等到 ImportScanning 才掛載，autoStart 永遠不會觸發，
  // 權限查詢就會逾時變成「沒有可用的相機」。初始狀態就必須把預覽放進樹裡。
  testWidgets('初始狀態就掛載相機預覽，否則 autoStart 不會觸發', (tester) async {
    await pump(tester, const ImportInitial());

    expect(find.byKey(previewKey), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('送出中不需要預覽', (tester) async {
    await pump(tester, const ImportSubmitting());

    expect(find.byKey(previewKey), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}

Widget _previewBuilder(BuildContext context) =>
    const SizedBox.expand(key: previewKey);
