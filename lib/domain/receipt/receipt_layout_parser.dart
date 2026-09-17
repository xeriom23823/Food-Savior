import 'package:food_savior/domain/receipt/ocr_result.dart';
import 'package:food_savior/domain/receipt/receipt_item.dart';

/// 把辨識結果的**版面**還原成品項（design D1）。
///
/// 收據沒有規格，但有版面：品名靠左、數字靠右、一列一項。把辨識結果當成一整段
/// 文字去跑正則，會在第一張排版稍有不同的收據上崩掉；用座標分列分欄則對版面
/// 變化有韌性。
///
/// 四張真實收據（麥當勞、台糖量販、電子發票明細、大買家收銀機發票）各自打破了
/// 一個原本的假設，現在的結構是被它們逼出來的：
///
/// 1. **先分類 token 再分列分欄**：數字、識別碼（條碼／序號）、稅別與運算符、
///    短代碼、文字。不分類的話 13 碼條碼會被當成一個 4 兆元的價格。
/// 2. **落單的數字列雙向配對**：台糖是品名在上、數字在下；大買家是條碼與金額
///    在上、品名在下。而且不能配到表頭表尾上。
/// 3. **表頭區以「第一個像品項的列」為界**，不是「第一個有數字的列」——
///    電話號碼也有數字。
/// 4. **`標籤:值` 一律是中繼資料**（`NO:`、`TEL:`、`機:`、`頁:`）。店家不可能
///    窮舉，但這個形式非常穩定。
///
/// 純 Dart：雜訊詞由外部注入（來源是 `assets/data/receipt_noise_terms.json`），
/// 這個類別不碰 asset，測試不需要 widget binding。
class ReceiptLayoutParser {
  ReceiptLayoutParser({required List<String> noiseTerms})
      : _noiseTerms = [
          for (final term in noiseTerms)
            if (term.trim().isNotEmpty) _stripSpaces(term).toLowerCase(),
        ];

  final List<String> _noiseTerms;

  /// 數值尾段最多取幾個——數量、單價、金額。再多就不是價格欄位了。
  static const int maxNumericTail = 3;

  /// 數字與前一段文字的間距小於「字高 × 這個比例」時，視為黏在品名上而不是價格。
  static const double _gluedGapRatio = 1.5;

  /// 連續這麼多位以上的純數字是識別碼（條碼、序號、電話），不是價格。
  /// 台灣沒有八位數的品項金額。
  static const int _identifierMinDigits = 8;

  /// 商品條碼的合法長度：EAN-8、UPC-A、EAN-13、GTIN-14。
  static const Set<int> _barcodeLengths = {8, 12, 13, 14};

  List<ReceiptItem> parse(OcrResult result) {
    final rows = _rows(result.elements).map(_split).toList();

    // 順序有意義：先把落單的數字配回品名，才知道哪些列「真的」像品項；
    // 表頭偵測依賴這個判斷。
    _mergeOrphanNumbers(rows);
    _dropHeaderZone(rows);
    _dropFooterSentences(rows);

    return [
      for (final row in rows)
        if (_itemFrom(row) case final item?) item,
    ];
  }

  // ---------------------------------------------------------------- 分列

  /// 依垂直重疊把元素分群成列，列由上而下、列內由左而右。
  ///
  /// 刻意不用辨識器自己的分行結果：收據上品名與金額中間隔著大片空白，
  /// ML Kit 常把它們分進不同的 `TextBlock`（design D1）。
  List<List<OcrTextElement>> _rows(List<OcrTextElement> elements) {
    final sorted = [...elements]
      ..sort((a, b) => a.bounds.top.compareTo(b.bounds.top));

    final rows = <List<OcrTextElement>>[];
    for (final element in sorted) {
      final row = rows
          .where((row) =>
              row.any((member) => member.bounds.isSameRowAs(element.bounds)))
          .firstOrNull;
      if (row == null) {
        rows.add([element]);
      } else {
        row.add(element);
      }
    }

    for (final row in rows) {
      row.sort((a, b) => a.bounds.left.compareTo(b.bounds.left));
    }
    return rows;
  }

  // ---------------------------------------------------------------- 分欄

  /// 把一列拆成「品名」「數值尾段」「條碼」。
  ///
  /// 從最右側往左取連續的數字：品名長度不定，數字欄位固定靠右。從左往右要先
  /// 知道品名在哪裡結束，那是循環論證。
  _Row _split(List<OcrTextElement> row) {
    final numbers = <num>[];
    var index = row.length - 1;

    while (index >= 0 && numbers.length < maxNumericTail) {
      final token = row[index].text;
      final kind = _classify(token);
      if (kind == _Kind.number) {
        numbers.insertAll(0, _parseNumbers(token));
        index--;
      } else if (kind == _Kind.marker) {
        // 稅別後綴與運算符永遠可以跳：它們可能出現在最右邊（`40 TX`），
        // 那時還沒抓到任何數字。
        index--;
      } else if (kind == _Kind.code && numbers.isNotEmpty) {
        // 促銷代碼（`1P`）只在已經抓到數字之後才跳，否則會把品名吃掉。
        index--;
      } else {
        break;
      }
    }
    if (numbers.length > maxNumericTail) {
      numbers.removeRange(0, numbers.length - maxNumericTail);
    }

    // 品名尾端的數字不是價格：「可樂 600」的 600 是容量。
    //
    // 判準是**水平間距**而不是數值大小：價格欄靠右，與品名之間有明顯的留白；
    // 黏在品名後面的數字則只隔著一個字的距離。這與 D1 的「版面優先」一致。
    while (numbers.isNotEmpty && index >= 0 && index + 1 < row.length) {
      final numberStart = row[index + 1];
      final gap = numberStart.bounds.left - row[index].bounds.right;
      if (gap > numberStart.bounds.height * _gluedGapRatio) break;
      numbers.removeAt(0);
      index++;
    }

    // 品名側：識別碼不是品名的一部分——條碼記下來，其餘（序號、電話）丟掉。
    String? barcode;
    final nameParts = <String>[];
    for (final element in row.take(index + 1)) {
      final text = element.text.trim();
      if (_classify(text) == _Kind.identifier) {
        final digits = _stripSpaces(text);
        if (_barcodeLengths.contains(digits.length)) barcode ??= digits;
        continue;
      }
      nameParts.add(text);
    }

    return _Row(
      name: nameParts.join(' ').trim(),
      numbers: numbers,
      barcode: barcode,
    );
  }

  // ---------------------------------------------------------------- 配對與表頭

  /// 把「整列只有數字」的列配回相鄰的品名列。
  ///
  /// - 台糖量販：品名獨佔一列，`1 X 189 = 189TX` 在下一列 → **往上**配。
  /// - 大買家：`4712123724362 $200T` 在上一列，品名在下一列 → **往下**配。
  ///
  /// 兩個方向都只配到「有品名、沒價格、而且看起來像品項」的列上——
  /// 否則條碼列會被配到它上面的 `機:020102 @:170 頁:2` 去。
  /// 上下都可以時優先往上：台灣收據以品名在上為主。
  void _mergeOrphanNumbers(List<_Row> rows) {
    for (var index = rows.length - 1; index >= 0; index--) {
      final row = rows[index];
      if (!row.isNumbersOnly) continue;

      final above = index > 0 ? rows[index - 1] : null;
      final below = index + 1 < rows.length ? rows[index + 1] : null;

      if (above != null && _canReceiveNumbers(above)) {
        rows[index - 1] = above.withNumbers(row.numbers, row.barcode);
        rows.removeAt(index);
      } else if (below != null && _canReceiveNumbers(below)) {
        rows[index + 1] = below.withNumbers(row.numbers, row.barcode);
        rows.removeAt(index);
      }
    }
  }

  /// 這一列能不能接收落單的數字：有品名、還沒有價格、而且不是中繼資料。
  bool _canReceiveNumbers(_Row row) =>
      row.numbers.isEmpty && _looksLikeItemName(row.name);

  /// 丟掉第一個像品項的列之前的所有列。
  ///
  /// 店名沒有辦法用關鍵字窮舉（「全家便利商店」「大買家實業股份有限公司」…），
  /// 但它的位置是穩定的：收據一定從店家資訊開始。
  ///
  /// 判準是「像品項」而不是「有數字」——電話號碼、序號、統編都有數字，
  /// 用「有數字」當界線會在麥當勞的 `餐廳電話:02-2276 8295` 就停下來。
  void _dropHeaderZone(List<_Row> rows) {
    final firstItem = rows.indexWhere(_isPlausibleItem);
    if (firstItem <= 0) return;
    rows.removeRange(0, firstItem);
  }

  /// 丟掉最後一個像品項的列**之後**、沒有任何數字的列。
  ///
  /// 表尾是宣導文字（「使用牌照稅開徵」「自4月1日起」「請妥善保管」）與
  /// 會員資訊。它們跟店名一樣沒辦法窮舉，但位置一樣穩定：在品項區之後，
  /// 而且沒有價格。品項區內部的無價格列（品名獨佔一列、金額在下一列）
  /// 在此之前已經被配對過了，所以不會被誤刪。
  void _dropFooterSentences(List<_Row> rows) {
    final lastItem = rows.lastIndexWhere(_isPlausibleItem);
    if (lastItem < 0) return;
    final kept = [
      ...rows.take(lastItem + 1),
      ...rows.skip(lastItem + 1).where((row) => row.numbers.isNotEmpty),
    ];
    rows
      ..clear()
      ..addAll(kept);
  }

  bool _isPlausibleItem(_Row row) =>
      row.numbers.isNotEmpty && _looksLikeItemName(row.name);

  /// 這段文字像不像品名：有字、不是表頭表尾、不是 `標籤:值`。
  bool _looksLikeItemName(String name) =>
      name.isNotEmpty &&
      _hasWordCharacter(name) &&
      !_isNoise(name) &&
      !_isLabelValue(name);

  // ---------------------------------------------------------------- 產生品項

  ReceiptItem? _itemFrom(_Row row) {
    if (!_looksLikeItemName(row.name)) return null;

    return switch (row.numbers.length) {
      // 三個數字是數量、單價、金額——但**順序各家不同**：
      // 麥當勞是「單價 數量 金額」、台糖是「數量 X 單價 = 金額」、
      // 電子發票明細是「單價*數量 金額」。位置靠不住，所以改用一個在零售上
      // 幾乎永遠成立的不變式：**數量比單價小**。
      //
      // 已知會錯的情形：單價 1 元的東西買 5 個（[5,1,5] 會判成買 1 個 5 元）。
      // 罕見而且使用者在草稿頁一眼就看得出來，不值得為它加規則。
      3 => ReceiptItem(
          rawName: row.name,
          quantity: _smaller(row.numbers[0], row.numbers[1]).toDouble(),
          unitPrice: _larger(row.numbers[0], row.numbers[1]).round(),
          amount: row.numbers[2].round(),
          barcode: row.barcode,
        ),
      // 單價、金額。數量不猜——規格說未知就是未知。
      2 => ReceiptItem(
          rawName: row.name,
          unitPrice: row.numbers[0].round(),
          amount: row.numbers[1].round(),
          barcode: row.barcode,
        ),
      1 => ReceiptItem(
          rawName: row.name,
          amount: row.numbers[0].round(),
          barcode: row.barcode,
        ),
      // 沒有數字的列仍然成為品項：品名本身就有價值，
      // 數量與期限使用者本來就要填。
      _ => ReceiptItem(rawName: row.name, barcode: row.barcode),
    };
  }

  static num _smaller(num a, num b) => a < b ? a : b;
  static num _larger(num a, num b) => a < b ? b : a;

  // ---------------------------------------------------------------- 判定

  /// 這一列是不是表頭表尾或結帳資訊。
  ///
  /// 比對前把空白全部去掉：收據印表機會在中文之間塞空格（「總 計:」），
  /// 不處理的話雜訊詞一個都對不上。
  bool _isNoise(String name) {
    final normalized = _stripSpaces(name).toLowerCase();
    return _noiseTerms.any(normalized.contains);
  }

  /// `標籤:值` 形式的中繼資料：`NO:80050683`、`TEL:02-8953-9111`、
  /// `機:020102`、`頁:2`、`店名:台北店`。
  ///
  /// 店家與 POS 系統不可能窮舉，但「開頭一到六個字接冒號」這個形式非常穩定，
  /// 而且真的品名幾乎不會長這樣。
  static final RegExp _labelValue = RegExp(r'^[^:：]{1,6}[:：]');

  static bool _isLabelValue(String name) =>
      _labelValue.hasMatch(_stripSpaces(name));

  /// 是否含有可以當品名的字元（CJK 或英文字母）。
  static bool _hasWordCharacter(String value) {
    for (final rune in value.runes) {
      final isCjk = rune >= 0x3400 && rune <= 0x9FFF;
      final isLatin =
          (rune >= 0x41 && rune <= 0x5A) || (rune >= 0x61 && rune <= 0x7A);
      if (isCjk || isLatin) return true;
    }
    return false;
  }

  static bool _hasCjk(String value) =>
      value.runes.any((rune) => rune >= 0x3400 && rune <= 0x9FFF);

  static String _stripSpaces(String value) =>
      value.replaceAll(RegExp(r'[\s　]+'), '');

  // ---------------------------------------------------------------- token 分類

  /// **順序有意義**：識別碼要在數字之前判，否則 13 碼條碼會被當成價格。
  static _Kind _classify(String raw) {
    final text = _stripSpaces(raw);
    if (text.isEmpty) return _Kind.text;
    if (_isTailMarker(text)) return _Kind.marker;
    if (_isIdentifier(text)) return _Kind.identifier;
    if (_parseNumbers(text).isNotEmpty) return _Kind.number;
    if (text.length <= 3 && !_hasCjk(text)) return _Kind.code;
    return _Kind.text;
  }

  /// 稅別後綴與運算符。
  static bool _isTailMarker(String text) {
    const markers = {
      'tx', 'zx', 'fx', 't', 'z', 'f', 'x', //
      '=', '*', '×', '@', '元',
    };
    return markers.contains(text.toLowerCase());
  }

  static final RegExp _digitsOnly = RegExp(r'^\d+$');

  /// 連續八位以上的純數字：條碼、序號、電話、統編。不是價格。
  static bool _isIdentifier(String text) =>
      text.length >= _identifierMinDigits && _digitsOnly.hasMatch(text);

  /// 單價*數量：兩邊都是數字才算，避免把「25G*10」這種規格拆開。
  static final RegExp _pricePair =
      RegExp(r'^(\d+(?:\.\d+)?)[*x×X](\d+(?:\.\d+)?)$');

  /// 把一段文字解析成它含有的數值。
  ///
  /// 回傳空清單代表「這不是數字」——所以「400ML」必須解析失敗，
  /// 否則品名裡的規格會被誤當成金額。
  ///
  /// 可能回傳兩個值：`20*2` 是「單價乘數量」擠在同一格（電子發票明細的版面）。
  static List<num> _parseNumbers(String raw) {
    final text = _stripSpaces(raw);
    if (text.isEmpty) return const [];

    final pair = _pricePair.firstMatch(text);
    if (pair != null) {
      return [num.parse(pair.group(1)!), num.parse(pair.group(2)!)];
    }

    final value = _parseNumber(text);
    return value == null ? const [] : [value];
  }

  /// 稅別後綴：TX（應稅）、Z／ZX（零稅率）、F／FX（免稅）。
  static final RegExp _taxedAmount = RegExp(
    r'^(-?\d+(?:\.\d+)?)(tx|zx|fx|t|z|f|x)$',
    caseSensitive: false,
  );

  /// 把價格欄位常見的裝飾去掉再解析。
  static num? _parseNumber(String raw) {
    var text = raw;
    for (final prefix in const ['nt\$', 'nt', '\$', '＄']) {
      if (text.toLowerCase().startsWith(prefix)) {
        text = text.substring(prefix.length);
        break;
      }
    }
    text = text.replaceAll(',', '').replaceAll('，', '').replaceAll('元', '');

    // 只在剝掉後綴之後剩下的是數字時才剝，免得把 `400ML` 變成 400。
    final taxed = _taxedAmount.firstMatch(text);
    if (taxed != null) return num.parse(taxed.group(1)!);

    if (text.endsWith('.')) text = text.substring(0, text.length - 1);
    if (text.isEmpty) return null;
    return num.tryParse(text);
  }
}

enum _Kind { number, identifier, marker, code, text }

/// 一列拆成品名、數值尾段與條碼之後的中間結果。
class _Row {
  const _Row({required this.name, required this.numbers, this.barcode});

  final String name;

  /// 保留原始數值：秤重商品的數量是小數（`0.35` 公斤），round 掉會變成 0。
  final List<num> numbers;

  final String? barcode;

  bool get isNumbersOnly => name.isEmpty && numbers.isNotEmpty;

  _Row withNumbers(List<num> numbers, String? barcode) =>
      _Row(name: name, numbers: numbers, barcode: this.barcode ?? barcode);
}
