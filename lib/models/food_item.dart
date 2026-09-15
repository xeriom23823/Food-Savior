import 'package:flutter/material.dart';
import 'package:food_savior/generated/l10n.dart';
import 'package:hive_ce/hive.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';

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
  others
}

extension FoodItemTypeExtension on FoodItemType {
  IconData get icon {
    switch (this) {
      case FoodItemType.vegetable:
        return FontAwesomeIcons.carrot.data;
      case FoodItemType.fruit:
        return FontAwesomeIcons.appleWhole.data;
      case FoodItemType.meat:
        return FontAwesomeIcons.drumstickBite.data;
      case FoodItemType.eggAndMilk:
        return FontAwesomeIcons.egg.data;
      case FoodItemType.seafood:
        return FontAwesomeIcons.fish.data;
      case FoodItemType.cannedFood:
        return FontAwesomeIcons.jar.data;
      case FoodItemType.cookedFood:
        return FontAwesomeIcons.bowlFood.data;
      case FoodItemType.drink:
        return FontAwesomeIcons.mugSaucer.data;
      case FoodItemType.snack:
        return FontAwesomeIcons.cookieBite.data;
      case FoodItemType.bread:
        return FontAwesomeIcons.breadSlice.data;
      case FoodItemType.others:
        return FontAwesomeIcons.utensils.data;
    }
  }

  String localizedName(BuildContext context) {
    switch (this) {
      case FoodItemType.vegetable:
        return S.of(context).foodItemTypeVegetable;
      case FoodItemType.fruit:
        return S.of(context).foodItemTypeFruit;
      case FoodItemType.meat:
        return S.of(context).foodItemTypeMeat;
      case FoodItemType.eggAndMilk:
        return S.of(context).foodItemTypeEggAndMilk;
      case FoodItemType.seafood:
        return S.of(context).foodItemTypeSeafood;
      case FoodItemType.cannedFood:
        return S.of(context).foodItemTypeCannedFood;
      case FoodItemType.cookedFood:
        return S.of(context).foodItemTypeCookedFood;
      case FoodItemType.drink:
        return S.of(context).foodItemTypeDrink;
      case FoodItemType.snack:
        return S.of(context).foodItemTypeSnack;
      case FoodItemType.bread:
        return S.of(context).foodItemTypeBread;
      case FoodItemType.others:
        return S.of(context).foodItemTypeOthers;
    }
  }

  Color get color {
    switch (this) {
      case FoodItemType.vegetable:
        return Colors.green.shade300;
      case FoodItemType.fruit:
        return Colors.red.shade300;
      case FoodItemType.meat:
        return Colors.brown.shade300;
      case FoodItemType.eggAndMilk:
        return Colors.yellow.shade300;
      case FoodItemType.seafood:
        return Colors.blue.shade300;
      case FoodItemType.cannedFood:
        return Colors.grey.shade500;
      case FoodItemType.cookedFood:
        return Colors.orange.shade300;
      case FoodItemType.drink:
        return Colors.purple.shade300;
      case FoodItemType.snack:
        return Colors.pink.shade300;
      case FoodItemType.bread:
        return Colors.brown.shade300;
      case FoodItemType.others:
        return Colors.grey.shade500;
    }
  }
}

enum FoodItemStatus { fresh, nearExpired, expired, consumed, wasted }

extension FoodItemStatusExtension on FoodItemStatus {
  Color get color {
    switch (this) {
      case FoodItemStatus.fresh:
        return Colors.green;
      case FoodItemStatus.nearExpired:
        return Colors.orange;
      case FoodItemStatus.expired:
        return Colors.red;
      case FoodItemStatus.consumed:
        return Colors.blue;
      case FoodItemStatus.wasted:
        return Colors.grey;
    }
  }

  String localizedName(BuildContext context) {
    switch (this) {
      case FoodItemStatus.fresh:
        return S.of(context).foodItemStatusFresh;
      case FoodItemStatus.nearExpired:
        return S.of(context).foodItemStatusNearExpired;
      case FoodItemStatus.expired:
        return S.of(context).foodItemStatusExpired;
      case FoodItemStatus.consumed:
        return S.of(context).foodItemStatusConsumed;
      case FoodItemStatus.wasted:
        return S.of(context).foodItemStatusWasted;
    }
  }
}

enum Unit { gram, milliliter, piece }

extension UnitExtension on Unit {
  String localizedName(BuildContext context) {
    switch (this) {
      case Unit.gram:
        return S.of(context).unitGram;
      case Unit.milliliter:
        return S.of(context).unitMilliliter;
      case Unit.piece:
        return S.of(context).unitPiece;
    }
  }
}

class FoodItem extends HiveObject {
  final String id;
  final String name;
  final FoodItemType type;
  final FoodItemStatus status;
  final int quantity;
  final Unit unit;
  final String description;
  final DateTime storageDate;
  final DateTime expirationDate;

  FoodItem(
      {required this.id,
      required this.name,
      required this.type,
      required this.status,
      required this.quantity,
      required this.unit,
      required this.description,
      required this.storageDate,
      required this.expirationDate});

  FoodItem copyWith({
    String? id,
    String? name,
    FoodItemType? type,
    FoodItemStatus? status,
    int? quantity,
    Unit? unit,
    String? description,
    DateTime? storageDate,
    DateTime? expirationDate,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      description: description ?? this.description,
      storageDate: storageDate ?? this.storageDate,
      expirationDate: expirationDate ?? this.expirationDate,
    );
  }

  // 顯示食物的數量與單位
  String quantityWithUnit(BuildContext context) {
    switch (unit) {
      case Unit.gram:
        return '$quantity ${unit.localizedName(context)}';
      case Unit.milliliter:
        return '$quantity ${unit.localizedName(context)}';
      case Unit.piece:
        return '$quantity ${unit.localizedName(context)}';
    }
  }

  UsedFoodItem toUsedFoodItem(
      {required String id,
      required FoodItemStatus usedStatus,
      required DateTime usedDate,
      required int usedQuantity}) {
    return UsedFoodItem(
        id: id,
        name: name,
        type: type,
        status: usedStatus,
        quantity: usedQuantity,
        unit: unit,
        description: description,
        storageDate: storageDate,
        expirationDate: expirationDate,
        usedDate: usedDate,
        affectFoodPoint: usedStatus == FoodItemStatus.consumed ? 1 : -1);
  }

  // 將 FoodItem 物件轉換為 JSON 字符串
  String toJsonString() => json.encode({
        'id': id,
        'name': name,
        'type': type.toString(),
        'status': status.toString(),
        'quantity': quantity,
        'unit': unit.toString(),
        'description': description,
        'storageDate': storageDate.toIso8601String(),
        'expirationDate': expirationDate.toIso8601String(),
      });

  // 從 JSON 字符串創建一個 FoodItem 物件
  static FoodItem fromJsonString(String jsonString) {
    final data = json.decode(jsonString);
    return FoodItem(
      id: data['id'],
      name: data['name'],
      type: FoodItemType.values.firstWhere(
        (e) => e.toString() == data['type'],
      ),
      status: FoodItemStatus.values.firstWhere(
        (e) => e.toString() == data['status'],
      ),
      quantity: data['quantity'],
      unit: Unit.values.firstWhere(
        (e) => e.toString() == data['unit'],
      ),
      description: data['description'],
      storageDate: DateTime.parse(data['storageDate']),
      expirationDate: DateTime.parse(data['expirationDate']),
    );
  }

  factory FoodItem.fromJson(Map<String, dynamic> data) {
    return FoodItem(
      id: data['id'],
      name: data['name'],
      type: FoodItemType.values.byName(data['type']),
      status: FoodItemStatus.values.byName(data['status']),
      quantity: data['quantity'],
      unit: Unit.values.byName(data['unit']),
      description: data['description'],
      storageDate: DateTime.parse(data['storageDate']),
      expirationDate: DateTime.parse(data['expirationDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'status': status.name,
      'quantity': quantity,
      'unit': unit.name,
      'description': description,
      'storageDate': storageDate.toIso8601String(),
      'expirationDate': expirationDate.toIso8601String(),
    };
  }

  // 值相等（food-inventory 規格）：所有欄位相同才相等，hashCode 與 == 一致；
  // runtimeType 比對讓 FoodItem 與 UsedFoodItem 即使 id 相同也不相等。
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FoodItem &&
        other.runtimeType == runtimeType &&
        other.id == id &&
        other.name == name &&
        other.type == type &&
        other.status == status &&
        other.quantity == quantity &&
        other.unit == unit &&
        other.description == description &&
        other.storageDate == storageDate &&
        other.expirationDate == expirationDate;
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name, type, status, quantity,
      unit, description, storageDate, expirationDate);
}

class UsedFoodItem extends FoodItem {
  final DateTime usedDate;
  final int affectFoodPoint;

  UsedFoodItem(
      {required super.id,
      required super.name,
      required super.type,
      required super.status,
      required super.quantity,
      required super.unit,
      required super.description,
      required super.storageDate,
      required super.expirationDate,
      required this.usedDate,
      required this.affectFoodPoint});

  // 複寫 copyWith 方法，以便在更新 UsedFoodItem 物件時使用
  @override
  UsedFoodItem copyWith({
    String? id,
    String? name,
    FoodItemType? type,
    FoodItemStatus? status,
    int? quantity,
    Unit? unit,
    String? description,
    DateTime? storageDate,
    DateTime? expirationDate,
    DateTime? usedDate,
    int? affectFoodPoint,
  }) {
    return UsedFoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      description: description ?? this.description,
      storageDate: storageDate ?? this.storageDate,
      expirationDate: expirationDate ?? this.expirationDate,
      usedDate: usedDate ?? this.usedDate,
      affectFoodPoint: affectFoodPoint ?? this.affectFoodPoint,
    );
  }

  // 將 UsedFoodItem 物件轉換為 JSON
  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'usedDate': usedDate.toIso8601String(),
      'affectFoodPoint': affectFoodPoint,
    });
    return json;
  }

  // 從 JSON 創建一個 UsedFoodItem 物件
  factory UsedFoodItem.fromJson(Map<String, dynamic> data) {
    return UsedFoodItem(
      id: data['id'],
      name: data['name'],
      type: FoodItemType.values.byName(data['type']),
      status: FoodItemStatus.values.byName(data['status']),
      quantity: data['quantity'],
      unit: Unit.values.byName(data['unit']),
      description: data['description'],
      storageDate: DateTime.parse(data['storageDate']),
      expirationDate: DateTime.parse(data['expirationDate']),
      usedDate: DateTime.parse(data['usedDate']),
      affectFoodPoint: data['affectFoodPoint'] ?? 0,
    );
  }

  // 將 UsedFoodItem 物件轉換為 JSON 字符串
  @override
  String toJsonString() => json.encode({
        'id': id,
        'name': name,
        'type': type.toString(),
        'status': status.toString(),
        'quantity': quantity,
        'unit': unit.toString(),
        'description': description,
        'storageDate': storageDate.toIso8601String(),
        'expirationDate': expirationDate.toIso8601String(),
        'usedDate': usedDate.toIso8601String(),
        'affectFoodPoint': affectFoodPoint,
      });

  // 從 JSON 字符串創建一個 UsedFoodItem 物件
  static UsedFoodItem fromJsonString(String jsonString) {
    final data = json.decode(jsonString);
    return UsedFoodItem(
      id: data['id'],
      name: data['name'],
      type: FoodItemType.values.firstWhere(
        (e) => e.toString() == data['type'],
      ),
      status: FoodItemStatus.values.firstWhere(
        (e) => e.toString() == data['status'],
      ),
      quantity: data['quantity'],
      unit: Unit.values.firstWhere(
        (e) => e.toString() == data['unit'],
      ),
      description: data['description'],
      storageDate: DateTime.parse(data['storageDate']),
      expirationDate: DateTime.parse(data['expirationDate']),
      usedDate: DateTime.parse(data['usedDate']),
      affectFoodPoint: data['affectFoodPoint'] ?? 0,
    );
  }

  // 值相等：沿用 FoodItem 的欄位比較，再加上 usedDate 與 affectFoodPoint。
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UsedFoodItem &&
        super == other &&
        other.usedDate == usedDate &&
        other.affectFoodPoint == affectFoodPoint;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, usedDate, affectFoodPoint);
}
