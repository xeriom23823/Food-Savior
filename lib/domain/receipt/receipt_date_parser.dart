/// 從收據文字擷取日期（receipt-ocr-import 規格）。
///
/// 日期**不是**阻擋匯入的理由：找不到就用今天，照常進行。
/// 純 Dart，`now` 由呼叫端注入。
abstract final class ReceiptDateParser {
  /// 民國年的合理上界。超過就不是民國年，改當西元處理。
  static const int maxRocYear = 300;

  /// 有分隔符的日期：`2026/09/15`、`2026-09-15`、`2026.09.15`、`115/09/14`、
  /// `2026年9月8日`。年份 2–4 位（2 位是民國、4 位是西元），月日各 1–2 位。
  static final RegExp _separated = RegExp(
    r'(\d{2,4})\s*[/\-.年]\s*(\d{1,2})\s*[/\-.月]\s*(\d{1,2})',
  );

  /// 無分隔符的 `YYYYMMDD`：收銀機發票常見（`20120323 16:29`）。
  /// 前後不能再接數字，否則 13 碼條碼裡的任何 8 碼都會被抓出來。
  static final RegExp _compact = RegExp(
    r'(?<!\d)((?:19|20)\d{2})(0[1-9]|1[0-2])(0[1-9]|[12]\d|3[01])(?!\d)',
  );

  /// 從 [text] 找出收據日期。
  ///
  /// 兩種格式的候選依**在文字中出現的位置**排序，取第一個合法且不在未來的。
  /// 找不到、解析不出合法日期、或算出來的日期**晚於今天**時，一律回傳今天的
  /// 當日零時——未來日期幾乎都是辨識錯誤（`8` 讀成 `9` 之類），不該讓它
  /// 變成存放日期。
  static DateTime parse(String text, {required DateTime now}) {
    final today = DateTime(now.year, now.month, now.day);

    final candidates = <(int, DateTime)>[
      for (final match in _separated.allMatches(text))
        if (_fromSeparated(match, text) case final date?) (match.start, date),
      for (final match in _compact.allMatches(text))
        if (_fromCompact(match) case final date?) (match.start, date),
    ]..sort((a, b) => a.$1.compareTo(b.$1));

    for (final (_, date) in candidates) {
      if (date.isAfter(today)) continue;
      return date;
    }
    return today;
  }

  static DateTime? _fromSeparated(RegExpMatch match, String text) {
    // 「中華民國101年3-4月份」是發票**期別**，不是日期：`101年3-4` 會被當成
    // 民國 101 年 3 月 4 日。判準是最後一組數字後面緊接著「月」。
    final after = match.end < text.length ? text[match.end] : '';
    if (after == '月') return null;

    return _build(
      rawYear: int.tryParse(match.group(1)!),
      month: int.tryParse(match.group(2)!),
      day: int.tryParse(match.group(3)!),
    );
  }

  static DateTime? _fromCompact(RegExpMatch match) => _build(
        rawYear: int.tryParse(match.group(1)!),
        month: int.tryParse(match.group(2)!),
        day: int.tryParse(match.group(3)!),
      );

  static DateTime? _build({
    required int? rawYear,
    required int? month,
    required int? day,
  }) {
    if (rawYear == null || month == null || day == null) return null;
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;

    // 4 位數是西元；3 位以下是民國（`115` → 2026、`99` → 2010）。
    final year = rawYear > maxRocYear ? rawYear : rawYear + 1911;
    final date = DateTime(year, month, day);
    // DateTime 會把 2 月 31 日捲到 3 月，捲過就是原本的日期不合法。
    if (date.month != month || date.day != day) return null;
    return date;
  }
}
