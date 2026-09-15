import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/models/expiry_quick_pick.dart';
import 'package:food_savior/models/food_item.dart';

void main() {
  final now = DateTime(2026, 9, 15, 14, 30);

  group('各選項的日期', () {
    test('今天就是今天，不是 24 小時後', () {
      expect(ExpiryQuickPick.today.dateFrom(now), DateTime(2026, 9, 15));
    });

    test('明天', () {
      expect(ExpiryQuickPick.tomorrow.dateFrom(now), DateTime(2026, 9, 16));
    });

    test('3 天後', () {
      expect(ExpiryQuickPick.threeDays.dateFrom(now), DateTime(2026, 9, 18));
    });

    test('1 週後', () {
      expect(ExpiryQuickPick.oneWeek.dateFrom(now), DateTime(2026, 9, 22));
    });

    test('2 週後', () {
      expect(ExpiryQuickPick.twoWeeks.dateFrom(now), DateTime(2026, 9, 29));
    });

    test('1 個月後', () {
      expect(ExpiryQuickPick.oneMonth.dateFrom(now), DateTime(2026, 10, 15));
    });
  });

  group('一律對齊當天零時', () {
    test('時分秒不影響結果', () {
      for (final pick in ExpiryQuickPick.values) {
        final fromNoon = pick.dateFrom(DateTime(2026, 9, 15, 12));
        final fromMidnight = pick.dateFrom(DateTime(2026, 9, 15));
        final fromLateNight = pick.dateFrom(DateTime(2026, 9, 15, 23, 59, 59));

        expect(fromNoon, fromMidnight, reason: '$pick 受時分影響');
        expect(fromLateNight, fromMidnight, reason: '$pick 受深夜時間影響');
      }
    });

    test('每個選項算出來的都是零時', () {
      for (final pick in ExpiryQuickPick.values) {
        final date = pick.dateFrom(now);
        expect(date.hour, 0, reason: '$pick 不是零時');
        expect(date.minute, 0);
        expect(date.second, 0);
      }
    });
  });

  group('邊界', () {
    test('跨月', () {
      final endOfMonth = DateTime(2026, 9, 29);

      expect(ExpiryQuickPick.threeDays.dateFrom(endOfMonth),
          DateTime(2026, 10, 2));
    });

    test('跨年', () {
      final endOfYear = DateTime(2026, 12, 28);

      expect(ExpiryQuickPick.oneWeek.dateFrom(endOfYear), DateTime(2027, 1, 4));
      expect(
          ExpiryQuickPick.oneMonth.dateFrom(endOfYear), DateTime(2027, 1, 28));
    });

    test('閏年的二月', () {
      // 2028 是閏年。
      expect(ExpiryQuickPick.tomorrow.dateFrom(DateTime(2028, 2, 28)),
          DateTime(2028, 2, 29));
    });

    test('月底加一個月會溢位到下個月初，仍是合理的近似', () {
      // 1/31 + 1 個月沒有對應的日期，DateTime 會往後捲。
      final result = ExpiryQuickPick.oneMonth.dateFrom(DateTime(2026, 1, 31));

      expect(result.month, 3);
      expect(result.day, lessThanOrEqualTo(3));
    });
  });

  group('expiryFrom', () {
    test('回傳精確到日的 ExpiryValue', () {
      final value = ExpiryQuickPick.today.expiryFrom(now);

      expect(value.precision, ExpiryPrecision.exact);
      expect(value.earliest, DateTime(2026, 9, 15));
      expect(value.latest, DateTime(2026, 9, 15));
    });
  });

  group('matching', () {
    test('日期正好落在某個選項上時回傳該選項', () {
      expect(ExpiryQuickPick.matching(DateTime(2026, 9, 15), now),
          ExpiryQuickPick.today);
      expect(ExpiryQuickPick.matching(DateTime(2026, 9, 16), now),
          ExpiryQuickPick.tomorrow);
      expect(ExpiryQuickPick.matching(DateTime(2026, 10, 15), now),
          ExpiryQuickPick.oneMonth);
    });

    test('帶時分的日期也能命中', () {
      expect(ExpiryQuickPick.matching(DateTime(2026, 9, 22, 18, 5), now),
          ExpiryQuickPick.oneWeek);
    });

    test('不落在任何選項上時回傳 null', () {
      expect(ExpiryQuickPick.matching(DateTime(2026, 9, 17), now), isNull);
      expect(ExpiryQuickPick.matching(DateTime(2026, 11, 3), now), isNull);
    });

    test('過去的日期不命中任何選項', () {
      expect(ExpiryQuickPick.matching(DateTime(2026, 9, 14), now), isNull);
    });

    test('null 回傳 null', () {
      expect(ExpiryQuickPick.matching(null, now), isNull);
    });
  });

  test('六個選項，順序由近到遠', () {
    final days = ExpiryQuickPick.values
        .map((pick) =>
            pick.dateFrom(now).difference(DateTime(2026, 9, 15)).inDays)
        .toList();

    expect(ExpiryQuickPick.values, hasLength(6));
    expect(days, [0, 1, 3, 7, 14, 30]);
  });
}
