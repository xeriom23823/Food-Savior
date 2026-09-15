import 'dart:convert';

import 'package:food_savior/domain/einvoice/einvoice.dart';
import 'package:food_savior/domain/einvoice/einvoice_parse_failure.dart';

/// 台灣電子發票證明聯二維條碼解析器（design D3）。
///
/// 規格來源：財政部電子發票整合服務平台《電子發票證明聯二維條碼規格》。
/// 規格會改版——改版時先加 `test/fixtures/einvoice/` 的 fixture 重現問題，再改實作。
///
/// 無狀態純函式。「已掃到左碼、還在等右碼」是互動狀態，屬於 ImportBloc（design D4）。
abstract final class EInvoiceQrParser {
  /// 左碼固定欄位的總長度。之後才是 `:` 分隔的品項區。
  static const int leftFixedLength = 77;

  /// 右碼的起始標記。
  static const String rightCodePrefix = '**';

  /// 判斷一段掃到的內容是不是右碼。左右碼可以任意順序掃描。
  static bool isRightCode(String raw) => raw.startsWith(rightCodePrefix);

  /// 解析左碼（可選地合併右碼）。
  ///
  /// [right] 為 null 時只解析左碼所載的品項；此時 [EInvoice.isComplete]
  /// 會告訴呼叫端還需不需要等右碼。
  static EInvoiceParseResult parse(String left, {String? right}) {
    if (left.length < leftFixedLength) {
      return const EInvoiceParseFailure(ParseFailureReason.tooShort);
    }
    if (right != null && !isRightCode(right)) {
      return const EInvoiceParseFailure(ParseFailureReason.codeMismatch);
    }

    final invoiceNumber = left.substring(0, 10);
    final issuedDate = _parseRocDate(left.substring(10, 17));
    if (issuedDate == null) {
      return const EInvoiceParseFailure(ParseFailureReason.malformed);
    }
    final totalAmount = _parseHex(left.substring(29, 37));

    // 固定區之後是 `:營業人自行使用區:記載筆數:總筆數:編碼參數:品名:數量:單價:…`
    final tail = left.substring(leftFixedLength);
    final fields = tail.split(':');
    // split 後的第 0 格是固定區與第一個 `:` 之間的空字串。
    // 少於 5 格代表連表頭都不完整。
    if (fields.length < 5) {
      return const EInvoiceParseFailure(ParseFailureReason.malformed);
    }

    final leftItemCount = int.tryParse(fields[2].trim());
    final totalItemCount = int.tryParse(fields[3].trim());
    if (leftItemCount == null || totalItemCount == null) {
      return const EInvoiceParseFailure(ParseFailureReason.malformed);
    }

    final encoding = _encodingOf(fields[4].trim());
    if (encoding == _NameEncoding.big5) {
      return const EInvoiceParseFailure(ParseFailureReason.unsupportedBig5);
    }

    final items = <EInvoiceItem>[
      ..._parseItems(fields.sublist(5), leftItemCount, encoding),
    ];

    if (right != null) {
      final remaining = totalItemCount - items.length;
      if (remaining > 0) {
        items.addAll(_parseItems(
          _rightCodeFields(right),
          remaining,
          encoding,
        ));
      }
    }

    return EInvoiceParseSuccess(EInvoice(
      invoiceNumber: invoiceNumber,
      issuedDate: issuedDate,
      items: items,
      declaredItemCount: totalItemCount,
      totalAmount: totalAmount,
    ));
  }

  /// 右碼去掉 `**` 前綴（與其後可能緊接的分隔符）後，同樣是 `:` 分隔的品項區。
  static List<String> _rightCodeFields(String right) {
    var body = right.substring(rightCodePrefix.length);
    if (body.startsWith(':')) body = body.substring(1);
    if (body.isEmpty) return const [];
    return body.split(':');
  }

  /// 以「品目筆數」為準切割品項，而不是以 `:` 的出現次數。
  ///
  /// 品名內可以含 `:`（規格允許），所以**從右往左**取：每個品項的最後兩格
  /// 必然是數量與單價，剩下的格數扣掉「前面每個品項至少要留 3 格」之後，
  /// 全部歸給目前這個品項的品名。這樣冒號出現在任何一個品名裡都能正確還原。
  static List<EInvoiceItem> _parseItems(
    List<String> fields,
    int count,
    _NameEncoding encoding,
  ) {
    if (count <= 0 || fields.isEmpty) return const [];

    // 宣告的筆數可能多於這段實際載有的品項（發票資料不全、或右碼還沒掃到）。
    // 以實際欄位數推得的上限收斂，否則往回數時會把不存在的品項也預留掉。
    // 品名含冒號時欄位數只會**多於** 3×筆數，所以這個上限不會誤縮。
    final capacity = fields.length ~/ 3;
    final effectiveCount = count < capacity ? count : capacity;
    if (effectiveCount <= 0) return const [];

    final available = List<String>.of(fields);
    final items = <EInvoiceItem>[];

    for (var index = effectiveCount - 1; index >= 0; index--) {
      // 這個品項之前還有 index 個品項，每個至少要留 3 格（名稱、數量、單價）。
      final reserved = index * 3;
      if (available.length - reserved < 3) break;

      final unitPrice = _parseAmount(available.removeLast());
      final quantity = double.tryParse(available.removeLast().trim());
      final nameFieldCount = available.length - reserved;
      final nameFields = available.sublist(available.length - nameFieldCount);
      available.removeRange(
          available.length - nameFieldCount, available.length);

      final name = _decodeName(nameFields.join(':'), encoding);
      if (name.isEmpty) continue;
      items.add(EInvoiceItem(
        name: name,
        quantity: quantity,
        unitPrice: unitPrice,
      ));
    }

    // 從右往左收集，回傳前轉回發票上的順序。
    return items.reversed.toList();
  }

  static String _decodeName(String raw, _NameEncoding encoding) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';
    if (encoding != _NameEncoding.base64) return trimmed;
    try {
      return utf8.decode(base64.decode(base64.normalize(trimmed)));
    } on FormatException {
      // 宣告是 Base64 但實際不是：退回原字串，讓使用者自己看得懂總比空白好。
      return trimmed;
    }
  }

  /// 民國 `yyyMMdd` → 當地時間當日零時。
  static DateTime? _parseRocDate(String raw) {
    if (raw.length != 7) return null;
    final rocYear = int.tryParse(raw.substring(0, 3));
    final month = int.tryParse(raw.substring(3, 5));
    final day = int.tryParse(raw.substring(5, 7));
    if (rocYear == null || month == null || day == null) return null;
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    final date = DateTime(rocYear + 1911, month, day);
    // DateTime 會把 2 月 31 日捲到 3 月，捲過就是原本的日期不合法。
    if (date.month != month || date.day != day) return null;
    return date;
  }

  /// 左碼的銷售額與總計額以 16 進位記載。
  static int? _parseHex(String raw) => int.tryParse(raw.trim(), radix: 16);

  /// 單價是 10 進位。小數點的發票也見過，四捨五入為整數元。
  static int? _parseAmount(String raw) {
    final value = double.tryParse(raw.trim());
    return value?.round();
  }

  static _NameEncoding _encodingOf(String raw) => switch (raw) {
        '0' => _NameEncoding.big5,
        '2' => _NameEncoding.base64,
        _ => _NameEncoding.utf8,
      };
}

enum _NameEncoding { big5, utf8, base64 }
