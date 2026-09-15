import 'dart:io';

import 'package:food_savior/hive/hive_registrar.g.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:hive_ce/hive.dart';

/// 測試用 Hive 環境：每個測試檔在自己的暫存目錄初始化一次，
/// 每個測試開一個獨立命名的 Box，結束後刪除。
class HiveTestEnv {
  late Directory _dir;
  int _counter = 0;

  Future<void> setUpAll() async {
    _dir = await Directory.systemTemp.createTemp('food_savior_test_');
    Hive.init(_dir.path);
    try {
      Hive.registerAdapters();
    } on HiveError {
      // 同一個 isolate 內已註冊過（例如多個 group 共用）。
    }
  }

  Future<Box<T>> openBox<T>(String prefix) =>
      Hive.openBox<T>('${prefix}_${_counter++}');

  Future<void> tearDownAll() async {
    await Hive.close();
    try {
      _dir.deleteSync(recursive: true);
    } on FileSystemException {
      // Windows 上偶爾有檔案鎖，忽略即可（暫存目錄）。
    }
  }
}

/// 以「現在」為基準的相對日期，因為現有 Bloc / Repository 直接使用 DateTime.now()。
DateTime daysFromNow(int days, {int minutes = 0}) =>
    DateTime.now().add(Duration(days: days, minutes: minutes));

FoodItem makeFood({
  String id = 'a',
  String? name,
  FoodItemType type = FoodItemType.fruit,
  FoodItemStatus status = FoodItemStatus.fresh,
  int quantity = 1,
  Unit unit = Unit.piece,
  String description = '',
  DateTime? storageDate,
  DateTime? expirationDate,
  int daysToExpire = 10,
}) =>
    FoodItem(
      id: id,
      name: name ?? id,
      type: type,
      status: status,
      quantity: quantity,
      unit: unit,
      description: description,
      storageDate: storageDate ?? daysFromNow(-1),
      expirationDate: expirationDate ?? daysFromNow(daysToExpire),
    );

UsedFoodItem makeUsed({
  String id = 'u',
  String? name,
  FoodItemType type = FoodItemType.fruit,
  FoodItemStatus status = FoodItemStatus.consumed,
  int quantity = 1,
  Unit unit = Unit.piece,
  DateTime? usedDate,
  int? affectFoodPoint,
}) =>
    UsedFoodItem(
      id: id,
      name: name ?? id,
      type: type,
      status: status,
      quantity: quantity,
      unit: unit,
      description: '',
      storageDate: daysFromNow(-5),
      expirationDate: daysFromNow(5),
      usedDate: usedDate ?? DateTime.now(),
      affectFoodPoint:
          affectFoodPoint ?? (status == FoodItemStatus.consumed ? 1 : -1),
    );

List<String> ids(Iterable<FoodItem> items) => items.map((e) => e.id).toList();
