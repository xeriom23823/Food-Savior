import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/repositories/food_preset_repository.dart';
import 'package:food_savior/models/storage_location.dart';

void main() {
  const json = '''
[
  {"keywords": ["牛奶", "milk"], "type": "eggAndMilk", "unit": "bottle",
   "days": {"refrigerated": 7, "frozen": 30, "ambient": 1}, "afterOpenDays": 3}
]
''';

  test('讀入 asset 並解析欄位', () async {
    final repo = FoodPresetRepository(loader: (_) async => json);

    final presets = await repo.load();

    expect(presets, hasLength(1));
    expect(presets.single.type, FoodItemType.eggAndMilk);
    expect(presets.single.unit, Unit.bottle);
    expect(presets.single.daysFor(LocationKind.frozen), 30);
    expect(presets.single.afterOpenDays, 3);
  });

  test('第二次載入用快取，不再讀 asset', () async {
    var calls = 0;
    final repo = FoodPresetRepository(loader: (_) async {
      calls++;
      return json;
    });

    await repo.load();
    await repo.load();

    expect(calls, 1);
  });

  test('讀不到 asset 時回傳空清單，不讓 App 起不來', () async {
    final repo = FoodPresetRepository(
      loader: (_) async => throw Exception('missing'),
    );

    expect(await repo.load(), isEmpty);
    expect(repo.presets, isEmpty);
  });

  test('沒有該存放方式時退回常溫天數', () async {
    final repo = FoodPresetRepository(
      loader: (_) async =>
          '[{"keywords":["米"],"type":"others","days":{"ambient":365}}]',
    );

    final preset = (await repo.load()).single;

    expect(preset.daysFor(LocationKind.refrigerated), 365);
  });
}
