import 'dart:convert';

import 'package:hive_ce/hive.dart';

/// 食物類型。列舉值只能在尾端新增（local-persistence 規格）。
enum FoodItemType {
  vegetable,
  fruit,
  meat,
  eggAndMilk,
  seafood,
  cannedFood,
  cookedFood,
  drink,
  snack,
  bread,
  others,
}

/// 食物狀態。fresh／nearExpired／expired／unknownExpiry 由有效期限推導；
/// consumed／wasted 只出現在 [UsedFoodItem]，由 [DisposalMethod] 推導。
enum FoodItemStatus {
  fresh,
  nearExpired,
  expired,
  consumed,
  wasted,
  unknownExpiry,
}

/// 份量單位。
enum Unit {
  gram,
  milliliter,
  piece,
  pack,
  box,
  bottle,
  bag,
  can,
  serving,
}

/// 不可量化的東西改記剩餘比例（醬油剩半瓶、米剩一點）。
enum RemainingFraction { full, mostly, half, low, almostGone }

/// 期限精度。四種精度統一存成 earliest／latest 兩個日期（design D10）。
enum ExpiryPrecision { exact, range, monthOnly, unknown }

/// 浪費原因。全部選填。
enum WasteReason {
  forgotten,
  boughtTooMuch,
  spoiled,
  disliked,
  expiredTooLong,
  other,
}

/// 處理方式。決定使用紀錄的 [FoodItemStatus] 與點數正負向（design D19）。
enum DisposalMethod { eaten, eatenAtRisk, givenAway, composted, discarded }

extension DisposalMethodX on DisposalMethod {
  /// 送人不算浪費：使用者沒有丟掉食物。
  bool get isWaste =>
      this == DisposalMethod.composted || this == DisposalMethod.discarded;

  FoodItemStatus get status =>
      isWaste ? FoodItemStatus.wasted : FoodItemStatus.consumed;
}

extension RemainingFractionX on RemainingFraction {
  /// 供排序與「還剩多少」的粗略比較用，不是精確份量。
  double get ratio => switch (this) {
        RemainingFraction.full => 1.0,
        RemainingFraction.mostly => 0.75,
        RemainingFraction.half => 0.5,
        RemainingFraction.low => 0.25,
        RemainingFraction.almostGone => 0.1,
      };
}

/// 期限一律以「日」為單位比較：標示「9/15 到期」的東西在 9/15 中午還沒過期。
/// 狀態推導、點數、提醒都走這兩個函式，才不會有的地方算到小時、有的地方算到天。
int daysUntilExpiry(DateTime expiry, DateTime reference) {
  final expiryDay = DateTime(expiry.year, expiry.month, expiry.day);
  final referenceDay = DateTime(reference.year, reference.month, reference.day);
  return expiryDay.difference(referenceDay).inDays;
}

bool isExpiredOn(DateTime expiry, DateTime reference) =>
    daysUntilExpiry(expiry, reference) < 0;

/// 名稱正規化：分群、模板比對、排行榜都用這一個函式，行為才會一致。
String normalizeFoodName(String name) {
  final buffer = StringBuffer();
  for (final rune in name.trim().runes) {
    // 全形英數與空白轉半形，避免「牛奶 」與「牛奶」被當成兩種東西。
    if (rune >= 0xFF01 && rune <= 0xFF5E) {
      buffer.writeCharCode(rune - 0xFEE0);
    } else if (rune == 0x3000) {
      buffer.writeCharCode(0x20);
    } else {
      buffer.writeCharCode(rune);
    }
  }
  return buffer.toString().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

/// 一項家中食物。
///
/// 期限以 [expiryEarliest]／[expiryLatest]／[expiryPrecision] 三個欄位表達四種精度；
/// 所有時間判斷一律走 [effectiveExpiry]，不要自己拿 [expiryEarliest] 算（design D11）。
class FoodItem extends HiveObject {
  FoodItem({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.storageDate,
    this.amount,
    this.unit,
    this.remainingFraction,
    this.description = '',
    this.expiryEarliest,
    this.expiryLatest,
    this.expiryPrecision = ExpiryPrecision.unknown,
    this.openedDate,
    this.shelfLifeAfterOpenDays,
    this.storageLocationId,
    this.priceTotal,
  });

  final String id;
  final String name;
  final FoodItemType type;
  final FoodItemStatus status;
  final DateTime storageDate;

  /// 數量。與 [remainingFraction] 二選一，至少其一非 null。
  final double? amount;
  final Unit? unit;
  final RemainingFraction? remainingFraction;

  final String description;

  /// 最早可能的到期日。`unknown` 精度時為 null。
  final DateTime? expiryEarliest;

  /// 最晚可能的到期日。只用於呈現不確定區間，MUST NOT 參與狀態推導。
  final DateTime? expiryLatest;
  final ExpiryPrecision expiryPrecision;

  final DateTime? openedDate;
  final int? shelfLifeAfterOpenDays;

  final String? storageLocationId;

  /// 總價（新台幣元）。選填。
  final int? priceTotal;

  /// 有效期限：開封後效期與原期限取較早者（design D11）。null 代表期限未知。
  DateTime? get effectiveExpiry {
    final opened = openedDate;
    final afterOpen = shelfLifeAfterOpenDays;
    if (opened == null || afterOpen == null) return expiryEarliest;
    final openedPlus = opened.add(Duration(days: afterOpen));
    // 期限一律以日為單位，開封推算出來的日期也要對齊，否則同一天會比出大小。
    final openedUntil =
        DateTime(openedPlus.year, openedPlus.month, openedPlus.day);
    final earliest = expiryEarliest;
    if (earliest == null) return openedUntil;
    return openedUntil.isBefore(earliest) ? openedUntil : earliest;
  }

  bool get isOpened => openedDate != null;

  /// 期限未知的項目要被看見並補齊（food-inventory 規格）。缺位置不算待補。
  bool get needsExpiryCompletion => expiryPrecision == ExpiryPrecision.unknown;

  /// 依 [now] 推導狀態。有效期限為 null → `unknownExpiry`。
  FoodItemStatus statusAt(DateTime now) {
    final expiry = effectiveExpiry;
    if (expiry == null) return FoodItemStatus.unknownExpiry;
    final days = daysUntilExpiry(expiry, now);
    if (days < 0) return FoodItemStatus.expired;
    if (days <= 3) return FoodItemStatus.nearExpired;
    return FoodItemStatus.fresh;
  }

  FoodItem withDerivedStatus(DateTime now) => copyWith(status: statusAt(now));

  FoodItem copyWith({
    String? id,
    String? name,
    FoodItemType? type,
    FoodItemStatus? status,
    DateTime? storageDate,
    double? amount,
    Unit? unit,
    RemainingFraction? remainingFraction,
    String? description,
    DateTime? expiryEarliest,
    DateTime? expiryLatest,
    ExpiryPrecision? expiryPrecision,
    DateTime? openedDate,
    int? shelfLifeAfterOpenDays,
    String? storageLocationId,
    int? priceTotal,
    bool clearAmount = false,
    bool clearRemainingFraction = false,
    bool clearExpiry = false,
    bool clearOpened = false,
    bool clearStorageLocation = false,
    bool clearPrice = false,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      storageDate: storageDate ?? this.storageDate,
      // 明確給值優先於 clear 旗標：clear 只負責「沒給值時清成 null」。
      amount: amount ?? (clearAmount ? null : this.amount),
      unit: unit ?? (clearAmount ? null : this.unit),
      remainingFraction: remainingFraction ??
          (clearRemainingFraction ? null : this.remainingFraction),
      description: description ?? this.description,
      expiryEarliest:
          expiryEarliest ?? (clearExpiry ? null : this.expiryEarliest),
      expiryLatest: expiryLatest ?? (clearExpiry ? null : this.expiryLatest),
      expiryPrecision: expiryPrecision ?? this.expiryPrecision,
      openedDate: openedDate ?? (clearOpened ? null : this.openedDate),
      shelfLifeAfterOpenDays: shelfLifeAfterOpenDays ??
          (clearOpened ? null : this.shelfLifeAfterOpenDays),
      storageLocationId: storageLocationId ??
          (clearStorageLocation ? null : this.storageLocationId),
      priceTotal: priceTotal ?? (clearPrice ? null : this.priceTotal),
    );
  }

  /// 依份量比例攤提金額（部分使用時用）。沒有金額就回傳 null。
  int? priceForPortion(double portion) {
    final price = priceTotal;
    final total = amount;
    if (price == null) return null;
    if (total == null || total <= 0) return price;
    return (price * (portion / total)).round();
  }

  UsedFoodItem toUsedFoodItem({
    required String id,
    required DisposalMethod disposalMethod,
    required DateTime usedDate,
    double? usedAmount,
    RemainingFraction? usedFraction,
    WasteReason? wasteReason,
    int? priceTotal,
    int affectFoodPoint = 0,
  }) {
    return UsedFoodItem(
      id: id,
      name: name,
      type: type,
      status: disposalMethod.status,
      storageDate: storageDate,
      amount: usedAmount ?? amount,
      unit: unit,
      remainingFraction: usedFraction ?? remainingFraction,
      description: description,
      expiryEarliest: expiryEarliest,
      expiryLatest: expiryLatest,
      expiryPrecision: expiryPrecision,
      openedDate: openedDate,
      shelfLifeAfterOpenDays: shelfLifeAfterOpenDays,
      storageLocationId: storageLocationId,
      priceTotal: priceTotal ?? priceForPortion(usedAmount ?? amount ?? 0),
      usedDate: usedDate,
      disposalMethod: disposalMethod,
      wasteReason: wasteReason,
      affectFoodPoint: affectFoodPoint,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'status': status.name,
        'storageDate': storageDate.toIso8601String(),
        'amount': amount,
        'unit': unit?.name,
        'remainingFraction': remainingFraction?.name,
        'description': description,
        'expiryEarliest': expiryEarliest?.toIso8601String(),
        'expiryLatest': expiryLatest?.toIso8601String(),
        'expiryPrecision': expiryPrecision.name,
        'openedDate': openedDate?.toIso8601String(),
        'shelfLifeAfterOpenDays': shelfLifeAfterOpenDays,
        'storageLocationId': storageLocationId,
        'priceTotal': priceTotal,
      };

  factory FoodItem.fromJson(Map<String, dynamic> data) => FoodItem(
        id: data['id'] as String,
        name: data['name'] as String,
        type:
            _enumByName(FoodItemType.values, data['type'], FoodItemType.others),
        status: _enumByName(FoodItemStatus.values, data['status'],
            FoodItemStatus.unknownExpiry),
        storageDate: DateTime.parse(data['storageDate'] as String),
        amount: (data['amount'] as num?)?.toDouble(),
        unit: _enumByNameOrNull(Unit.values, data['unit']),
        remainingFraction: _enumByNameOrNull(
            RemainingFraction.values, data['remainingFraction']),
        description: (data['description'] as String?) ?? '',
        expiryEarliest: _dateOrNull(data['expiryEarliest']),
        expiryLatest: _dateOrNull(data['expiryLatest']),
        expiryPrecision: _enumByName(ExpiryPrecision.values,
            data['expiryPrecision'], ExpiryPrecision.unknown),
        openedDate: _dateOrNull(data['openedDate']),
        shelfLifeAfterOpenDays: data['shelfLifeAfterOpenDays'] as int?,
        storageLocationId: data['storageLocationId'] as String?,
        priceTotal: data['priceTotal'] as int?,
      );

  String toJsonString() => json.encode(toJson());

  static FoodItem fromJsonString(String jsonString) =>
      FoodItem.fromJson(json.decode(jsonString) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FoodItem &&
        other.runtimeType == runtimeType &&
        other.id == id &&
        other.name == name &&
        other.type == type &&
        other.status == status &&
        other.storageDate == storageDate &&
        other.amount == amount &&
        other.unit == unit &&
        other.remainingFraction == remainingFraction &&
        other.description == description &&
        other.expiryEarliest == expiryEarliest &&
        other.expiryLatest == expiryLatest &&
        other.expiryPrecision == expiryPrecision &&
        other.openedDate == openedDate &&
        other.shelfLifeAfterOpenDays == shelfLifeAfterOpenDays &&
        other.storageLocationId == storageLocationId &&
        other.priceTotal == priceTotal;
  }

  @override
  int get hashCode => Object.hash(
        runtimeType,
        id,
        name,
        type,
        status,
        storageDate,
        amount,
        unit,
        remainingFraction,
        description,
        expiryEarliest,
        expiryLatest,
        expiryPrecision,
        Object.hash(
            openedDate, shelfLifeAfterOpenDays, storageLocationId, priceTotal),
      );
}

/// 一筆使用紀錄（食用或浪費）。
class UsedFoodItem extends FoodItem {
  UsedFoodItem({
    required super.id,
    required super.name,
    required super.type,
    required super.status,
    required super.storageDate,
    required this.usedDate,
    required this.disposalMethod,
    required this.affectFoodPoint,
    this.wasteReason,
    super.amount,
    super.unit,
    super.remainingFraction,
    super.description,
    super.expiryEarliest,
    super.expiryLatest,
    super.expiryPrecision,
    super.openedDate,
    super.shelfLifeAfterOpenDays,
    super.storageLocationId,
    super.priceTotal,
  });

  final DateTime usedDate;
  final DisposalMethod disposalMethod;
  final WasteReason? wasteReason;
  final int affectFoodPoint;

  bool get isWaste => disposalMethod.isWaste;

  @override
  UsedFoodItem copyWith({
    String? id,
    String? name,
    FoodItemType? type,
    FoodItemStatus? status,
    DateTime? storageDate,
    double? amount,
    Unit? unit,
    RemainingFraction? remainingFraction,
    String? description,
    DateTime? expiryEarliest,
    DateTime? expiryLatest,
    ExpiryPrecision? expiryPrecision,
    DateTime? openedDate,
    int? shelfLifeAfterOpenDays,
    String? storageLocationId,
    int? priceTotal,
    DateTime? usedDate,
    DisposalMethod? disposalMethod,
    WasteReason? wasteReason,
    int? affectFoodPoint,
    bool clearAmount = false,
    bool clearRemainingFraction = false,
    bool clearExpiry = false,
    bool clearOpened = false,
    bool clearStorageLocation = false,
    bool clearPrice = false,
  }) {
    final method = disposalMethod ?? this.disposalMethod;
    return UsedFoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? method.status,
      storageDate: storageDate ?? this.storageDate,
      amount: amount ?? (clearAmount ? null : this.amount),
      unit: unit ?? (clearAmount ? null : this.unit),
      remainingFraction: remainingFraction ??
          (clearRemainingFraction ? null : this.remainingFraction),
      description: description ?? this.description,
      expiryEarliest:
          expiryEarliest ?? (clearExpiry ? null : this.expiryEarliest),
      expiryLatest: expiryLatest ?? (clearExpiry ? null : this.expiryLatest),
      expiryPrecision: expiryPrecision ?? this.expiryPrecision,
      openedDate: openedDate ?? (clearOpened ? null : this.openedDate),
      shelfLifeAfterOpenDays: shelfLifeAfterOpenDays ??
          (clearOpened ? null : this.shelfLifeAfterOpenDays),
      storageLocationId: storageLocationId ??
          (clearStorageLocation ? null : this.storageLocationId),
      priceTotal: priceTotal ?? (clearPrice ? null : this.priceTotal),
      usedDate: usedDate ?? this.usedDate,
      disposalMethod: method,
      wasteReason: wasteReason ?? this.wasteReason,
      affectFoodPoint: affectFoodPoint ?? this.affectFoodPoint,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'usedDate': usedDate.toIso8601String(),
        'disposalMethod': disposalMethod.name,
        'wasteReason': wasteReason?.name,
        'affectFoodPoint': affectFoodPoint,
      };

  factory UsedFoodItem.fromJson(Map<String, dynamic> data) {
    final base = FoodItem.fromJson(data);
    final method = _enumByName(
        DisposalMethod.values, data['disposalMethod'], DisposalMethod.eaten);
    return UsedFoodItem(
      id: base.id,
      name: base.name,
      type: base.type,
      status: base.status,
      storageDate: base.storageDate,
      amount: base.amount,
      unit: base.unit,
      remainingFraction: base.remainingFraction,
      description: base.description,
      expiryEarliest: base.expiryEarliest,
      expiryLatest: base.expiryLatest,
      expiryPrecision: base.expiryPrecision,
      openedDate: base.openedDate,
      shelfLifeAfterOpenDays: base.shelfLifeAfterOpenDays,
      storageLocationId: base.storageLocationId,
      priceTotal: base.priceTotal,
      usedDate: DateTime.parse(data['usedDate'] as String),
      disposalMethod: method,
      wasteReason: _enumByNameOrNull(WasteReason.values, data['wasteReason']),
      affectFoodPoint: (data['affectFoodPoint'] as int?) ?? 0,
    );
  }

  @override
  String toJsonString() => json.encode(toJson());

  static UsedFoodItem fromJsonString(String jsonString) =>
      UsedFoodItem.fromJson(json.decode(jsonString) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UsedFoodItem &&
        super == other &&
        other.usedDate == usedDate &&
        other.disposalMethod == disposalMethod &&
        other.wasteReason == wasteReason &&
        other.affectFoodPoint == affectFoodPoint;
  }

  @override
  int get hashCode => Object.hash(
      super.hashCode, usedDate, disposalMethod, wasteReason, affectFoodPoint);
}

T _enumByName<T extends Enum>(List<T> values, Object? raw, T fallback) {
  if (raw is! String) return fallback;
  for (final value in values) {
    if (value.name == raw) return value;
  }
  return fallback;
}

T? _enumByNameOrNull<T extends Enum>(List<T> values, Object? raw) {
  if (raw is! String) return null;
  for (final value in values) {
    if (value.name == raw) return value;
  }
  return null;
}

DateTime? _dateOrNull(Object? raw) =>
    raw is String ? DateTime.tryParse(raw) : null;
