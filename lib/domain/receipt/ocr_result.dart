/// 文字辨識的結果，以本專案自己的型別表達（design D2）。
///
/// **刻意不用 ML Kit 的 `TextLine`／`Rect`**：那會讓版面解析器與 Bloc 相依於
/// ML Kit，測試就得跑真的辨識器。用自家型別的代價是一層轉換，換來的是
/// fixture 可以是純 JSON、測試不需要相機也不需要 widget binding。
///
/// `Rect` 來自 `dart:ui`（屬於 Flutter），所以這裡自己定義 [TextBounds]，
/// 讓整個 `lib/domain/receipt/` 維持零 Flutter 相依。
class OcrResult {
  const OcrResult({required this.elements});

  /// 辨識到的所有文字元素，順序不保證——版面解析只看座標（design D1）。
  final List<OcrTextElement> elements;

  bool get isEmpty => elements.isEmpty;

  /// 全部文字串起來，供日期擷取這種不看版面的用途。
  String get plainText => elements.map((e) => e.text).join('\n');
}

/// 一段辨識到的文字與它在影像上的位置。
class OcrTextElement {
  const OcrTextElement({
    required this.text,
    required this.bounds,
    this.confidence,
  });

  final String text;
  final TextBounds bounds;

  /// 辨識器給的信心值，可能沒有。目前只記錄不使用——先看版面解析本身的正確率。
  final double? confidence;

  /// 與 [fromJson] 互逆。Debug 建置在實機辨識後逐行印出，`adb logcat` 撈回來
  /// 就是一份真實版面的 fixture（design D6）。
  Map<String, dynamic> toJson() => {
        'text': text,
        'left': bounds.left,
        'top': bounds.top,
        'right': bounds.right,
        'bottom': bounds.bottom,
        if (confidence != null) 'confidence': confidence,
      };

  factory OcrTextElement.fromJson(Map<String, dynamic> data) => OcrTextElement(
        text: data['text'] as String,
        bounds: TextBounds(
          left: (data['left'] as num).toDouble(),
          top: (data['top'] as num).toDouble(),
          right: (data['right'] as num).toDouble(),
          bottom: (data['bottom'] as num).toDouble(),
        ),
        confidence: (data['confidence'] as num?)?.toDouble(),
      );

  @override
  String toString() => 'OcrTextElement($text, $bounds)';
}

/// 文字在影像上的方框。座標原點在左上，y 往下增加（與 ML Kit 一致）。
class TextBounds {
  const TextBounds({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  final double left;
  final double top;
  final double right;
  final double bottom;

  double get width => right - left;
  double get height => bottom - top;

  /// 兩段文字是否屬於同一列（design D1）。
  ///
  /// 判定是「垂直重疊超過較矮者高度的一半」而不是「中心點接近」：收據上品名
  /// 與金額的字級常常不同，用中心點會把大小字誤判成不同列。
  bool isSameRowAs(TextBounds other) {
    final overlap = (bottom < other.bottom ? bottom : other.bottom) -
        (top > other.top ? top : other.top);
    if (overlap <= 0) return false;
    final shorter = height < other.height ? height : other.height;
    if (shorter <= 0) return false;
    return overlap >= shorter / 2;
  }

  @override
  String toString() => 'TextBounds($left, $top, $right, $bottom)';
}
