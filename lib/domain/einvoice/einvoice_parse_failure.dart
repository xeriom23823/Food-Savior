import 'package:food_savior/domain/einvoice/einvoice.dart';

/// 解析失敗的原因。每一個都對應一個 l10n key（design D12）。
///
/// 刻意不用例外：解析失敗是**預期中的正常結果**（使用者可能掃到任何東西），
/// 不是程式錯誤。呼叫端必須處理每一種原因。
enum ParseFailureReason {
  /// 內容太短，不可能是發票左碼。掃到其他 QR 時最常見。
  tooShort,

  /// 中文編碼參數為 Big5。不猜測解碼結果，直接請使用者手動輸入。
  unsupportedBig5,

  /// 右碼與目前持有的左碼不是同一張發票。
  codeMismatch,

  /// 格式符合長度但欄位內容不合法（日期、筆數解不出來）。
  malformed,
}

/// 解析結果：成功帶 [EInvoice]，失敗帶 [ParseFailureReason]。
sealed class EInvoiceParseResult {
  const EInvoiceParseResult();
}

class EInvoiceParseSuccess extends EInvoiceParseResult {
  const EInvoiceParseSuccess(this.invoice);

  final EInvoice invoice;

  @override
  String toString() => 'EInvoiceParseSuccess(${invoice.invoiceNumber})';
}

class EInvoiceParseFailure extends EInvoiceParseResult {
  const EInvoiceParseFailure(this.reason);

  final ParseFailureReason reason;

  @override
  String toString() => 'EInvoiceParseFailure($reason)';
}
