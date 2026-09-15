import 'package:food_savior/models/expiry.dart';

/// 期限的快速選項（design D2）。
///
/// 存在的理由：要設一個期限，原本一律得開完整的日期選擇器、翻月份、點日期、確認
/// ——為了「今天」按四下。而這六個涵蓋絕大多數情況。
///
/// **「今天」是刻意放進去的**：即期品與今天就要吃掉的東西是真實且常見的情況，
/// 而它在只有日期選擇器時最難選（使用者正是為此回報）。
///
/// 純 Dart：沒有 Flutter 相依，日期邏輯可以直接單元測試。
enum ExpiryQuickPick {
  today(days: 0),
  tomorrow(days: 1),
  threeDays(days: 3),
  oneWeek(days: 7),
  twoWeeks(days: 14),
  oneMonth(months: 1);

  const ExpiryQuickPick({this.days = 0, this.months = 0});

  final int days;
  final int months;

  /// 這個選項相對於 [now] 對應的日期，一律對齊當天零時。
  ///
  /// 對齊是必要的：選中狀態以日期相等判定，「今天 14:30」與「今天 00:00」
  /// 比不相等的話，選項就永遠不會亮（design D3）。
  DateTime dateFrom(DateTime now) {
    // 先取當天零時再加，避免夏令時間或月底加月時被時分秒帶偏。
    final base = DateTime(now.year, now.month, now.day);
    if (months == 0) return base.add(Duration(days: days));
    // DateTime 會把 1/31 + 1 個月處理成 3/2 或 3/3（視閏年）。
    // 這是「一個月後」的合理近似，而且與使用者的直覺（下個月的同一天）
    // 只在月底差一兩天，不值得為此自己算月曆。
    return DateTime(base.year, base.month + months, base.day);
  }

  /// 這個選項對應的 [ExpiryValue]。
  ExpiryValue expiryFrom(DateTime now) => ExpiryValue.exact(dateFrom(now));

  /// [date] 是否正好落在這個選項上。
  bool matches(DateTime date, DateTime now) =>
      ExpiryValue.dateOnly(date) == dateFrom(now);

  /// [date] 命中哪一個選項；都不命中回傳 null。
  ///
  /// 順序上先命中的優先——選項的天數各不相同，實務上不會有兩個同時命中。
  static ExpiryQuickPick? matching(DateTime? date, DateTime now) {
    if (date == null) return null;
    for (final pick in values) {
      if (pick.matches(date, now)) return pick;
    }
    return null;
  }
}
