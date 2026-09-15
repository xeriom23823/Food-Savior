import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/domain/einvoice/einvoice.dart';
import 'package:food_savior/domain/import/invoice_draft_mapper.dart';
import 'package:food_savior/domain/import/product_name_cleaner.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/models/food_preset.dart';
import 'package:food_savior/models/food_suggestion.dart';
import 'package:food_savior/models/storage_location.dart';

import 'product_name_cleaner_test.dart' show loadNoiseTerms;

/// 用真實的 asset 資料測，才不會出現「測試通過但實機對不到」的落差。
List<FoodPreset> loadPresets() {
  final decoded = json
      .decode(File('assets/data/food_presets.json').readAsStringSync()) as List;
  return decoded.cast<Map<String, dynamic>>().map(FoodPreset.fromJson).toList();
}

final DateTime issuedDate = DateTime(2026, 9, 15);
final DateTime fixedNow = DateTime(2026, 9, 18, 10);

EInvoice invoiceWith(List<EInvoiceItem> items) => EInvoice(
      invoiceNumber: 'AB12345678',
      issuedDate: issuedDate,
      items: items,
      declaredItemCount: items.length,
    );

void main() {
  late InvoiceDraftMapper mapper;

  setUp(() {
    mapper = InvoiceDraftMapper(
      suggestionEngine: FoodSuggestionEngine(presets: loadPresets()),
      cleaner: ProductNameCleaner(noiseTerms: loadNoiseTerms()),
      now: () => fixedNow,
    );
  });

  test('命中內建對照表時帶出類型與到期日', () {
    final drafts = mapper.draftsFrom(
      invoiceWith([const EInvoiceItem(name: '雞蛋', quantity: 1, unitPrice: 89)]),
      locationKind: LocationKind.refrigerated,
    );
    final draft = drafts.single;

    expect(draft.type, FoodItemType.eggAndMilk);
    expect(draft.needsReview, isFalse);
    expect(draft.expiry.isKnown, isTrue);
    // 對照表的雞蛋冷藏 21 天，且以**發票日**起算而非今天。
    expect(draft.expiry.earliest, issuedDate.add(const Duration(days: 21)));
  });

  test('存放日期是發票開立日，不是今天', () {
    final drafts = mapper.draftsFrom(
      invoiceWith([const EInvoiceItem(name: '牛奶', quantity: 1, unitPrice: 65)]),
    );

    expect(drafts.single.storageDate, issuedDate);
  });

  test('未命中任何來源時標示待確認並退回 others', () {
    final drafts = mapper.draftsFrom(
      invoiceWith([
        const EInvoiceItem(name: '環保購物袋', quantity: 1, unitPrice: 2),
      ]),
    );
    final draft = drafts.single;

    expect(draft.type, FoodItemType.others);
    expect(draft.needsReview, isTrue);
    expect(draft.expiry.isKnown, isFalse);
  });

  test('金額 = 單價 × 數量', () {
    final drafts = mapper.draftsFrom(
      invoiceWith([
        const EInvoiceItem(name: '梅花豬肉片', quantity: 2, unitPrice: 120),
      ]),
    );

    expect(drafts.single.priceTotal, 240);
  });

  test('缺單價時金額為 null，不猜', () {
    final drafts = mapper.draftsFrom(
      invoiceWith([const EInvoiceItem(name: '香蕉', quantity: 1)]),
    );

    expect(drafts.single.priceTotal, isNull);
  });

  test('品名抽出的規格覆蓋建議機制的數量與單位', () {
    // 對照表對「優酪乳」建議 box；品名寫明 400ML，規格優先。
    final drafts = mapper.draftsFrom(
      invoiceWith([
        const EInvoiceItem(name: '統一AB優酪乳400ML特價', quantity: 1, unitPrice: 32),
      ]),
    );
    final draft = drafts.single;

    expect(draft.amount, 400);
    expect(draft.unit, Unit.milliliter);
    expect(draft.type, FoodItemType.eggAndMilk);
  });

  test('沒有規格時用發票上的數量', () {
    final drafts = mapper.draftsFrom(
      invoiceWith([const EInvoiceItem(name: '雞蛋', quantity: 3, unitPrice: 89)]),
    );

    expect(drafts.single.amount, 3);
  });

  test('原始品名一律保留供對照發票', () {
    const raw = '【冷藏】梅花豬肉片(約300g)';
    final drafts = mapper.draftsFrom(
      invoiceWith([const EInvoiceItem(name: raw, quantity: 1, unitPrice: 120)]),
    );

    expect(drafts.single.sourceLine, raw);
    expect(drafts.single.name, isNot(raw));
  });

  test('一次轉換多個品項並保持發票順序', () {
    final drafts = mapper.draftsFrom(invoiceWith(const [
      EInvoiceItem(name: '牛奶', quantity: 1, unitPrice: 65),
      EInvoiceItem(name: '雞蛋', quantity: 1, unitPrice: 89),
      EInvoiceItem(name: '高麗菜', quantity: 1, unitPrice: 45),
    ]));

    expect(drafts.map((d) => d.name).toList(), ['牛奶', '雞蛋', '高麗菜']);
  });

  group('toFoodItem', () {
    test('依 now 推導狀態並保留匯入的欄位', () {
      final draft = mapper
          .draftsFrom(
            invoiceWith([
              const EInvoiceItem(name: '雞蛋', quantity: 2, unitPrice: 89),
            ]),
            locationKind: LocationKind.refrigerated,
          )
          .single;

      final item = draft.toFoodItem(id: 'x', now: fixedNow);

      expect(item.id, 'x');
      expect(item.name, '雞蛋');
      expect(item.type, FoodItemType.eggAndMilk);
      expect(item.amount, 2);
      expect(item.priceTotal, 178);
      expect(item.storageDate, issuedDate);
      expect(item.status, FoodItemStatus.fresh);
    });

    test('期限未知的草稿轉出來是 unknownExpiry', () {
      final draft = mapper
          .draftsFrom(
            invoiceWith([const EInvoiceItem(name: '環保購物袋', quantity: 1)]),
          )
          .single;

      final item = draft.toFoodItem(id: 'y', now: fixedNow);

      expect(item.status, FoodItemStatus.unknownExpiry);
      expect(item.needsExpiryCompletion, isTrue);
    });
  });

  group('isImportable', () {
    test('被排除的草稿不可匯入', () {
      final draft = mapper
          .draftsFrom(invoiceWith([const EInvoiceItem(name: '雞蛋')]))
          .single;

      expect(draft.isImportable, isTrue);
      expect(draft.copyWith(excluded: true).isImportable, isFalse);
    });

    test('名稱為空不可匯入', () {
      final draft = mapper
          .draftsFrom(invoiceWith([const EInvoiceItem(name: '雞蛋')]))
          .single;

      expect(draft.copyWith(name: '   ').isImportable, isFalse);
    });

    test('數量為零或負數不可匯入', () {
      final draft = mapper
          .draftsFrom(invoiceWith([const EInvoiceItem(name: '雞蛋')]))
          .single;

      expect(draft.copyWith(amount: 0).isImportable, isFalse);
      expect(draft.copyWith(amount: -1).isImportable, isFalse);
    });
  });
}
