import 'dart:convert';
import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/bloc/receipt_import/receipt_import_bloc.dart';
import 'package:food_savior/domain/import/product_name_cleaner.dart';
import 'package:food_savior/domain/receipt/ocr_result.dart';
import 'package:food_savior/domain/receipt/receipt_draft_mapper.dart';
import 'package:food_savior/domain/receipt/receipt_layout_parser.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/models/food_preset.dart';
import 'package:food_savior/models/food_suggestion.dart';
import 'package:food_savior/models/storage_location.dart';
import 'package:food_savior/services/ocr/receipt_image_picker.dart';
import 'package:food_savior/services/ocr/text_recognition_service.dart';

import '../helpers/fake_text_recognition_service.dart';

List<FoodPreset> loadPresets() =>
    (json.decode(File('assets/data/food_presets.json').readAsStringSync())
            as List)
        .cast<Map<String, dynamic>>()
        .map(FoodPreset.fromJson)
        .toList();

List<String> loadTerms(String asset) {
  final decoded = json.decode(File(asset).readAsStringSync()) as Map;
  return [
    for (final group in decoded.values) ...(group as List).cast<String>(),
  ];
}

final DateTime fixedNow = DateTime(2026, 9, 18, 10);

/// 一張最小的收據版面：店名（表頭）、兩個品項、日期（表尾）。
/// 座標只要能分列就好——版面解析器本身的正確率由基準測試負責。
OcrTextElement el(String text, double left, double top) => OcrTextElement(
      text: text,
      bounds:
          TextBounds(left: left, top: top, right: left + 60, bottom: top + 10),
    );

final OcrResult receipt = OcrResult(elements: [
  el('全聯福利中心', 0, 0),
  el('鮮奶', 0, 20),
  el('55', 200, 20),
  el('雞蛋', 0, 40),
  el('89', 200, 40),
  el('2026/09/10', 0, 60),
]);

/// 有文字但沒有一列像品項：全是招呼語與「標籤:值」。
///
/// 注意：解析器在**整張都沒有數字**時會把剩下的文字列當品名放行
/// （OCR 漏掉所有價格時至少還有名字可改），所以這裡不能只放店名。
final OcrResult headerOnly = OcrResult(elements: [
  el('歡迎光臨', 0, 0),
  el('電話:0212345678', 0, 20),
  el('謝謝光臨', 0, 40),
]);

void main() {
  late FakeReceiptImagePicker picker;
  late FakeTextRecognitionService recognizer;
  late List<FoodItem> imported;

  setUp(() {
    picker = FakeReceiptImagePicker();
    recognizer = FakeTextRecognitionService(
      result: RecognitionSuccess(receipt),
    );
    imported = [];
  });

  ReceiptImportBloc build() => ReceiptImportBloc(
        imagePicker: picker,
        recognizer: recognizer,
        parser: ReceiptLayoutParser(
          noiseTerms: loadTerms('assets/data/receipt_noise_terms.json'),
        ),
        mapper: ReceiptDraftMapper(
          suggestionEngine: FoodSuggestionEngine(presets: loadPresets()),
          cleaner: ProductNameCleaner(
            noiseTerms: loadTerms('assets/data/product_noise_terms.json'),
          ),
        ),
        onItemReady: imported.add,
        locationKind: LocationKind.refrigerated,
        defaultLocationId: 'fridge-1',
        now: () => fixedNow,
      );

  group('取得照片', () {
    blocTest<ReceiptImportBloc, ReceiptImportState>(
      '開始時顯示來源選擇',
      build: build,
      act: (bloc) => bloc.add(const ReceiptImportStarted()),
      expect: () => const [ReceiptImportChoosingSource()],
    );

    blocTest<ReceiptImportBloc, ReceiptImportState>(
      '選擇來源會把來源交給 picker',
      build: build,
      act: (bloc) => bloc.add(
        const ReceiptImportSourceChosen(ReceiptImageSource.gallery),
      ),
      verify: (_) {
        expect(picker.requestedSources, [ReceiptImageSource.gallery]);
        expect(recognizer.recognizedPaths, ['/tmp/receipt.jpg']);
      },
    );

    blocTest<ReceiptImportBloc, ReceiptImportState>(
      '取消拍照回到來源選擇，不辨識',
      build: build,
      setUp: () => picker.result = const ImagePickCancelled(),
      act: (bloc) => bloc.add(
        const ReceiptImportSourceChosen(ReceiptImageSource.camera),
      ),
      expect: () => const [ReceiptImportChoosingSource()],
      verify: (_) => expect(recognizer.recognizedPaths, isEmpty),
    );

    blocTest<ReceiptImportBloc, ReceiptImportState>(
      '權限被拒進入 permissionDenied',
      build: build,
      setUp: () => picker.result = const ImagePickDenied(),
      act: (bloc) => bloc.add(
        const ReceiptImportSourceChosen(ReceiptImageSource.camera),
      ),
      expect: () => const [
        ReceiptImportBlocked(reason: ReceiptImportBlock.permissionDenied),
      ],
    );
  });

  group('辨識', () {
    blocTest<ReceiptImportBloc, ReceiptImportState>(
      '辨識器未就緒進入 recognizerNotReady',
      build: build,
      setUp: () => recognizer.result = const RecognitionUnavailable(),
      act: (bloc) => bloc.add(
        const ReceiptImportSourceChosen(ReceiptImageSource.camera),
      ),
      expect: () => const [
        ReceiptImportRecognizing(),
        ReceiptImportBlocked(reason: ReceiptImportBlock.recognizerNotReady),
      ],
    );

    blocTest<ReceiptImportBloc, ReceiptImportState>(
      '沒有任何文字回報 noText',
      build: build,
      setUp: () =>
          recognizer.result = const RecognitionSuccess(OcrResult(elements: [])),
      act: (bloc) => bloc.add(
        const ReceiptImportSourceChosen(ReceiptImageSource.camera),
      ),
      expect: () => const [
        ReceiptImportRecognizing(),
        ReceiptImportEmpty(kind: ReceiptImportEmptyKind.noText),
      ],
    );

    blocTest<ReceiptImportBloc, ReceiptImportState>(
      '有文字但沒有品項回報 noItems',
      build: build,
      setUp: () => recognizer.result = RecognitionSuccess(headerOnly),
      act: (bloc) => bloc.add(
        const ReceiptImportSourceChosen(ReceiptImageSource.camera),
      ),
      expect: () => const [
        ReceiptImportRecognizing(),
        ReceiptImportEmpty(kind: ReceiptImportEmptyKind.noItems),
      ],
    );

    blocTest<ReceiptImportBloc, ReceiptImportState>(
      '成功時產生草稿，每列都待確認，存放日期取自收據',
      build: build,
      act: (bloc) => bloc.add(
        const ReceiptImportSourceChosen(ReceiptImageSource.camera),
      ),
      expect: () => [
        const ReceiptImportRecognizing(),
        isA<ReceiptImportDrafts>()
            .having((s) => s.drafts.length, 'drafts', 2)
            .having((s) => s.drafts.map((d) => d.name), 'names', ['鮮奶', '雞蛋'])
            .having((s) => s.drafts.every((d) => d.needsReview),
                'all needsReview', isTrue)
            .having((s) => s.receiptDate, 'receiptDate', DateTime(2026, 9, 10))
            .having((s) => s.drafts.first.storageDate, 'storageDate',
                DateTime(2026, 9, 10))
            .having(
                (s) => s.drafts.first.storageLocationId, 'location', 'fridge-1')
            .having((s) => s.now, 'now', fixedNow),
      ],
    );

    blocTest<ReceiptImportBloc, ReceiptImportState>(
      '重試回到來源選擇',
      build: build,
      setUp: () => recognizer.result = const RecognitionUnavailable(),
      // 事件處理是並行的：要等到 Blocked 出現再重試，否則 Retried 會先跑完，
      // 而「回到初始狀態」與初始狀態相等，不會被 emit。
      act: (bloc) async {
        bloc.add(const ReceiptImportSourceChosen(ReceiptImageSource.camera));
        await bloc.stream.firstWhere((s) => s is ReceiptImportBlocked);
        bloc.add(const ReceiptImportRetried());
      },
      skip: 2,
      expect: () => const [ReceiptImportChoosingSource()],
    );
  });

  group('草稿', () {
    Future<ReceiptImportBloc> withDrafts() async {
      final bloc = build()
        ..add(const ReceiptImportSourceChosen(ReceiptImageSource.camera));
      await bloc.stream.firstWhere((s) => s is ReceiptImportDrafts);
      return bloc;
    }

    blocTest<ReceiptImportBloc, ReceiptImportState>(
      '排除一列後 importable 少一筆，再切回來恢復',
      build: build,
      act: (bloc) async {
        bloc.add(const ReceiptImportSourceChosen(ReceiptImageSource.camera));
        await bloc.stream.firstWhere((s) => s is ReceiptImportDrafts);
        bloc
          ..add(const ReceiptImportDraftToggled(index: 0))
          ..add(const ReceiptImportDraftToggled(index: 0));
      },
      skip: 2,
      expect: () => [
        isA<ReceiptImportDrafts>()
            .having((s) => s.drafts[0].excluded, 'excluded', isTrue)
            .having((s) => s.importable.length, 'importable', 1),
        isA<ReceiptImportDrafts>()
            .having((s) => s.drafts[0].excluded, 'excluded', isFalse)
            .having((s) => s.importable.length, 'importable', 2),
      ],
    );

    blocTest<ReceiptImportBloc, ReceiptImportState>(
      '編輯一列會取代該列',
      build: build,
      act: (bloc) async {
        bloc.add(const ReceiptImportSourceChosen(ReceiptImageSource.camera));
        final drafts = await bloc.stream
            .firstWhere((s) => s is ReceiptImportDrafts) as ReceiptImportDrafts;
        bloc.add(ReceiptImportDraftChanged(
          index: 1,
          draft: drafts.drafts[1].copyWith(name: '土雞蛋', needsReview: false),
        ));
      },
      skip: 2,
      expect: () => [
        isA<ReceiptImportDrafts>()
            .having((s) => s.drafts[1].name, 'name', '土雞蛋')
            .having((s) => s.drafts[1].needsReview, 'needsReview', isFalse)
            .having((s) => s.drafts[0].name, 'untouched', '鮮奶'),
      ],
    );

    blocTest<ReceiptImportBloc, ReceiptImportState>(
      '超出範圍的索引被忽略',
      build: build,
      act: (bloc) async {
        bloc.add(const ReceiptImportSourceChosen(ReceiptImageSource.camera));
        await bloc.stream.firstWhere((s) => s is ReceiptImportDrafts);
        bloc.add(const ReceiptImportDraftToggled(index: 5));
      },
      skip: 2,
      expect: () => const <ReceiptImportState>[],
    );

    blocTest<ReceiptImportBloc, ReceiptImportState>(
      '送出只寫入未排除的列，並回報筆數',
      build: build,
      act: (bloc) async {
        bloc.add(const ReceiptImportSourceChosen(ReceiptImageSource.camera));
        await bloc.stream.firstWhere((s) => s is ReceiptImportDrafts);
        bloc
          ..add(const ReceiptImportDraftToggled(index: 0))
          ..add(const ReceiptImportSubmitted());
      },
      skip: 3,
      expect: () => const [
        ReceiptImportSubmitting(),
        ReceiptImportDone(importedCount: 1),
      ],
      verify: (_) {
        expect(imported.map((item) => item.name), ['雞蛋']);
        expect(imported.single.storageDate, DateTime(2026, 9, 10));
        expect(imported.single.storageLocationId, 'fridge-1');
      },
    );

    blocTest<ReceiptImportBloc, ReceiptImportState>(
      '全部排除時送出不動作',
      build: build,
      act: (bloc) async {
        bloc.add(const ReceiptImportSourceChosen(ReceiptImageSource.camera));
        await bloc.stream.firstWhere((s) => s is ReceiptImportDrafts);
        bloc
          ..add(const ReceiptImportDraftToggled(index: 0))
          ..add(const ReceiptImportDraftToggled(index: 1))
          ..add(const ReceiptImportSubmitted());
      },
      skip: 4,
      expect: () => const <ReceiptImportState>[],
      verify: (_) => expect(imported, isEmpty),
    );

    blocTest<ReceiptImportBloc, ReceiptImportState>(
      '不在草稿狀態時送出不動作',
      build: build,
      act: (bloc) => bloc.add(const ReceiptImportSubmitted()),
      expect: () => const <ReceiptImportState>[],
      verify: (_) => expect(imported, isEmpty),
    );

    test('關閉 Bloc 會釋放辨識器', () async {
      final bloc = await withDrafts();
      await bloc.close();
      expect(recognizer.disposed, isTrue);
    });
  });
}
