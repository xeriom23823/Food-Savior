import 'package:equatable/equatable.dart';
import 'package:food_savior/models/food_item.dart';

/// 等級。門檻集中在這裡，之後要調整只改這一處（design D3）。
enum PointsLevel {
  novice(0),
  keeper(50),
  saver(150),
  guardian(350),
  master(700);

  const PointsLevel(this.threshold);

  /// 進入這個等級所需的累計點數。
  final int threshold;

  PointsLevel? get next {
    final index = PointsLevel.values.indexOf(this);
    return index == PointsLevel.values.length - 1
        ? null
        : PointsLevel.values[index + 1];
  }

  static PointsLevel forPoints(int totalPoints) {
    // 總分為負時仍是第一級：降級只會讓人不想再打開這一頁。
    final points = totalPoints < 0 ? 0 : totalPoints;
    var level = PointsLevel.novice;
    for (final candidate in PointsLevel.values) {
      if (points >= candidate.threshold) level = candidate;
    }
    return level;
  }
}

/// 一次性里程碑。未達成的也要看得見（design D4）。
enum PointsMilestone {
  firstRecord,
  tenRescues,
  hundredPoints,
  weekWithoutWaste,
  monthWithoutWaste,
  fiveHundredPoints,
}

/// 用戶頁的「成績」。全部由既有紀錄推導，不持久化（design D1）。
class FoodPointsSummary extends Equatable {
  const FoodPointsSummary({
    required this.totalPoints,
    required this.weeklyNet,
    required this.level,
    required this.levelProgress,
    required this.achieved,
    this.pointsToNextLevel,
    this.daysSinceLastWaste,
    this.hasRecords = false,
  });

  static const FoodPointsSummary empty = FoodPointsSummary(
    totalPoints: 0,
    weeklyNet: 0,
    level: PointsLevel.novice,
    levelProgress: 0,
    achieved: <PointsMilestone>{},
  );

  /// 全部紀錄的點數總和。可以是負的，照實顯示。
  final int totalPoints;

  /// 本週（當地時間週一 00:00 起）的淨分。
  final int weeklyNet;

  final PointsLevel level;

  /// 目前等級內的進度（0〜1）。已達最高級時為 1。
  final double levelProgress;

  /// 距離下一級還差幾點。已達最高級時為 null。
  final int? pointsToNextLevel;

  /// 距離上次浪費的天數。完全沒有紀錄時為 null（design D2）。
  final int? daysSinceLastWaste;

  final Set<PointsMilestone> achieved;

  final bool hasRecords;

  bool isAchieved(PointsMilestone milestone) => achieved.contains(milestone);

  /// 需要 +3 的紀錄達這麼多筆才算「救回即期食物」的里程碑。
  static const int rescueMilestoneCount = 10;

  factory FoodPointsSummary.from(
    Iterable<UsedFoodItem> items, {
    required DateTime now,
  }) {
    final records = items.toList();
    if (records.isEmpty) return FoodPointsSummary.empty;

    final weekStart = startOfWeek(now);
    var total = 0;
    var weekly = 0;
    var rescues = 0;
    DateTime? lastWaste;
    DateTime? earliest;

    for (final record in records) {
      total += record.affectFoodPoint;
      if (!record.usedDate.isBefore(weekStart)) {
        weekly += record.affectFoodPoint;
      }
      if (record.affectFoodPoint == 3) rescues++;
      if (record.isWaste &&
          (lastWaste == null || record.usedDate.isAfter(lastWaste))) {
        lastWaste = record.usedDate;
      }
      if (earliest == null || record.usedDate.isBefore(earliest)) {
        earliest = record.usedDate;
      }
    }

    // 從來沒浪費過時從第一筆紀錄算起，這樣新使用者不會看到一個假的大數字。
    final since = lastWaste ?? earliest;
    final days = since == null ? null : _wholeDaysBetween(since, now);

    final level = PointsLevel.forPoints(total);
    final next = level.next;
    final clamped = total < 0 ? 0 : total;

    return FoodPointsSummary(
      totalPoints: total,
      weeklyNet: weekly,
      level: level,
      levelProgress: next == null
          ? 1
          : ((clamped - level.threshold) / (next.threshold - level.threshold))
              .clamp(0.0, 1.0),
      pointsToNextLevel: next == null ? null : next.threshold - clamped,
      daysSinceLastWaste: days,
      hasRecords: true,
      achieved: _milestonesFor(
        totalPoints: total,
        rescues: rescues,
        daysSinceLastWaste: days,
      ),
    );
  }

  static Set<PointsMilestone> _milestonesFor({
    required int totalPoints,
    required int rescues,
    required int? daysSinceLastWaste,
  }) {
    final days = daysSinceLastWaste ?? 0;
    return {
      PointsMilestone.firstRecord,
      if (rescues >= rescueMilestoneCount) PointsMilestone.tenRescues,
      if (totalPoints >= 100) PointsMilestone.hundredPoints,
      if (totalPoints >= 500) PointsMilestone.fiveHundredPoints,
      if (days >= 7) PointsMilestone.weekWithoutWaste,
      if (days >= 30) PointsMilestone.monthWithoutWaste,
    };
  }

  /// 本週的起點：當地時間的週一 00:00。
  static DateTime startOfWeek(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    return today.subtract(Duration(days: today.weekday - DateTime.monday));
  }

  static int _wholeDaysBetween(DateTime from, DateTime to) {
    final fromDay = DateTime(from.year, from.month, from.day);
    final toDay = DateTime(to.year, to.month, to.day);
    final days = toDay.difference(fromDay).inDays;
    return days < 0 ? 0 : days;
  }

  @override
  List<Object?> get props => [
        totalPoints,
        weeklyNet,
        level,
        levelProgress,
        pointsToNextLevel,
        daysSinceLastWaste,
        achieved,
        hasRecords,
      ];
}
