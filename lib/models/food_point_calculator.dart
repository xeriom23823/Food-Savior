import 'package:food_savior/models/food_item.dart';

/// 食物點數的唯一計算入口（food-points 規格、design D19）。
///
/// 所有寫入路徑（滑動操作、部分處理、過期處理）都必須走這裡，
/// 才不會出現「同一個行為在不同頁面得到不同分數」。
class FoodPointCalculator {
  const FoodPointCalculator({this.dailyPositiveCap = 10});

  /// 每日加分上限。以「當日正分總和」計算，負分不計入
  /// （舊規則把負分也算進總和，等於多浪費就能多得分）。
  final int dailyPositiveCap;

  /// 救援窗口：到期前這麼多天內（含當日）用完視為即期救援。
  static const int rescueWindowDays = 3;

  /// 未套用每日上限的基本分。
  int basePointFor({
    required DisposalMethod disposalMethod,
    required DateTime? effectiveExpiry,
    required DateTime usedDate,
  }) {
    final expiry = effectiveExpiry;
    final isExpired = expiry != null && isExpiredOn(expiry, usedDate);

    switch (disposalMethod) {
      case DisposalMethod.eaten:
      case DisposalMethod.givenAway:
        if (expiry == null) return 2;
        if (isExpired) return 1;
        return daysUntilExpiry(expiry, usedDate) <= rescueWindowDays ? 3 : 2;
      case DisposalMethod.eatenAtRisk:
        return 1;
      case DisposalMethod.composted:
        return isExpired ? -1 : -2;
      case DisposalMethod.discarded:
        return isExpired ? -2 : -3;
    }
  }

  /// 套用每日上限後的實際點數。[existing] 是這一筆寫入前已存在的紀錄。
  int pointFor(UsedFoodItem item, Iterable<UsedFoodItem> existing) {
    final base = basePointFor(
      disposalMethod: item.disposalMethod,
      effectiveExpiry: item.effectiveExpiry,
      usedDate: item.usedDate,
    );
    if (base <= 0) return base;

    final earned = positiveTotalOn(item.usedDate, existing);
    final remaining = dailyPositiveCap - earned;
    if (remaining <= 0) return 0;
    return base > remaining ? remaining : base;
  }

  /// 某日曆日已累積的正分總和。
  int positiveTotalOn(DateTime day, Iterable<UsedFoodItem> items) {
    return items
        .where((item) => isSameDay(item.usedDate, day))
        .where((item) => item.affectFoodPoint > 0)
        .fold<int>(0, (sum, item) => sum + item.affectFoodPoint);
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
