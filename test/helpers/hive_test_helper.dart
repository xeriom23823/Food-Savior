import 'dart:io';

import 'package:food_savior/hive/hive_registrar.g.dart';
import 'package:food_savior/models/expiry.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/models/storage_location.dart';
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

/// 測試的固定「現在」。新程式碼的 now 都可注入，所以不需要真的時鐘。
final DateTime testNow = DateTime(2026, 9, 15, 12);

/// 期限一律以「日」為單位，所以測試的相對日期也回傳當天零時。
DateTime daysFromNow(int days, {DateTime? from}) {
  final base = (from ?? testNow).add(Duration(days: days));
  return DateTime(base.year, base.month, base.day);
}

FoodItem makeFood({
  String id = 'a',
  String? name,
  FoodItemType type = FoodItemType.fruit,
  FoodItemStatus status = FoodItemStatus.fresh,
  double? amount = 1,
  Unit? unit = Unit.piece,
  RemainingFraction? remainingFraction,
  String description = '',
  DateTime? storageDate,
  ExpiryValue? expiry,
  int? daysToExpire = 10,
  DateTime? openedDate,
  int? shelfLifeAfterOpenDays,
  String? storageLocationId,
  int? priceTotal,
}) {
  final resolved = expiry ??
      (daysToExpire == null
          ? const ExpiryValue.unknown()
          : ExpiryValue.exact(daysFromNow(daysToExpire)));
  return FoodItem(
    id: id,
    name: name ?? id,
    type: type,
    status: status,
    amount: amount,
    unit: unit,
    remainingFraction: remainingFraction,
    description: description,
    storageDate: storageDate ?? daysFromNow(-1),
    expiryEarliest: resolved.earliest,
    expiryLatest: resolved.latest,
    expiryPrecision: resolved.precision,
    openedDate: openedDate,
    shelfLifeAfterOpenDays: shelfLifeAfterOpenDays,
    storageLocationId: storageLocationId,
    priceTotal: priceTotal,
  );
}

UsedFoodItem makeUsed({
  String id = 'u',
  String? name,
  FoodItemType type = FoodItemType.fruit,
  DisposalMethod disposalMethod = DisposalMethod.eaten,
  double? amount = 1,
  Unit? unit = Unit.piece,
  DateTime? usedDate,
  DateTime? expiry,
  WasteReason? wasteReason,
  int? priceTotal,
  int affectFoodPoint = 2,
}) =>
    UsedFoodItem(
      id: id,
      name: name ?? id,
      type: type,
      status: disposalMethod.status,
      amount: amount,
      unit: unit,
      description: '',
      storageDate: daysFromNow(-5),
      expiryEarliest: expiry ?? daysFromNow(5),
      expiryLatest: expiry ?? daysFromNow(5),
      expiryPrecision: ExpiryPrecision.exact,
      usedDate: usedDate ?? testNow,
      disposalMethod: disposalMethod,
      wasteReason: wasteReason,
      priceTotal: priceTotal,
      affectFoodPoint: affectFoodPoint,
    );

StorageLocation makeLocation({
  String id = 'loc',
  String name = '冷藏',
  LocationKind kind = LocationKind.refrigerated,
  int sortOrder = 0,
}) =>
    StorageLocation(id: id, name: name, kind: kind, sortOrder: sortOrder);

List<String> ids(Iterable<FoodItem> items) => items.map((e) => e.id).toList();
