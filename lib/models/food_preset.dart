import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/models/storage_location.dart';

/// 內建的保存期限對照表的一筆（design D15）。
///
/// 完全離線、可單元測試、沒有 API 成本；使用者選擇不走 AI 猜測。
class FoodPreset {
  const FoodPreset({
    required this.keywords,
    required this.type,
    required this.days,
    this.unit,
    this.afterOpenDays,
  });

  /// 比對用的關鍵字（zh／en 都放）。比對時取「最長命中」者。
  final List<String> keywords;
  final FoodItemType type;

  /// 依存放方式的建議保存天數。
  final Map<LocationKind, int> days;

  final Unit? unit;

  /// 開封後可放幾天。null 代表這種食物沒有開封的概念。
  final int? afterOpenDays;

  int? daysFor(LocationKind kind) => days[kind] ?? days[LocationKind.ambient];

  factory FoodPreset.fromJson(Map<String, dynamic> data) {
    final rawDays = (data['days'] as Map?) ?? const {};
    return FoodPreset(
      keywords: (data['keywords'] as List).cast<String>(),
      type: FoodItemType.values.firstWhere(
        (value) => value.name == data['type'],
        orElse: () => FoodItemType.others,
      ),
      unit: data['unit'] == null
          ? null
          : Unit.values.firstWhere(
              (value) => value.name == data['unit'],
              orElse: () => Unit.piece,
            ),
      days: {
        for (final entry in rawDays.entries)
          LocationKind.values.firstWhere(
            (value) => value.name == entry.key,
            orElse: () => LocationKind.other,
          ): entry.value as int,
      },
      afterOpenDays: data['afterOpenDays'] as int?,
    );
  }
}

/// 類型層級的退路：名稱沒命中任何關鍵字時用這個。
const Map<FoodItemType, Map<LocationKind, int>> kFallbackShelfLife = {
  FoodItemType.vegetable: {
    LocationKind.refrigerated: 5,
    LocationKind.frozen: 90,
    LocationKind.ambient: 3,
  },
  FoodItemType.fruit: {
    LocationKind.refrigerated: 7,
    LocationKind.frozen: 180,
    LocationKind.ambient: 4,
  },
  FoodItemType.meat: {
    LocationKind.refrigerated: 2,
    LocationKind.frozen: 90,
    LocationKind.ambient: 1,
  },
  FoodItemType.eggAndMilk: {
    LocationKind.refrigerated: 7,
    LocationKind.frozen: 30,
    LocationKind.ambient: 1,
  },
  FoodItemType.seafood: {
    LocationKind.refrigerated: 2,
    LocationKind.frozen: 90,
    LocationKind.ambient: 1,
  },
  FoodItemType.cannedFood: {
    LocationKind.refrigerated: 365,
    LocationKind.frozen: 365,
    LocationKind.ambient: 365,
  },
  FoodItemType.cookedFood: {
    LocationKind.refrigerated: 3,
    LocationKind.frozen: 30,
    LocationKind.ambient: 1,
  },
  FoodItemType.drink: {
    LocationKind.refrigerated: 14,
    LocationKind.frozen: 90,
    LocationKind.ambient: 180,
  },
  FoodItemType.snack: {
    LocationKind.refrigerated: 90,
    LocationKind.frozen: 180,
    LocationKind.ambient: 90,
  },
  FoodItemType.bread: {
    LocationKind.refrigerated: 5,
    LocationKind.frozen: 30,
    LocationKind.ambient: 3,
  },
};
