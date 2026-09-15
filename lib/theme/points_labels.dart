import 'package:flutter/material.dart';
import 'package:food_savior/generated/l10n.dart';
import 'package:food_savior/models/food_points_summary.dart';

/// 等級與里程碑的顯示文字。放在 theme 層是因為它只是呈現，
/// 模型本身不認識 l10n（localization 規格）。
extension PointsLevelLabel on PointsLevel {
  String localizedName(BuildContext context) => switch (this) {
        PointsLevel.novice => S.of(context).levelNoviceName,
        PointsLevel.keeper => S.of(context).levelKeeperName,
        PointsLevel.saver => S.of(context).levelSaverName,
        PointsLevel.guardian => S.of(context).levelGuardianName,
        PointsLevel.master => S.of(context).levelMasterName,
      };
}

extension PointsMilestoneLabel on PointsMilestone {
  String localizedName(BuildContext context) => switch (this) {
        PointsMilestone.firstRecord => S.of(context).milestoneFirstRecordName,
        PointsMilestone.tenRescues => S.of(context).milestoneTenRescuesName,
        PointsMilestone.hundredPoints =>
          S.of(context).milestoneHundredPointsName,
        PointsMilestone.weekWithoutWaste =>
          S.of(context).milestoneWeekWithoutWasteName,
        PointsMilestone.monthWithoutWaste =>
          S.of(context).milestoneMonthWithoutWasteName,
        PointsMilestone.fiveHundredPoints =>
          S.of(context).milestoneFiveHundredPointsName,
      };

  /// 未達成時顯示的條件文字。看得到目標才有方向（design D4）。
  String localizedCondition(BuildContext context) => switch (this) {
        PointsMilestone.firstRecord =>
          S.of(context).milestoneFirstRecordCondition,
        PointsMilestone.tenRescues =>
          S.of(context).milestoneTenRescuesCondition,
        PointsMilestone.hundredPoints =>
          S.of(context).milestoneHundredPointsCondition,
        PointsMilestone.weekWithoutWaste =>
          S.of(context).milestoneWeekWithoutWasteCondition,
        PointsMilestone.monthWithoutWaste =>
          S.of(context).milestoneMonthWithoutWasteCondition,
        PointsMilestone.fiveHundredPoints =>
          S.of(context).milestoneFiveHundredPointsCondition,
      };

  IconData get icon => switch (this) {
        PointsMilestone.firstRecord => Icons.flag_outlined,
        PointsMilestone.tenRescues => Icons.volunteer_activism_outlined,
        PointsMilestone.hundredPoints => Icons.star_outline,
        PointsMilestone.weekWithoutWaste => Icons.event_available_outlined,
        PointsMilestone.monthWithoutWaste => Icons.calendar_month_outlined,
        PointsMilestone.fiveHundredPoints => Icons.military_tech_outlined,
      };
}
