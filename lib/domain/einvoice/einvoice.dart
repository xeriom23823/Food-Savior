/// 一張電子發票證明聯解析出來的內容（design D3）。
///
/// 純 Dart：不 import 任何 `package:flutter`，測試不需要 widget binding。
/// 買方／賣方統一編號與加密驗證資訊**刻意不保留**——它們是個資，
/// 解析流程用不到，留著只會增加外洩面（design「隱私」）。
class EInvoice {
  const EInvoice({
    required this.invoiceNumber,
    required this.issuedDate,
    required this.items,
    required this.declaredItemCount,
    this.totalAmount,
  });

  /// 發票字軌 + 號碼，共 10 碼（例 `AB12345678`）。防重複匯入用這個當鍵。
  final String invoiceNumber;

  /// 開立日期。民國年已換算為西元，且為當地時間當日零時。
  final DateTime issuedDate;

  final List<EInvoiceItem> items;

  /// 左碼宣告的「該張發票品目總筆數」。
  ///
  /// 與 [items] 長度不一致代表右碼還沒掃到、或發票本身資料不全。
  final int declaredItemCount;

  /// 總計額（含稅）。左碼以 16 進位記載。
  final int? totalAmount;

  /// 品項是否已蒐集完整。用來決定要不要繼續等右碼。
  bool get isComplete => items.length >= declaredItemCount;
}

/// 發票上的一個品項。數量與單價可能解析失敗，所以都是 nullable。
class EInvoiceItem {
  const EInvoiceItem({required this.name, this.quantity, this.unitPrice});

  /// 品名。已依中文編碼參數解碼，但**尚未清洗**（還帶著品牌與促銷字樣）。
  final String name;

  final double? quantity;
  final int? unitPrice;

  /// 小計。數量或單價缺一就是 null，不猜。
  int? get subtotal {
    final q = quantity;
    final p = unitPrice;
    if (q == null || p == null) return null;
    return (q * p).round();
  }

  @override
  String toString() => 'EInvoiceItem($name, $quantity, $unitPrice)';
}
