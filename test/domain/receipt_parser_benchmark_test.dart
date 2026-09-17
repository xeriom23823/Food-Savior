import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/domain/receipt/ocr_result.dart';
import 'package:food_savior/domain/receipt/receipt_date_parser.dart';
import 'package:food_savior/domain/receipt/receipt_item.dart';
import 'package:food_savior/domain/receipt/receipt_layout_parser.dart';

/// 版面解析的基準（receipt-ocr-import 規格）。
///
/// 存在的理由與 `name_suggestion_benchmark_test` 相同：沒有基準就無從判斷
/// 「修好 A 版面是不是弄壞了 B 版面」。收據的版面變化比品名更沒有上界，
/// 所以這道防線更重要。
///
/// **同時量 recall 與 precision**：只量 recall 的話，一個「什麼都回傳」的
/// 解析器可以拿滿分，但它會把店名、電話、總計全部倒進使用者的草稿清單。
void main() {
  /// 找到期望品項的比例。
  ///
  /// 實測歷程（2026-09-16）：
  /// - 初版：66.7%／50.0%
  /// - 修店名誤判與落單金額後，三張自造 fixture 都 100%
  /// - 補一張未為其設計的刁鑽版面：75%／75% → 修小數 round 與品名尾端數字後
  ///   93.75%／90.0%
  /// - **加入三張真實收據（麥當勞、台糖、電子發票明細）：崩到 39.3%／37.1%**
  ///   → 修稅別後綴、分隔符、`20*2`、欄位順序：96.4%／94.3%
  /// - **加入第四張真實收據（大買家收銀機發票）：那張 0%／0%**——條碼被當成
  ///   價格、金額在品名上一列、日期無分隔符、`標籤:值` 中繼資料滿版
  /// - 重寫為「token 分類 → 雙向配對 → 以像品項的列界定表頭表尾」：
  ///   **96.9%／95.0%**，四張真實收據全部 100%／100%
  ///
  /// 每一張真實收據都打破了一個自造 fixture 沒預料到的假設。這個基準的價值
  /// 不在數字，在於**每張新收據進來都能立刻知道哪裡壞了**。
  ///
  /// **這個數字仍然高估真實表現**：fixture 是照著照片抄下來的版面，不是 ML Kit
  /// 的實際輸出。真實辨識會有認錯的字（麥當勞那張「玉米濃湯-大」在照片裡
  /// 已經糊到只剩「玉米濃-大」），那一層的損失還沒被量到。
  ///
  /// 仍未處理：品名太長換行時會變成兩個品項（`adversarial-layouts` 的
  /// 「日式炸豬排便當 / (附味噌湯)」）。四張真實收據都沒有這個版面，先不做——
  /// 合併續行有把兩個真品項誤併的風險。
  const double recallThreshold = 0.90;

  /// 回傳的品項中真的是品項的比例。
  ///
  /// 抓的是「把店名、統編、總計當成食物倒進草稿」這類噪音。只量 recall 的話，
  /// 一個「什麼都回傳」的解析器可以拿滿分——大買家那張一度 recall 100%
  /// 但 precision 6%，整張表頭表尾全部被當成食物。
  const double precisionThreshold = 0.85;

  late List<_ReceiptFixture> fixtures;
  late ReceiptLayoutParser parser;

  setUpAll(() {
    fixtures = Directory('test/fixtures/receipts')
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.json'))
        .map((file) => _ReceiptFixture.fromJson(
              json.decode(file.readAsStringSync()) as Map<String, dynamic>,
              File(file.path).uri.pathSegments.last,
            ))
        .toList()
      ..sort((a, b) => a.file.compareTo(b.file));

    final noise = json.decode(
      File('assets/data/receipt_noise_terms.json').readAsStringSync(),
    ) as Map;
    parser = ReceiptLayoutParser(noiseTerms: [
      for (final group in noise.values) ...(group as List).cast<String>(),
    ]);
  });

  test('基準樣本涵蓋多種版面', () {
    // 只有一種版面的基準量不出韌性。
    expect(fixtures.length, greaterThanOrEqualTo(3));
    expect(
      fixtures.expand((f) => f.expected).length,
      greaterThanOrEqualTo(9),
    );
  });

  test('解析的 recall 與 precision 都不低於門檻', () {
    final report = StringBuffer();
    var totalRecall = 0.0;
    var totalPrecision = 0.0;

    for (final fixture in fixtures) {
      final actual = parser.parse(fixture.ocr);
      final matched = <ReceiptItem>[];
      final remaining = [...actual];

      for (final want in fixture.expected) {
        final hit = remaining.where((item) => want.matches(item)).firstOrNull;
        if (hit != null) {
          matched.add(hit);
          remaining.remove(hit);
        }
      }

      final recall = matched.length / fixture.expected.length;
      final precision = actual.isEmpty ? 0.0 : matched.length / actual.length;
      totalRecall += recall;
      totalPrecision += precision;

      report
        ..writeln('${fixture.file}  '
            'recall ${_pct(recall)}  precision ${_pct(precision)}')
        ..writeln('  期望 ${fixture.expected.length} 項，'
            '解析出 ${actual.length} 項，命中 ${matched.length} 項');
      for (final want in fixture.expected) {
        if (!matched.any(want.matches)) report.writeln('  未命中：$want');
      }
      for (final extra in remaining) {
        report.writeln('  多出來：${extra.rawName}');
      }
    }

    final recall = totalRecall / fixtures.length;
    final precision = totalPrecision / fixtures.length;

    // 不論通過與否都印出來——這份報告本身就是這個測試的產出。
    // ignore: avoid_print
    print('\n$report');

    expect(recall, greaterThanOrEqualTo(recallThreshold),
        reason: 'recall ${_pct(recall)} 低於門檻\n$report');
    expect(precision, greaterThanOrEqualTo(precisionThreshold),
        reason: 'precision ${_pct(precision)} 低於門檻\n$report');
  });

  test('每張收據都能擷取到標註的日期', () {
    for (final fixture in fixtures) {
      final date = ReceiptDateParser.parse(
        fixture.ocr.plainText,
        now: DateTime(2026, 9, 16),
      );
      expect(date, fixture.expectedDate, reason: '${fixture.file} 的日期擷取錯誤');
    }
  });
}

String _pct(double value) => '${(value * 100).toStringAsFixed(1)}%';

class _ReceiptFixture {
  const _ReceiptFixture({
    required this.file,
    required this.ocr,
    required this.expected,
    required this.expectedDate,
  });

  factory _ReceiptFixture.fromJson(Map<String, dynamic> data, String file) {
    final raw = (data['expectedDate'] as String).split('-');
    return _ReceiptFixture(
      file: file,
      ocr: OcrResult(
        elements: (data['elements'] as List)
            .cast<Map<String, dynamic>>()
            .map(OcrTextElement.fromJson)
            .toList(),
      ),
      expected: (data['expected'] as List)
          .cast<Map<String, dynamic>>()
          .map(_ExpectedItem.fromJson)
          .toList(),
      expectedDate: DateTime(
        int.parse(raw[0]),
        int.parse(raw[1]),
        int.parse(raw[2]),
      ),
    );
  }

  final String file;
  final OcrResult ocr;
  final List<_ExpectedItem> expected;
  final DateTime expectedDate;
}

/// 人工標註的一個品項。只比對有標註的欄位。
class _ExpectedItem {
  const _ExpectedItem({
    required this.rawName,
    this.quantity,
    this.unitPrice,
    this.amount,
    this.barcode,
  });

  factory _ExpectedItem.fromJson(Map<String, dynamic> data) => _ExpectedItem(
        rawName: data['rawName'] as String,
        quantity: (data['quantity'] as num?)?.toDouble(),
        unitPrice: data['unitPrice'] as int?,
        amount: data['amount'] as int?,
        barcode: data['barcode'] as String?,
      );

  final String rawName;
  final double? quantity;
  final int? unitPrice;
  final int? amount;
  final String? barcode;

  bool matches(ReceiptItem item) {
    if (item.rawName != rawName) return false;
    if (quantity != null && item.quantity != quantity) return false;
    if (unitPrice != null && item.unitPrice != unitPrice) return false;
    if (amount != null && item.amount != amount) return false;
    if (barcode != null && item.barcode != barcode) return false;
    return true;
  }

  @override
  String toString() => '$rawName(qty=$quantity, unit=$unitPrice, amount=$amount'
      '${barcode == null ? '' : ', barcode=$barcode'})';
}
