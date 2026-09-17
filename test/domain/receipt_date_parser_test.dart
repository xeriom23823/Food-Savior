import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/domain/receipt/receipt_date_parser.dart';

void main() {
  final now = DateTime(2026, 9, 16, 14, 30);
  final today = DateTime(2026, 9, 16);

  group('西元日期', () {
    test('斜線', () {
      expect(ReceiptDateParser.parse('2026/09/15', now: now),
          DateTime(2026, 9, 15));
    });

    test('連字號', () {
      expect(ReceiptDateParser.parse('2026-09-13', now: now),
          DateTime(2026, 9, 13));
    });

    test('點', () {
      expect(ReceiptDateParser.parse('2026.09.10', now: now),
          DateTime(2026, 9, 10));
    });

    test('中文年月日', () {
      expect(
          ReceiptDateParser.parse('2026年9月8日', now: now), DateTime(2026, 9, 8));
    });

    test('單位數月日', () {
      expect(
          ReceiptDateParser.parse('2026/9/5', now: now), DateTime(2026, 9, 5));
    });
  });

  group('民國日期', () {
    test('三位數民國年', () {
      expect(ReceiptDateParser.parse('115/09/14', now: now),
          DateTime(2026, 9, 14));
    });

    test('兩位數民國年（舊單據）', () {
      expect(ReceiptDateParser.parse('99/12/31', now: now),
          DateTime(2010, 12, 31));
    });
  });

  group('夾在整段文字裡', () {
    test('日期前後有其他文字也找得到', () {
      const text = '全家便利商店\n統一編號 12345678\n交易時間 2026/09/15 14:32\n鮮奶 65';

      expect(ReceiptDateParser.parse(text, now: now), DateTime(2026, 9, 15));
    });

    test('取第一個合法且不在未來的日期', () {
      const text = '2026/09/15\n2026/09/10';

      expect(ReceiptDateParser.parse(text, now: now), DateTime(2026, 9, 15));
    });
  });

  group('退回今天的情形', () {
    test('完全沒有日期', () {
      expect(ReceiptDateParser.parse('鮮奶 65\n雞蛋 89', now: now), today);
    });

    test('空字串', () {
      expect(ReceiptDateParser.parse('', now: now), today);
    });

    test('月份不合法', () {
      expect(ReceiptDateParser.parse('2026/13/01', now: now), today);
    });

    test('日期不存在（2 月 31 日）', () {
      expect(ReceiptDateParser.parse('2026/02/31', now: now), today);
    });

    test('未來日期視為辨識錯誤', () {
      // `8` 被讀成 `9` 之類，不該讓它變成存放日期。
      expect(ReceiptDateParser.parse('2027/01/01', now: now), today);
    });

    test('未來日期之後若有合法日期就用後者', () {
      expect(ReceiptDateParser.parse('2027/01/01 2026/09/12', now: now),
          DateTime(2026, 9, 12));
    });
  });

  test('回傳的一律是當日零時', () {
    final date = ReceiptDateParser.parse('2026/09/15', now: now);

    expect(date.hour, 0);
    expect(date.minute, 0);
    expect(date.second, 0);
  });

  test('今天的判定用裝置當地日期，不受時分影響', () {
    expect(ReceiptDateParser.parse('沒有日期', now: DateTime(2026, 9, 16, 23, 59)),
        today);
    expect(ReceiptDateParser.parse('沒有日期', now: DateTime(2026, 9, 16)), today);
  });

  group('真實收據逼出來的格式（大買家收銀機發票）', () {
    test('無分隔符的 YYYYMMDD', () {
      expect(ReceiptDateParser.parse('20120323 16:29 INV:2813', now: now),
          DateTime(2012, 3, 23));
    });

    test('無分隔符的日期前後不能再接數字，否則條碼裡的 8 碼會被抓出來', () {
      // 4712123724362 裡面有 20121237、12123724 之類的片段，都不是日期。
      expect(ReceiptDateParser.parse('4712123724362', now: now), today);
    });

    test('無分隔符但月日不合法的八位數不是日期', () {
      // 12252813 → 1225-28-13、80050683 → 8005-06-83。
      expect(ReceiptDateParser.parse('AR 12252813', now: now), today);
      expect(ReceiptDateParser.parse('NO:80050683', now: now), today);
    });

    test('「101年3-4月份」是發票期別，不是日期', () {
      // 這一行在收據最上面，會比真正的交易日期先被掃到。
      expect(
        ReceiptDateParser.parse('中華民國101年3-4月份\n20120323 16:29', now: now),
        DateTime(2012, 3, 23),
      );
    });

    test('只有期別、沒有真正日期時退回今天', () {
      expect(ReceiptDateParser.parse('中華民國101年3-4月份', now: now), today);
    });

    test('電話與客服專線不會被當成日期', () {
      expect(ReceiptDateParser.parse('TEL:02-8953-9111', now: now), today);
      expect(ReceiptDateParser.parse('專線:0800-000-321', now: now), today);
    });

    test('繳納期限的「自4月1日起」不會被當成日期', () {
      expect(ReceiptDateParser.parse('自4月1日起 至4月30日止', now: now), today);
    });

    test('兩種格式並存時依出現位置取第一個合法的', () {
      expect(
        ReceiptDateParser.parse('2014-03-22 13:03:02 之後 20120323', now: now),
        DateTime(2014, 3, 22),
      );
    });
  });
}
