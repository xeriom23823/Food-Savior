import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/models/food_points_summary.dart';

import '../helpers/hive_test_helper.dart';

void main() {
  // testNow 是 2026-09-15（週二），所以本週從 09-14（週一）起算。
  UsedFoodItem eaten({
    String id = 'e',
    int point = 2,
    DateTime? usedDate,
  }) =>
      makeUsed(
        id: id,
        disposalMethod: DisposalMethod.eaten,
        affectFoodPoint: point,
        usedDate: usedDate ?? testNow,
      );

  UsedFoodItem wasted({
    String id = 'w',
    int point = -2,
    DateTime? usedDate,
  }) =>
      makeUsed(
        id: id,
        disposalMethod: DisposalMethod.discarded,
        affectFoodPoint: point,
        usedDate: usedDate ?? testNow,
      );

  FoodPointsSummary summarize(List<UsedFoodItem> items) =>
      FoodPointsSummary.from(items, now: testNow);

  group('累計總分', () {
    test('是全部紀錄的總和', () {
      final summary = summarize([
        eaten(id: 'a', point: 3),
        eaten(id: 'b', point: 2),
        wasted(id: 'c', point: -2),
      ]);

      expect(summary.totalPoints, 3);
      expect(summary.hasRecords, isTrue);
    });

    test('可以是負的，照實顯示', () {
      final summary = summarize([
        wasted(id: 'a', point: -3),
        wasted(id: 'b', point: -3),
      ]);

      expect(summary.totalPoints, -6);
    });

    test('完全沒有紀錄時回傳 empty', () {
      final summary = summarize(const []);

      expect(summary, FoodPointsSummary.empty);
      expect(summary.hasRecords, isFalse);
      expect(summary.daysSinceLastWaste, isNull);
    });
  });

  group('本週淨分', () {
    test('以週一為界，上週日不計入', () {
      final summary = summarize([
        eaten(id: 'mon', point: 2, usedDate: daysFromNow(-1)), // 09-14 週一
        eaten(id: 'sun', point: 5, usedDate: daysFromNow(-2)), // 09-13 週日
      ]);

      expect(summary.weeklyNet, 2);
      expect(summary.totalPoints, 7);
    });

    test('本週的浪費會扣掉', () {
      final summary = summarize([
        eaten(id: 'a', point: 3),
        wasted(id: 'b', point: -3),
      ]);

      expect(summary.weeklyNet, 0);
    });

    test('週一當天的紀錄算本週', () {
      expect(
        FoodPointsSummary.startOfWeek(testNow),
        DateTime(2026, 9, 14),
      );
    });
  });

  group('等級', () {
    test('門檻邊界', () {
      expect(PointsLevel.forPoints(0), PointsLevel.novice);
      expect(PointsLevel.forPoints(49), PointsLevel.novice);
      expect(PointsLevel.forPoints(50), PointsLevel.keeper);
      expect(PointsLevel.forPoints(149), PointsLevel.keeper);
      expect(PointsLevel.forPoints(150), PointsLevel.saver);
      expect(PointsLevel.forPoints(350), PointsLevel.guardian);
      expect(PointsLevel.forPoints(700), PointsLevel.master);
      expect(PointsLevel.forPoints(9999), PointsLevel.master);
    });

    test('總分為負時仍是第一級，不降級也不空白', () {
      final summary = summarize([wasted(id: 'a', point: -3)]);

      expect(summary.level, PointsLevel.novice);
      expect(summary.pointsToNextLevel, 50);
    });

    test('剛好達到門檻時進度歸零並顯示距下一級的差距', () {
      final summary = summarize([eaten(id: 'a', point: 50)]);

      expect(summary.level, PointsLevel.keeper);
      expect(summary.pointsToNextLevel, 100);
      expect(summary.levelProgress, 0);
    });

    test('等級內的進度是比例', () {
      final summary = summarize([eaten(id: 'a', point: 100)]);

      expect(summary.level, PointsLevel.keeper);
      expect(summary.levelProgress, closeTo(0.5, 0.0001));
    });

    test('已達最高級時沒有下一級進度', () {
      final summary = summarize([eaten(id: 'a', point: 800)]);

      expect(summary.level, PointsLevel.master);
      expect(summary.pointsToNextLevel, isNull);
      expect(summary.levelProgress, 1);
    });
  });

  group('距離上次浪費的天數', () {
    test('以最後一筆浪費紀錄計算', () {
      final summary = summarize([
        wasted(id: 'old', usedDate: daysFromNow(-10)),
        wasted(id: 'recent', usedDate: daysFromNow(-3)),
        eaten(id: 'today'),
      ]);

      expect(summary.daysSinceLastWaste, 3);
    });

    test('中間沒開 App 的日子不會中斷', () {
      final summary = summarize([
        wasted(id: 'w', usedDate: daysFromNow(-10)),
        eaten(id: 'e', usedDate: testNow),
      ]);

      expect(summary.daysSinceLastWaste, 10);
    });

    test('從來沒浪費過時從第一筆紀錄算起', () {
      final summary = summarize([
        eaten(id: 'a', usedDate: daysFromNow(-8)),
        eaten(id: 'b', usedDate: daysFromNow(-1)),
      ]);

      expect(summary.daysSinceLastWaste, 8);
    });

    test('今天剛浪費過就是 0', () {
      final summary = summarize([wasted(id: 'a')]);

      expect(summary.daysSinceLastWaste, 0);
    });

    test('堆肥也算浪費', () {
      final summary = summarize([
        makeUsed(
          id: 'c',
          disposalMethod: DisposalMethod.composted,
          affectFoodPoint: -1,
          usedDate: daysFromNow(-2),
        ),
        eaten(id: 'e', usedDate: daysFromNow(-9)),
      ]);

      expect(summary.daysSinceLastWaste, 2);
    });

    test('送人不算浪費', () {
      final summary = summarize([
        makeUsed(
          id: 'g',
          disposalMethod: DisposalMethod.givenAway,
          affectFoodPoint: 2,
          usedDate: daysFromNow(-1),
        ),
        eaten(id: 'e', usedDate: daysFromNow(-6)),
      ]);

      expect(summary.daysSinceLastWaste, 6);
    });
  });

  group('里程碑', () {
    test('有任何紀錄就達成第一筆', () {
      expect(
        summarize([eaten(id: 'a')]).isAchieved(PointsMilestone.firstRecord),
        isTrue,
      );
    });

    test('救回十項需要 10 筆 +3 的紀錄', () {
      final nine = List.generate(9, (i) => eaten(id: 'r$i', point: 3));
      expect(
        summarize(nine).isAchieved(PointsMilestone.tenRescues),
        isFalse,
      );

      final ten = [...nine, eaten(id: 'r9', point: 3)];
      expect(
        summarize(ten).isAchieved(PointsMilestone.tenRescues),
        isTrue,
      );
    });

    test('累計點數的兩個里程碑', () {
      expect(
        summarize([eaten(id: 'a', point: 99)])
            .isAchieved(PointsMilestone.hundredPoints),
        isFalse,
      );
      expect(
        summarize([eaten(id: 'a', point: 100)])
            .isAchieved(PointsMilestone.hundredPoints),
        isTrue,
      );
      expect(
        summarize([eaten(id: 'a', point: 500)])
            .isAchieved(PointsMilestone.fiveHundredPoints),
        isTrue,
      );
    });

    test('連續沒浪費的兩個里程碑', () {
      final sixDays = summarize([wasted(id: 'w', usedDate: daysFromNow(-6))]);
      expect(sixDays.isAchieved(PointsMilestone.weekWithoutWaste), isFalse);

      final sevenDays = summarize([wasted(id: 'w', usedDate: daysFromNow(-7))]);
      expect(sevenDays.isAchieved(PointsMilestone.weekWithoutWaste), isTrue);
      expect(sevenDays.isAchieved(PointsMilestone.monthWithoutWaste), isFalse);

      final month = summarize([wasted(id: 'w', usedDate: daysFromNow(-30))]);
      expect(month.isAchieved(PointsMilestone.monthWithoutWaste), isTrue);
    });

    test('刪掉紀錄後里程碑會退回', () {
      final before = summarize([eaten(id: 'a', point: 120)]);
      expect(before.isAchieved(PointsMilestone.hundredPoints), isTrue);

      final after = summarize([eaten(id: 'a', point: 80)]);
      expect(after.isAchieved(PointsMilestone.hundredPoints), isFalse);
    });
  });
}
