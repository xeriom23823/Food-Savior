import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/models/food_preset.dart';
import 'package:food_savior/models/food_suggestion.dart';
import 'package:food_savior/models/storage_location.dart';

import '../helpers/hive_test_helper.dart';

void main() {
  const milk = FoodPreset(
    keywords: ['牛奶', 'milk'],
    type: FoodItemType.eggAndMilk,
    days: {
      LocationKind.refrigerated: 7,
      LocationKind.frozen: 30,
      LocationKind.ambient: 1,
    },
    afterOpenDays: 3,
  );
  const milkCandy = FoodPreset(
    keywords: ['牛奶糖'],
    type: FoodItemType.snack,
    days: {LocationKind.ambient: 180},
  );

  group('關鍵字比對', () {
    const engine = FoodSuggestionEngine(presets: [milk, milkCandy]);

    test('最長命中優先：牛奶糖不會被當成牛奶', () {
      expect(engine.presetFor('牛奶糖')?.type, FoodItemType.snack);
      expect(engine.presetFor('低脂牛奶')?.type, FoodItemType.eggAndMilk);
    });

    test('大小寫與空白不影響比對', () {
      expect(engine.presetFor('  MILK ')?.type, FoodItemType.eggAndMilk);
    });

    test('沒命中回傳 null', () {
      expect(engine.presetFor('阿嬤給的東西'), isNull);
    });
  });

  group('建議順序：模板 → 對照表 → 未知', () {
    test('命中使用者歷史時帶入類型與天數差', () {
      final history = FoodSuggestionEngine.templatesFromHistory(
        foodItems: [
          makeFood(
            id: 'old',
            name: '牛奶',
            type: FoodItemType.eggAndMilk,
            storageDate: daysFromNow(-7),
            daysToExpire: 0,
            unit: Unit.bottle,
          ),
        ],
        usedFoodItems: const [],
      );
      final engine =
          FoodSuggestionEngine(templates: history, presets: const []);

      final suggestion = engine.suggest(name: '牛奶', now: testNow);

      expect(suggestion.source, SuggestionSource.template);
      expect(suggestion.type, FoodItemType.eggAndMilk);
      expect(suggestion.unit, Unit.bottle);
      expect(suggestion.expiry.earliest, daysFromNow(7));
    });

    test('沒有歷史時用內建對照表，依存放方式取天數', () {
      const engine = FoodSuggestionEngine(presets: [milk]);

      final refrigerated = engine.suggest(
        name: '牛奶',
        now: testNow,
        locationKind: LocationKind.refrigerated,
      );
      final frozen = engine.suggest(
        name: '牛奶',
        now: testNow,
        locationKind: LocationKind.frozen,
      );

      expect(refrigerated.source, SuggestionSource.preset);
      expect(refrigerated.expiry.earliest, daysFromNow(7));
      expect(frozen.expiry.earliest, daysFromNow(30));
      expect(refrigerated.shelfLifeAfterOpenDays, 3);
    });

    test('都沒命中就是期限未知，且不阻擋建立', () {
      const engine = FoodSuggestionEngine();

      final suggestion = engine.suggest(name: '阿嬤給的東西', now: testNow);

      expect(suggestion.source, SuggestionSource.none);
      expect(suggestion.type, FoodItemType.others);
      expect(suggestion.expiry.isKnown, isFalse);
      expect(suggestion.amount, 1);
    });
  });

  group('常用模板', () {
    test('出現次數多的排前面，同次數則最近用過的在前', () {
      final templates = FoodSuggestionEngine.templatesFromHistory(
        foodItems: [
          makeFood(id: '1', name: '雞蛋'),
          makeFood(id: '2', name: '雞蛋'),
          makeFood(id: '3', name: '牛奶', storageDate: daysFromNow(-1)),
          makeFood(id: '4', name: '蘋果', storageDate: daysFromNow(-10)),
        ],
        usedFoodItems: const [],
      );

      expect(templates.first.name, '雞蛋');
      expect(templates.first.usageCount, 2);
      expect(templates[1].name, '牛奶');
    });

    test('使用紀錄也算進歷史', () {
      final templates = FoodSuggestionEngine.templatesFromHistory(
        foodItems: const [],
        usedFoodItems: [makeUsed(id: 'u1', name: '青椒')],
      );

      expect(templates.single.name, '青椒');
    });
  });

  group('命中選擇規則（design D4）', () {
    const gourd = FoodPreset(
      keywords: ['冬瓜'],
      type: FoodItemType.vegetable,
      days: {LocationKind.ambient: 14},
    );
    const gourdTea = FoodPreset(
      keywords: ['瓜茶'],
      type: FoodItemType.drink,
      days: {LocationKind.ambient: 180},
    );
    const chocolate = FoodPreset(
      keywords: ['巧克力'],
      type: FoodItemType.snack,
      days: {LocationKind.ambient: 120},
    );
    const cake = FoodPreset(
      keywords: ['蛋糕'],
      type: FoodItemType.bread,
      days: {LocationKind.ambient: 2},
    );
    const tofu = FoodPreset(
      keywords: ['豆腐'],
      type: FoodItemType.cookedFood,
      days: {LocationKind.ambient: 1},
    );
    const eggTofu = FoodPreset(
      keywords: ['雞蛋豆腐'],
      type: FoodItemType.cookedFood,
      days: {LocationKind.ambient: 1},
    );

    test('最靠近字尾的命中優先：中文的中心語在字尾', () {
      const engine = FoodSuggestionEngine(presets: [chocolate, cake]);

      // 「巧克力」比「蛋糕」長，但巧克力蛋糕是蛋糕不是巧克力。
      expect(engine.presetFor('巧克力蛋糕')?.type, FoodItemType.bread);
    });

    test('字尾優先勝過長度', () {
      const engine = FoodSuggestionEngine(presets: [gourd, gourdTea]);

      expect(engine.presetFor('冬瓜茶')?.type, FoodItemType.drink);
    });

    test('結束位置相同時長度較長者勝', () {
      const engine = FoodSuggestionEngine(presets: [tofu, eggTofu]);

      expect(engine.presetFor('雞蛋豆腐')?.type, FoodItemType.cookedFood);
      // 兩者同類型，改以關鍵字驗證選到的是哪一條。
      expect(engine.presetFor('雞蛋豆腐')?.keywords, ['雞蛋豆腐']);
    });

    test('結果與對照表在檔案裡的排列順序無關', () {
      const forward = FoodSuggestionEngine(presets: [gourd, gourdTea]);
      const reversed = FoodSuggestionEngine(presets: [gourdTea, gourd]);

      expect(
        forward.presetFor('冬瓜茶')?.type,
        reversed.presetFor('冬瓜茶')?.type,
        reason: '重新排列對照表不應改變推導結果',
      );
    });

    test('只命中一個關鍵字時照常運作', () {
      const engine = FoodSuggestionEngine(presets: [gourd, gourdTea]);

      expect(engine.presetFor('冬瓜排骨')?.type, FoodItemType.vegetable);
    });
  });
}
