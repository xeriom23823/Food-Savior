import 'package:food_savior/domain/einvoice/einvoice.dart';
import 'package:food_savior/domain/import/food_item_draft.dart';
import 'package:food_savior/domain/import/product_name_cleaner.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/models/food_suggestion.dart';
import 'package:food_savior/models/storage_location.dart';

/// 發票品項 → 食物草稿（design D6）。
///
/// 刻意**不自己判斷類型與效期**：那是 [FoodSuggestionEngine] 的工作，
/// 與快速新增共用同一條路徑。把 `food_presets.json` 做大，兩邊同時變準。
class InvoiceDraftMapper {
  InvoiceDraftMapper({
    required this.suggestionEngine,
    required this.cleaner,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final FoodSuggestionEngine suggestionEngine;
  final ProductNameCleaner cleaner;
  final DateTime Function() _now;

  List<FoodItemDraft> draftsFrom(
    EInvoice invoice, {
    LocationKind? locationKind,
    String? defaultLocationId,
  }) {
    return [
      for (final item in invoice.items)
        _draftFor(
          item,
          issuedDate: invoice.issuedDate,
          locationKind: locationKind,
          defaultLocationId: defaultLocationId,
        ),
    ];
  }

  FoodItemDraft _draftFor(
    EInvoiceItem item, {
    required DateTime issuedDate,
    LocationKind? locationKind,
    String? defaultLocationId,
  }) {
    final cleaned = cleaner.clean(item.name);

    // 建議的效期以「發票開立日」起算，不是以今天起算——使用者可能隔幾天才掃
    // （design D11）。now 只用於狀態推導。
    final suggestion = suggestionEngine.suggest(
      name: cleaned.coreName,
      now: issuedDate,
      locationKind: locationKind,
      defaultLocationId: defaultLocationId,
    );

    // 品名抽出的規格優先於建議機制的數量與單位（einvoice-import 規格）。
    final amount = cleaned.amount ?? item.quantity ?? suggestion.amount;
    final unit = cleaned.unit ?? suggestion.unit;

    return FoodItemDraft(
      sourceLine: item.name,
      name: cleaned.coreName,
      type: suggestion.type,
      expiry: suggestion.expiry,
      storageDate: issuedDate,
      amount: amount,
      unit: unit,
      storageLocationId: suggestion.storageLocationId,
      priceTotal: item.subtotal,
      needsReview: suggestion.source == SuggestionSource.none,
    );
  }

  /// 目前時間。呼叫端轉 [FoodItem] 時用它推導狀態。
  DateTime get now => _now();
}
