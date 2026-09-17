import 'package:food_savior/domain/import/food_item_draft.dart';
import 'package:food_savior/domain/import/product_name_cleaner.dart';
import 'package:food_savior/domain/receipt/receipt_item.dart';
import 'package:food_savior/models/food_suggestion.dart';
import 'package:food_savior/models/storage_location.dart';

/// 收據品項 → 食物草稿。
///
/// 與 `InvoiceDraftMapper` 共用同一條後半段管線（清洗 → 建議 → 草稿），
/// 只有兩處刻意不同：
///
/// 1. **每一列都標 `needsReview`**（receipt-ocr-import 規格）。OCR 可能把 8 讀成
///    B、把兩列併成一列、把金額當成數量；發票 QR 不會。使用者必須逐列看過。
/// 2. 沒有數量時**不塞預設值**，讓草稿頁顯示「未填」而不是假的 1。
class ReceiptDraftMapper {
  ReceiptDraftMapper({
    required this.suggestionEngine,
    required this.cleaner,
  });

  final FoodSuggestionEngine suggestionEngine;
  final ProductNameCleaner cleaner;

  List<FoodItemDraft> draftsFrom(
    List<ReceiptItem> items, {
    required DateTime receiptDate,
    LocationKind? locationKind,
    String? defaultLocationId,
  }) {
    return [
      for (final item in items)
        _draftFor(
          item,
          receiptDate: receiptDate,
          locationKind: locationKind,
          defaultLocationId: defaultLocationId,
        ),
    ];
  }

  FoodItemDraft _draftFor(
    ReceiptItem item, {
    required DateTime receiptDate,
    LocationKind? locationKind,
    String? defaultLocationId,
  }) {
    final cleaned = cleaner.clean(item.rawName);

    // 建議的效期以收據日期起算，不是以今天起算——使用者可能隔幾天才拍
    // （與 InvoiceDraftMapper 的 design D11 一致）。
    final suggestion = suggestionEngine.suggest(
      name: cleaned.coreName,
      now: receiptDate,
      locationKind: locationKind,
      defaultLocationId: defaultLocationId,
    );

    // 品名抽出的規格優先於收據上的數量：「可樂 600」的 600ML 比「1」有用。
    final amount = cleaned.amount ?? item.quantity;
    final unit = cleaned.unit ?? (amount == null ? null : suggestion.unit);

    return FoodItemDraft(
      sourceLine: item.rawName,
      name: cleaned.coreName,
      type: suggestion.type,
      expiry: suggestion.expiry,
      storageDate: receiptDate,
      amount: amount,
      unit: unit,
      storageLocationId: suggestion.storageLocationId,
      priceTotal: item.amount,
      // 不論品名有沒有命中建議，收據草稿一律待確認。
      needsReview: true,
    );
  }
}
