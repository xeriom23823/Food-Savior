import 'package:food_savior/models/food_item.dart';

/// 清洗後的 POS 品名（design D5）。
class CleanedProductName {
  const CleanedProductName({
    required this.coreName,
    this.amount,
    this.unit,
  });

  /// 核心名稱。清洗後為空時等於原始品名——寧可冗長，不要無名。
  final String coreName;

  /// 從品名抽出的規格數量（`400ML` → 400）。
  final double? amount;

  /// 規格對應的單位。與 [amount] 同時存在或同時為 null。
  final Unit? unit;

  bool get hasSpec => amount != null && unit != null;

  @override
  String toString() => 'CleanedProductName($coreName, $amount, $unit)';
}

/// 把 `統一AB優酪乳400ML特價` 這種 POS 品名清洗成核心名稱與規格。
///
/// **只做剝除，不做替換或推論**（design D5）：錯誤的替換會讓使用者看到一個
/// 他不認識的名字，比看到冗長的原始品名更糟。
///
/// 純 Dart：雜訊詞表由外部注入（來源是 `assets/data/product_noise_terms.json`），
/// 這個類別不碰 asset，測試不需要 widget binding。
class ProductNameCleaner {
  ProductNameCleaner({required List<String> noiseTerms})
      // 先長後短：「統一超商」必須比「統一」先被剝掉，否則會剩下「超商」。
      : _noiseTerms = List<String>.of(noiseTerms)
          ..sort((a, b) => b.length.compareTo(a.length));

  final List<String> _noiseTerms;

  /// 規格樣式。**順序有意義**：`kg` 必須排在 `g` 前面，否則 `2kg` 會被當成 `2k` + `g`。
  static final List<_SpecPattern> _specPatterns = [
    _SpecPattern(r'(\d+(?:\.\d+)?)\s*(?:kg|公斤)', Unit.gram, 1000),
    _SpecPattern(r'(\d+(?:\.\d+)?)\s*(?:ml|cc|毫升|公撮)', Unit.milliliter, 1),
    _SpecPattern(r'(\d+(?:\.\d+)?)\s*(?:公升|公昇)', Unit.milliliter, 1000),
    _SpecPattern(r'(\d+(?:\.\d+)?)\s*(?:gm|g|公克|克)(?![a-z])', Unit.gram, 1),
    _SpecPattern(r'(\d+)\s*(?:入|顆|個|支|片|條|尾|束)', Unit.piece, 1),
    _SpecPattern(r'(\d+)\s*(?:包|袋)', Unit.bag, 1),
    _SpecPattern(r'(\d+)\s*盒', Unit.box, 1),
    _SpecPattern(r'(\d+)\s*罐', Unit.can, 1),
    _SpecPattern(r'(\d+)\s*瓶', Unit.bottle, 1),
  ];

  /// 沒有數字、只以 `/顆` 這種形式表示的計價單位。
  static final RegExp _trailingUnit =
      RegExp(r'[/／]\s*(顆|個|包|盒|罐|瓶|條|支|片|尾|束|斤|台斤)\s*$');

  static final RegExp _bracketed = RegExp(r'[\(\[{【〔（][^\)\]}】〕）]*[\)\]}】〕）]');
  static final RegExp _separators =
      RegExp(r'^[\s\-_/／·．.、,，*+]+|[\s\-_/／·．.、,，*+]+$');

  static const Map<String, Unit> _bareUnits = {
    '顆': Unit.piece,
    '個': Unit.piece,
    '條': Unit.piece,
    '支': Unit.piece,
    '片': Unit.piece,
    '尾': Unit.piece,
    '束': Unit.piece,
    '包': Unit.bag,
    '盒': Unit.box,
    '罐': Unit.can,
    '瓶': Unit.bottle,
    '斤': Unit.gram,
    '台斤': Unit.gram,
  };

  CleanedProductName clean(String raw) {
    // 1. 沿用既有的正規化（全形轉半形、空白收斂、小寫），分群與模板比對共用同一個
    //    函式，發票匯入才不會跟快速新增對不上。
    var working = normalizeFoodName(raw);
    final original = working.isEmpty ? raw.trim() : working;

    // 2. 規格必須在剝括號**之前**抽，否則 `(約300g)` 會連同括號一起被丟掉。
    double? amount;
    Unit? unit;
    for (final pattern in _specPatterns) {
      final match = pattern.regExp.firstMatch(working);
      if (match == null) continue;
      final value = double.tryParse(match.group(1)!);
      if (value == null || value <= 0) continue;
      amount = value * pattern.multiplier;
      unit = pattern.unit;
      working = working.replaceRange(match.start, match.end, ' ');
      break;
    }

    // 沒有數字的計價單位（`高麗菜/顆`）：拿得到單位，數量留給呼叫端給預設值。
    if (unit == null) {
      final match = _trailingUnit.firstMatch(working);
      if (match != null) {
        unit = _bareUnits[match.group(1)!];
        if (unit != null) {
          amount = 1;
          working = working.replaceRange(match.start, match.end, ' ');
        }
      }
    }

    // 3. 剝括號與其內容（溫層、規格說明、贈品備註都躲在裡面）。
    working = working.replaceAll(_bracketed, ' ');

    // 4. 剝雜訊詞。
    for (final term in _noiseTerms) {
      if (term.isEmpty) continue;
      working = working.replaceAll(term, ' ');
    }

    final core = _tidy(working);
    return CleanedProductName(
      coreName: core.isEmpty ? original : core,
      amount: amount,
      unit: unit,
    );
  }

  static String _tidy(String value) =>
      value.replaceAll(RegExp(r'\s+'), ' ').replaceAll(_separators, '').trim();
}

class _SpecPattern {
  _SpecPattern(String source, this.unit, this.multiplier)
      : regExp = RegExp(source);

  final RegExp regExp;
  final Unit unit;
  final double multiplier;
}
