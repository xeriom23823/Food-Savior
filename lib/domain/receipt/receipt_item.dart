/// 版面解析出來的一個品項。
///
/// 這是**解析結果**，還不是食物草稿——品名尚未清洗、類型與期限還沒推導。
/// 轉成 `FoodItemDraft` 是 `ReceiptDraftMapper` 的事。
class ReceiptItem {
  const ReceiptItem({
    required this.rawName,
    this.quantity,
    this.unitPrice,
    this.amount,
    this.barcode,
  });

  /// 這一列左側的文字，尚未清洗。
  final String rawName;

  /// 數量。只有數值尾段是三個數字時才知道。
  final double? quantity;

  final int? unitPrice;

  /// 小計。數值尾段的最右側一個數字。
  final int? amount;

  /// 同一列上的商品條碼（EAN-8／UPC-A／EAN-13／GTIN-14）。
  ///
  /// 量販店的收銀機發票會把條碼印在品名旁邊。現在只是記下來；
  /// 之後做條碼 → 商品名稱對照時，這裡就是現成的資料來源。
  final String? barcode;

  @override
  String toString() => 'ReceiptItem($rawName, qty=$quantity, unit=$unitPrice, '
      'amount=$amount, barcode=$barcode)';

  @override
  bool operator ==(Object other) =>
      other is ReceiptItem &&
      other.rawName == rawName &&
      other.quantity == quantity &&
      other.unitPrice == unitPrice &&
      other.amount == amount &&
      other.barcode == barcode;

  @override
  int get hashCode =>
      Object.hash(rawName, quantity, unitPrice, amount, barcode);
}
