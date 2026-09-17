import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/domain/receipt/ocr_result.dart';
import 'package:food_savior/domain/receipt/receipt_item.dart';
import 'package:food_savior/domain/receipt/receipt_layout_parser.dart';

/// 版面解析的逐條行為（receipt-ocr-import 規格）。
///
/// 基準測試量的是整體正確率；這裡鎖的是每一條規則。
void main() {
  const noiseTerms = ['總計', '找零', '統一編號', '謝謝光臨'];
  final parser = ReceiptLayoutParser(noiseTerms: noiseTerms);

  /// 造一列。cells 是 (文字, left, right)；同一列共用 y 範圍。
  List<OcrTextElement> row(double top, List<(String, double, double)> cells) {
    return [
      for (final (text, left, right) in cells)
        OcrTextElement(
          text: text,
          bounds: TextBounds(
            left: left,
            top: top,
            right: right,
            bottom: top + 34,
          ),
        ),
    ];
  }

  List<ReceiptItem> parse(List<List<OcrTextElement>> rows) =>
      parser.parse(OcrResult(elements: rows.expand((r) => r).toList()));

  /// 大部分測試不關心表頭，用一列有價格的假表頭把表頭區用掉。
  List<OcrTextElement> header(double top) =>
      row(top, [('統一編號', 40, 180), ('12345678', 200, 340)]);

  group('數值尾段的四種解讀', () {
    test('三個數字是數量、單價、金額', () {
      final items = parse([
        header(0),
        row(100, [
          ('鮮奶', 40, 140),
          ('2', 420, 448),
          ('65', 500, 556),
          ('130', 620, 700)
        ]),
      ]);

      expect(
          items.single,
          const ReceiptItem(
              rawName: '鮮奶', quantity: 2, unitPrice: 65, amount: 130));
    });

    test('兩個數字是單價與金額，數量不猜', () {
      final items = parse([
        header(0),
        row(100, [('高麗菜', 40, 180), ('45', 500, 556), ('45', 620, 700)]),
      ]);

      expect(items.single.quantity, isNull);
      expect(items.single.unitPrice, 45);
      expect(items.single.amount, 45);
    });

    test('一個數字只有金額', () {
      final items = parse([
        header(0),
        row(100, [('香蕉', 40, 140), ('39', 620, 700)]),
      ]);

      expect(items.single.amount, 39);
      expect(items.single.quantity, isNull);
      expect(items.single.unitPrice, isNull);
    });

    test('沒有數字的列仍然成為品項', () {
      final items = parse([
        header(0),
        row(100, [('手工豆腐', 40, 200)]),
      ]);

      expect(items.single.rawName, '手工豆腐');
      expect(items.single.amount, isNull);
    });

    test('超過三個數字只取最右邊三個', () {
      final items = parse([
        header(0),
        row(100, [
          ('肉', 40, 100),
          ('9', 300, 330),
          ('2', 420, 448),
          ('65', 500, 556),
          ('130', 620, 700),
        ]),
      ]);

      expect(items.single.quantity, 2);
      expect(items.single.amount, 130);
    });
  });

  group('品名與數字的分界', () {
    test('品名含規格時規格不會被當成金額', () {
      final items = parse([
        header(0),
        row(100, [('統一AB優酪乳400ML', 40, 420), ('32', 620, 700)]),
      ]);

      expect(items.single.rawName, '統一AB優酪乳400ML');
      expect(items.single.amount, 32);
    });

    test('品名尾端獨立的數字黏在品名上，不算價格', () {
      // 「可樂 600」的 600 是容量；它與品名只隔一個字的距離。
      final items = parse([
        header(0),
        row(100, [('可樂', 40, 130), ('600', 150, 215), ('35', 630, 700)]),
      ]);

      expect(items.single.rawName, '可樂 600');
      expect(items.single.amount, 35);
      expect(items.single.unitPrice, isNull);
    });

    test('與品名有明顯間距的數字算價格', () {
      final items = parse([
        header(0),
        row(100, [
          ('蔬菜', 40, 130),
          ('0.35', 400, 470),
          ('120', 520, 580),
          ('42', 630, 700)
        ]),
      ]);

      expect(items.single.quantity, 0.35);
      expect(items.single.amount, 42);
    });

    test('秤重商品的小數數量不會被四捨五入成 0', () {
      final items = parse([
        header(0),
        row(100, [
          ('豬肉', 40, 130),
          ('0.4', 400, 460),
          ('300', 520, 590),
          ('120', 630, 700)
        ]),
      ]);

      expect(items.single.quantity, 0.4);
    });
  });

  group('分列依垂直重疊', () {
    test('垂直重疊的元素視為同一列，即使分屬不同區塊', () {
      final elements = [
        ...header(0),
        // 品名與金額中間隔著大片空白，辨識器常把它們分進不同 TextBlock。
        OcrTextElement(
          text: '雞蛋',
          bounds: const TextBounds(left: 40, top: 100, right: 140, bottom: 134),
        ),
        OcrTextElement(
          // 稍微錯開但仍重疊過半。
          text: '89',
          bounds:
              const TextBounds(left: 620, top: 106, right: 700, bottom: 140),
        ),
      ];

      final items = parser.parse(OcrResult(elements: elements));

      expect(items.single.rawName, '雞蛋');
      expect(items.single.amount, 89);
    });

    test('垂直不重疊的元素是不同列', () {
      final items = parse([
        header(0),
        row(100, [('雞蛋', 40, 140), ('89', 620, 700)]),
        row(200, [('牛奶', 40, 140), ('65', 620, 700)]),
      ]);

      expect(items.map((e) => e.rawName).toList(), ['雞蛋', '牛奶']);
    });

    test('元素順序不影響結果——只看座標', () {
      final rows = [
        header(0),
        row(200, [('牛奶', 40, 140), ('65', 620, 700)]),
        row(100, [('雞蛋', 40, 140), ('89', 620, 700)]),
      ];

      final shuffled = rows.expand((r) => r).toList().reversed.toList();
      final items = parser.parse(OcrResult(elements: shuffled));

      expect(items.map((e) => e.rawName).toList(), ['雞蛋', '牛奶']);
    });
  });

  group('落單的數字併回上一列', () {
    test('金額獨佔下一列時併回品名', () {
      final items = parse([
        header(0),
        row(100, [('有機高麗菜', 40, 260)]),
        row(140, [('55', 640, 700)]),
      ]);

      expect(items.single.rawName, '有機高麗菜');
      expect(items.single.amount, 55);
    });

    test('上一列已經有價格時不併', () {
      final items = parse([
        header(0),
        row(100, [('雞蛋', 40, 140), ('89', 620, 700)]),
        row(140, [('55', 640, 700)]),
      ]);

      expect(items.single.amount, 89);
    });
  });

  group('過濾非品項的列', () {
    test('排除結帳資訊', () {
      final items = parse([
        header(0),
        row(100, [('雞蛋', 40, 140), ('89', 620, 700)]),
        row(200, [('總計', 40, 140), ('214', 620, 700)]),
        row(240, [('找零', 40, 140), ('286', 620, 700)]),
      ]);

      expect(items.map((e) => e.rawName).toList(), ['雞蛋']);
    });

    test('排除表頭：第一個有價格的列之前都不是品項', () {
      final items = parse([
        row(0, [('全家便利商店', 40, 340)]),
        row(40, [('台北市信義路', 40, 300)]),
        row(100, [('雞蛋', 40, 140), ('89', 620, 700)]),
      ]);

      expect(items.map((e) => e.rawName).toList(), ['雞蛋']);
    });

    test('只剩數字與符號的品名被排除', () {
      final items = parse([
        header(0),
        row(100, [('2026/09/15', 40, 220), ('14:32', 250, 340)]),
        row(200, [('雞蛋', 40, 140), ('89', 620, 700)]),
      ]);

      expect(items.map((e) => e.rawName).toList(), ['雞蛋']);
    });

    test('整列只有數字時不會變成品項', () {
      final items = parse([
        header(0),
        row(100, [('雞蛋', 40, 140), ('89', 620, 700)]),
        row(300, [('999', 640, 700)]),
      ]);

      expect(items, hasLength(1));
    });
  });

  group('價格的裝飾', () {
    test('金額前的貨幣符號', () {
      final items = parse([
        header(0),
        row(100, [('優酪乳', 40, 180), ('\$32', 620, 700)]),
      ]);

      expect(items.single.amount, 32);
    });

    test('金額中的千分位逗號', () {
      final items = parse([
        header(0),
        row(100, [('牛排', 40, 160), ('1,320', 600, 700)]),
      ]);

      expect(items.single.amount, 1320);
    });
  });

  test('沒有任何元素時回傳空清單', () {
    expect(parser.parse(const OcrResult(elements: [])), isEmpty);
  });

  test('沒有雜訊詞表時仍可運作，只是不濾結帳資訊', () {
    final bare = ReceiptLayoutParser(noiseTerms: const []);
    final items = bare.parse(OcrResult(
      elements: [
        ...header(0),
        ...row(100, [('雞蛋', 40, 140), ('89', 620, 700)]),
      ],
    ));

    expect(items.map((e) => e.rawName), contains('雞蛋'));
  });

  // 以下規則都是四張真實收據逼出來的（麥當勞、台糖量販、電子發票明細、
  // 大買家收銀機發票），每一條都對應一個當初 0 分的失敗。

  group('稅別後綴與分隔符', () {
    test('黏在金額上的稅別後綴會被剝掉（麥當勞 52TX）', () {
      final items = parse([
        header(0),
        row(100, [
          ('玉米濃湯', 40, 200),
          ('52', 555, 605),
          ('1', 660, 690),
          ('52TX', 880, 1000)
        ]),
      ]);

      expect(items.single.amount, 52);
      expect(items.single.rawName, '玉米濃湯');
    });

    test('稅別後綴是獨立的一格、而且在最右邊時，掃描不會提前停下（電子發票明細）', () {
      final items = parse([
        header(0),
        row(100, [('香氛蠟燭', 40, 200), ('40', 560, 610), ('TX', 625, 675)]),
      ]);

      expect(items.single.amount, 40);
    });

    test('夾著 X 與 = 的數值列仍能解析（台糖）', () {
      final items = parse([
        header(0),
        row(100, [('雞腿排', 40, 200)]),
        row(146, [
          ('1', 60, 80),
          ('X', 130, 160),
          ('105', 230, 290),
          ('=', 350, 380),
          ('105TX', 560, 700)
        ]),
      ]);

      expect(
          items.single,
          const ReceiptItem(
              rawName: '雞腿排', quantity: 1, unitPrice: 105, amount: 105));
    });

    test('促銷代碼只在已抓到數字後才跳過（麥當勞的 1P）', () {
      final items = parse([
        header(0),
        row(100, [
          ('馬鈴薯餅', 40, 200),
          ('32', 555, 605),
          ('1', 660, 690),
          ('1P', 730, 790),
          ('0TX', 900, 1000)
        ]),
      ]);

      expect(items.single.rawName, '馬鈴薯餅');
      expect(items.single.quantity, 1);
      expect(items.single.unitPrice, 32);
      expect(items.single.amount, 0);
    });

    test('單價*數量擠在同一格會被拆開（電子發票明細）', () {
      final items = parse([
        header(0),
        row(100, [('香氛蠟燭S', 40, 200)]),
        row(150, [('20*2', 320, 420), ('40', 560, 610), ('TX', 625, 675)]),
      ]);

      expect(
          items.single,
          const ReceiptItem(
              rawName: '香氛蠟燭S', quantity: 2, unitPrice: 20, amount: 40));
    });

    test('規格裡的星號不會被當成單價乘數量', () {
      final items = parse([
        header(0),
        row(100, [('排骨雞麵 90g*5', 40, 300), ('65', 620, 700)]),
      ]);

      expect(items.single.rawName, '排骨雞麵 90g*5');
      expect(items.single.amount, 65);
    });
  });

  group('欄位順序各家不同：數量取較小者', () {
    test('單價在前（麥當勞）', () {
      final items = parse([
        header(0),
        row(100, [
          ('玉米濃湯', 40, 200),
          ('52', 555, 605),
          ('1', 660, 690),
          ('52', 880, 950)
        ]),
      ]);

      expect(items.single.quantity, 1);
      expect(items.single.unitPrice, 52);
    });

    test('數量在前（超商）', () {
      final items = parse([
        header(0),
        row(100, [
          ('鮮奶', 40, 140),
          ('2', 420, 448),
          ('65', 500, 556),
          ('130', 620, 700)
        ]),
      ]);

      expect(items.single.quantity, 2);
      expect(items.single.unitPrice, 65);
    });
  });

  group('識別碼與條碼（大買家）', () {
    test('八位以上的純數字不是價格，合法長度的記成條碼', () {
      final items = parse([
        header(0),
        row(100,
            [('雞蛋', 40, 140), ('4712345678901', 200, 500), ('89', 620, 700)]),
      ]);

      expect(items.single.rawName, '雞蛋');
      expect(items.single.amount, 89);
      expect(items.single.unitPrice, isNull);
      expect(items.single.barcode, '4712345678901');
    });

    test('不是條碼長度的識別碼只被丟掉，不進品名', () {
      final items = parse([
        header(0),
        row(100, [('雞蛋', 40, 140), ('1234567890', 200, 400), ('89', 620, 700)]),
      ]);

      expect(items.single.rawName, '雞蛋');
      expect(items.single.barcode, isNull);
    });

    test('條碼與金額在上一列、品名在下一列時往下配', () {
      final items = parse([
        header(0),
        row(100, [('4712123724362', 50, 380), ('\$200T', 500, 620)]),
        row(130, [('綠-檸檬汁2.5kg', 50, 360)]),
      ]);

      expect(items.single.rawName, '綠-檸檬汁2.5kg');
      expect(items.single.amount, 200);
      expect(items.single.barcode, '4712123724362');
    });

    test('落單的數字不會配到標籤:值的列上，會跳過它往下配', () {
      final items = parse([
        header(0),
        row(70,
            [('機:020102', 50, 260), ('@:170', 280, 400), ('頁:2', 420, 500)]),
        row(100, [('4712123724362', 50, 380), ('\$200T', 500, 620)]),
        row(130, [('綠-檸檬汁2.5kg', 50, 360)]),
      ]);

      expect(items.map((e) => e.rawName).toList(), ['綠-檸檬汁2.5kg']);
      expect(items.single.amount, 200);
    });
  });

  group('中繼資料與表尾', () {
    test('標籤:值 形式一律不是品項', () {
      final items = parse([
        header(0),
        row(100, [('雞蛋', 40, 140), ('89', 620, 700)]),
        row(140, [('店名:台北店', 50, 300), ('店號:0201', 320, 520)]),
        row(180, [('NO:80050683', 50, 320)]),
        row(220, [('TEL:02-8953-9111', 50, 400)]),
        row(260, [('交易後餘額', 160, 440), (':18元', 530, 660)]),
      ]);

      expect(items.map((e) => e.rawName).toList(), ['雞蛋']);
    });

    test('表頭區以第一個像品項的列為界，電話號碼裡的數字不算（麥當勞）', () {
      final items = parse([
        row(0, [('餐廳0046', 50, 300), ('新莊中正', 320, 560)]),
        row(40, [('餐廳電話:02-2276', 50, 590), ('8295', 610, 730)]),
        row(80,
            [('機046003', 50, 300), ('序484420', 320, 560), ('-27', 580, 680)]),
        row(120, [
          ('玉米濃湯', 55, 310),
          ('52', 555, 605),
          ('1', 660, 690),
          ('52TX', 880, 1000)
        ]),
      ]);

      expect(items.map((e) => e.rawName).toList(), ['玉米濃湯']);
    });

    test('最後一個品項之後沒有數字的列是表尾宣導（大買家）', () {
      final items = parse([
        header(0),
        row(100, [('綠-檸檬汁', 50, 360), ('200', 500, 620)]),
        row(160, [('使用牌照稅開徵', 80, 560)]),
        row(200, [('自4月1日起', 200, 420)]),
        row(240, [('至4月30日止', 190, 430)]),
      ]);

      expect(items.map((e) => e.rawName).toList(), ['綠-檸檬汁']);
    });

    test('表尾規則不會誤刪品項區內部的無價格列', () {
      final items = parse([
        header(0),
        row(100, [('高麗菜', 40, 260)]),
        row(140, [('55', 640, 700)]),
        row(200, [('雞蛋', 40, 260)]),
        row(240, [('89', 640, 700)]),
      ]);

      expect(items.map((e) => e.rawName).toList(), ['高麗菜', '雞蛋']);
    });

    test('中文之間的空格不影響雜訊比對（總 計:）', () {
      final items = parse([
        header(0),
        row(100, [('雞蛋', 40, 140), ('89', 620, 700)]),
        row(140, [('總 計:', 390, 590), ('89', 880, 950)]),
      ]);

      expect(items.map((e) => e.rawName).toList(), ['雞蛋']);
    });
  });
}
