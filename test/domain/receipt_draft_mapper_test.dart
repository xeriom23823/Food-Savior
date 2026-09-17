import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/domain/import/product_name_cleaner.dart';
import 'package:food_savior/domain/receipt/receipt_draft_mapper.dart';
import 'package:food_savior/domain/receipt/receipt_item.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/models/food_preset.dart';
import 'package:food_savior/models/food_suggestion.dart';
import 'package:food_savior/models/storage_location.dart';

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

void main() {
  final receiptDate = DateTime(2026, 9, 15);
  late ReceiptDraftMapper mapper;

  setUp(() {
    mapper = ReceiptDraftMapper(
      suggestionEngine: FoodSuggestionEngine(presets: loadPresets()),
      cleaner: ProductNameCleaner(noiseTerms: loadNoiseTerms()),
    );
  });

  test('走與發票匯入相同的清洗與推導', () {
    final drafts = mapper.draftsFrom(
      [const ReceiptItem(rawName: '特價 統一 牛奶', amount: 55)],
      receiptDate: receiptDate,
      locationKind: LocationKind.refrigerated,
    );

    expect(drafts.single.name, '牛奶');
    expect(drafts.single.type, FoodItemType.eggAndMilk);
    expect(drafts.single.expiry.isKnown, isTrue);
  });

  test('存放日期是收據日期', () {
    final drafts = mapper.draftsFrom(
      [const ReceiptItem(rawName: '雞蛋', amount: 89)],
      receiptDate: receiptDate,
    );

    expect(drafts.single.storageDate, receiptDate);
  });

  test('建議到期日從收據日期起算，不是從今天', () {
    final drafts = mapper.draftsFrom(
      [const ReceiptItem(rawName: '雞蛋')],
      receiptDate: receiptDate,
      locationKind: LocationKind.refrigerated,
    );

    // 對照表的雞蛋冷藏 21 天。
    expect(drafts.single.expiry.earliest,
        receiptDate.add(const Duration(days: 21)));
  });

  // receipt-ocr-import 規格：OCR 的可信度低於 QR，每一列都要使用者看過。
  test('每一列都標待確認，即使品名命中建議', () {
    final drafts = mapper.draftsFrom(
      [
        const ReceiptItem(rawName: '雞蛋', amount: 89),
        const ReceiptItem(rawName: '環保購物袋', amount: 2),
      ],
      receiptDate: receiptDate,
    );

    expect(drafts.every((draft) => draft.needsReview), isTrue);
  });

  test('金額來自收據的小計', () {
    final drafts = mapper.draftsFrom(
      [
        const ReceiptItem(
            rawName: '梅花豬肉片', quantity: 1, unitPrice: 158, amount: 158)
      ],
      receiptDate: receiptDate,
    );

    expect(drafts.single.priceTotal, 158);
  });

  test('沒有數量時不塞假的 1', () {
    final drafts = mapper.draftsFrom(
      [const ReceiptItem(rawName: '手工豆腐')],
      receiptDate: receiptDate,
    );

    expect(drafts.single.amount, isNull);
    expect(drafts.single.unit, isNull);
  });

  test('品名抽出的規格優先於收據數量', () {
    final drafts = mapper.draftsFrom(
      [const ReceiptItem(rawName: '可樂 600ML', quantity: 1, amount: 35)],
      receiptDate: receiptDate,
    );

    expect(drafts.single.amount, 600);
    expect(drafts.single.unit, Unit.milliliter);
  });

  test('原始品名一律保留供對照收據', () {
    const raw = '特價 統一 牛奶';
    final drafts = mapper.draftsFrom(
      [const ReceiptItem(rawName: raw, amount: 55)],
      receiptDate: receiptDate,
    );

    expect(drafts.single.sourceLine, raw);
    expect(drafts.single.name, isNot(raw));
  });

  test('未命中建議時退回 others 與期限未知', () {
    final drafts = mapper.draftsFrom(
      [const ReceiptItem(rawName: '環保購物袋', amount: 2)],
      receiptDate: receiptDate,
    );

    expect(drafts.single.type, FoodItemType.others);
    expect(drafts.single.expiry.isKnown, isFalse);
  });

  test('一次轉換多個品項並保持收據順序', () {
    final drafts = mapper.draftsFrom(
      const [
        ReceiptItem(rawName: '牛奶'),
        ReceiptItem(rawName: '雞蛋'),
        ReceiptItem(rawName: '高麗菜'),
      ],
      receiptDate: receiptDate,
    );

    expect(drafts.map((d) => d.name).toList(), ['牛奶', '雞蛋', '高麗菜']);
  });

  test('空清單回傳空清單', () {
    expect(mapper.draftsFrom(const [], receiptDate: receiptDate), isEmpty);
  });
}
