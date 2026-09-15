import 'dart:convert';
import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/bloc/import/import_bloc.dart';
import 'package:food_savior/domain/einvoice/einvoice_parse_failure.dart';
import 'package:food_savior/domain/import/invoice_draft_mapper.dart';
import 'package:food_savior/domain/import/product_name_cleaner.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/models/food_preset.dart';
import 'package:food_savior/models/food_suggestion.dart';
import 'package:food_savior/repositories/preferences_repository.dart';
import 'package:food_savior/services/scanner/scanner_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_scanner_service.dart';

String fixture(String name) =>
    File('test/fixtures/einvoice/$name').readAsStringSync();

List<FoodPreset> loadPresets() =>
    (json.decode(File('assets/data/food_presets.json').readAsStringSync())
            as List)
        .cast<Map<String, dynamic>>()
        .map(FoodPreset.fromJson)
        .toList();

List<String> loadNoiseTerms() {
  final decoded = json.decode(
    File('assets/data/product_noise_terms.json').readAsStringSync(),
  ) as Map;
  return [
    for (final group in decoded.values) ...(group as List).cast<String>(),
  ];
}

final DateTime fixedNow = DateTime(2026, 9, 18, 10);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeScannerService scanner;
  late PreferencesRepository preferences;
  late List<FoodItem> imported;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    scanner = FakeScannerService();
    preferences = PreferencesRepository(
      preferences: await SharedPreferences.getInstance(),
    );
    imported = [];
  });

  ImportBloc build() => ImportBloc(
        scannerService: scanner,
        mapper: InvoiceDraftMapper(
          suggestionEngine: FoodSuggestionEngine(presets: loadPresets()),
          cleaner: ProductNameCleaner(noiseTerms: loadNoiseTerms()),
          now: () => fixedNow,
        ),
        preferencesRepository: preferences,
        onItemReady: imported.add,
      );

  /// 掃描是非同步串流，餵完要讓事件跑完才能斷言。
  Future<void> settle(ImportBloc bloc) =>
      Future<void>.delayed(Duration.zero).then((_) async {
        await Future<void>.delayed(Duration.zero);
      });

  group('權限', () {
    blocTest<ImportBloc, ImportState>(
      '權限通過時進入掃描狀態',
      build: build,
      act: (bloc) => bloc.add(const ImportStarted()),
      expect: () => [const ImportScanning()],
    );

    blocTest<ImportBloc, ImportState>(
      '權限被拒時不進入掃描',
      build: () {
        scanner.permission = ScannerPermission.denied;
        return build();
      },
      act: (bloc) => bloc.add(const ImportStarted()),
      expect: () => [
        const ImportPermissionBlocked(permission: ScannerPermission.denied),
      ],
    );

    blocTest<ImportBloc, ImportState>(
      '沒有相機時顯示對應狀態',
      build: () {
        scanner.permission = ScannerPermission.noCamera;
        return build();
      },
      act: (bloc) => bloc.add(const ImportStarted()),
      expect: () => [
        const ImportPermissionBlocked(permission: ScannerPermission.noCamera),
      ],
    );
  });

  group('雙碼配對', () {
    blocTest<ImportBloc, ImportState>(
      '先左後右：兩碼齊了才產生草稿',
      build: build,
      act: (bloc) async {
        bloc.add(const ImportStarted());
        await settle(bloc);
        scanner.emit(fixture('utf8_left.txt'));
        await settle(bloc);
        scanner.emit(fixture('utf8_right.txt'));
      },
      wait: const Duration(milliseconds: 10),
      verify: (bloc) {
        final state = bloc.state as ImportDrafts;
        expect(state.invoiceNumber, 'AB12345678');
        expect(state.drafts.map((d) => d.name).toList(),
            ['牛奶', '雞蛋', '高麗菜', '梅花豬肉片']);
        expect(state.itemsIncomplete, isFalse);
      },
    );

    blocTest<ImportBloc, ImportState>(
      '先右後左：結果與相反順序相同',
      build: build,
      act: (bloc) async {
        bloc.add(const ImportStarted());
        await settle(bloc);
        scanner.emit(fixture('utf8_right.txt'));
        await settle(bloc);
        scanner.emit(fixture('utf8_left.txt'));
      },
      wait: const Duration(milliseconds: 10),
      verify: (bloc) {
        final state = bloc.state as ImportDrafts;
        expect(state.drafts.map((d) => d.name).toList(),
            ['牛奶', '雞蛋', '高麗菜', '梅花豬肉片']);
      },
    );

    blocTest<ImportBloc, ImportState>(
      '只掃到左碼時停留在掃描狀態',
      build: build,
      act: (bloc) async {
        bloc.add(const ImportStarted());
        await settle(bloc);
        scanner.emit(fixture('partial_left.txt'));
      },
      wait: const Duration(milliseconds: 10),
      verify: (bloc) {
        expect(bloc.state, const ImportScanning(hasLeftCode: true));
      },
    );

    blocTest<ImportBloc, ImportState>(
      '左碼已涵蓋宣告筆數時直接產生草稿，不等右碼',
      build: build,
      act: (bloc) async {
        bloc.add(const ImportStarted());
        await settle(bloc);
        scanner.emit(fixture('base64_left.txt'));
      },
      wait: const Duration(milliseconds: 10),
      verify: (bloc) => expect(bloc.state, isA<ImportDrafts>()),
    );

    blocTest<ImportBloc, ImportState>(
      '掃到不是發票的 QR 不中斷掃描',
      build: build,
      act: (bloc) async {
        bloc.add(const ImportStarted());
        await settle(bloc);
        scanner.emit('https://example.com');
      },
      wait: const Duration(milliseconds: 10),
      verify: (bloc) => expect(bloc.state, isA<ImportScanning>()),
    );

    blocTest<ImportBloc, ImportState>(
      '實際品項少於宣告筆數時標示 itemsIncomplete',
      build: build,
      act: (bloc) async {
        bloc.add(const ImportStarted());
        await settle(bloc);
        scanner.emit(fixture('short_items_left.txt'));
        await settle(bloc);
        scanner.emit(fixture('short_items_right.txt'));
      },
      wait: const Duration(milliseconds: 10),
      verify: (bloc) {
        final state = bloc.state as ImportDrafts;
        expect(state.drafts, hasLength(3));
        expect(state.itemsIncomplete, isTrue);
      },
    );

    blocTest<ImportBloc, ImportState>(
      'Big5 發票回報不支援並停止掃描',
      build: build,
      act: (bloc) async {
        bloc.add(const ImportStarted());
        await settle(bloc);
        scanner.emit(fixture('big5_left.txt'));
      },
      wait: const Duration(milliseconds: 10),
      verify: (bloc) {
        expect(
          bloc.state,
          const ImportFailure(reason: ParseFailureReason.unsupportedBig5),
        );
      },
    );
  });

  group('重複發票', () {
    blocTest<ImportBloc, ImportState>(
      '掃到已匯入過的發票時先警告，不直接產生草稿',
      build: () {
        preferences.markInvoiceImported('AB12345678');
        return build();
      },
      act: (bloc) async {
        bloc.add(const ImportStarted());
        await settle(bloc);
        scanner.emit(fixture('utf8_left.txt'));
        await settle(bloc);
        scanner.emit(fixture('utf8_right.txt'));
      },
      wait: const Duration(milliseconds: 10),
      verify: (bloc) {
        expect(
          bloc.state,
          const ImportDuplicateWarning(invoiceNumber: 'AB12345678'),
        );
      },
    );

    blocTest<ImportBloc, ImportState>(
      '選擇仍要匯入後照常產生草稿',
      build: () {
        preferences.markInvoiceImported('AB12345678');
        return build();
      },
      act: (bloc) async {
        bloc.add(const ImportStarted());
        await settle(bloc);
        scanner.emit(fixture('utf8_left.txt'));
        await settle(bloc);
        scanner.emit(fixture('utf8_right.txt'));
        await settle(bloc);
        bloc.add(const ImportDuplicateConfirmed());
      },
      wait: const Duration(milliseconds: 10),
      verify: (bloc) => expect(bloc.state, isA<ImportDrafts>()),
    );
  });

  group('草稿編輯與送出', () {
    Future<ImportBloc> scannedBloc() async {
      final bloc = build();
      bloc.add(const ImportStarted());
      await Future<void>.delayed(const Duration(milliseconds: 5));
      scanner.emit(fixture('utf8_left.txt'));
      await Future<void>.delayed(const Duration(milliseconds: 5));
      scanner.emit(fixture('utf8_right.txt'));
      await Future<void>.delayed(const Duration(milliseconds: 5));
      return bloc;
    }

    test('排除某一列後不會被寫入', () async {
      final bloc = await scannedBloc();

      bloc.add(const ImportDraftToggled(index: 0));
      await Future<void>.delayed(const Duration(milliseconds: 5));
      bloc.add(const ImportSubmitted());
      await Future<void>.delayed(const Duration(milliseconds: 5));

      expect(imported.map((e) => e.name).toList(), ['雞蛋', '高麗菜', '梅花豬肉片']);
      expect((bloc.state as ImportDone).importedCount, 3);
      await bloc.close();
    });

    test('全部排除時不能送出', () async {
      final bloc = await scannedBloc();
      final count = (bloc.state as ImportDrafts).drafts.length;

      for (var i = 0; i < count; i++) {
        bloc.add(ImportDraftToggled(index: i));
      }
      await Future<void>.delayed(const Duration(milliseconds: 5));

      expect((bloc.state as ImportDrafts).canSubmit, isFalse);

      bloc.add(const ImportSubmitted());
      await Future<void>.delayed(const Duration(milliseconds: 5));

      expect(imported, isEmpty);
      expect(bloc.state, isA<ImportDrafts>());
      await bloc.close();
    });

    test('編輯名稱後寫入的是編輯後的值', () async {
      final bloc = await scannedBloc();
      final drafts = (bloc.state as ImportDrafts).drafts;

      bloc.add(ImportDraftChanged(
        index: 0,
        draft: drafts.first.copyWith(name: '全脂鮮乳'),
      ));
      await Future<void>.delayed(const Duration(milliseconds: 5));
      bloc.add(const ImportSubmitted());
      await Future<void>.delayed(const Duration(milliseconds: 5));

      expect(imported.first.name, '全脂鮮乳');
      await bloc.close();
    });

    test('送出成功後記下發票號碼，之後再掃會被視為重複', () async {
      final bloc = await scannedBloc();

      bloc.add(const ImportSubmitted());
      await Future<void>.delayed(const Duration(milliseconds: 5));

      expect(imported, hasLength(4));
      expect(preferences.hasImportedInvoice('AB12345678'), isTrue);
      await bloc.close();
    });

    test('每一筆都取得唯一 id', () async {
      final bloc = await scannedBloc();

      bloc.add(const ImportSubmitted());
      await Future<void>.delayed(const Duration(milliseconds: 5));

      expect(imported.map((e) => e.id).toSet(), hasLength(imported.length));
      await bloc.close();
    });

    test('未送出前不會有任何項目寫入', () async {
      final bloc = await scannedBloc();

      expect(imported, isEmpty);
      await bloc.close();
    });
  });
}
