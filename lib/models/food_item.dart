// 目的：食物項目的資料模型
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
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
        return MdiIcons.carrot;
      case FoodItemType.fruit:
        return MdiIcons.apple;
      case FoodItemType.meat:
        return MdiIcons.foodSteak;
      case FoodItemType.eggAndMilk:
        return MdiIcons.eggFried;
      case FoodItemType.seafood:
        return MdiIcons.fish;
      case FoodItemType.cannedFood:
        return MdiIcons.zipBox;
      case FoodItemType.cookedFood:
        return MdiIcons.food;
      case FoodItemType.drink:
        return MdiIcons.cup;
      case FoodItemType.snack:
        return MdiIcons.cookie;
      case FoodItemType.bread:
        return MdiIcons.breadSlice;
      case FoodItemType.others:
        return MdiIcons.foodForkDrink;
    }
  }

  String get name {
    switch (this) {
      case FoodItemType.vegetable:
        return '蔬菜';
      case FoodItemType.fruit:
        return '水果';
      case FoodItemType.meat:
        return '肉類';
      case FoodItemType.eggAndMilk:
        return '蛋奶';
      case FoodItemType.seafood:
        return '海鮮';
      case FoodItemType.cannedFood:
        return '罐頭食品';
      case FoodItemType.cookedFood:
        return '熟食';
      case FoodItemType.drink:
        return '飲料';
      case FoodItemType.snack:
        return '零食';
      case FoodItemType.bread:
        return '麵包';
      case FoodItemType.others:
        return '其他';
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
      default:
        return Colors.red;
    }
  }
}

enum Unit { gram, kilogram, milliliter, liter, piece }

extension UnitExtension on Unit {
  String get name {
    switch (this) {
      case Unit.gram:
        return '公克';
      case Unit.kilogram:
        return '公斤';
      case Unit.milliliter:
        return '毫升';
      case Unit.liter:
        return '公升';
      case Unit.piece:
        return '個';
    }
  }
}

class FoodItem {
  final String name;
  final FoodItemType type;
  final FoodItemStatus status;
  final double quantity;
  final Unit unit;
  final String description;
  final DateTime storageDate;
  final DateTime expirationDate;

  FoodItem(
      {required this.name,
      required this.type,
      required this.status,
      required this.quantity,
      required this.unit,
      required this.description,
      required this.storageDate,
      required this.expirationDate});

  FoodItem copyWith({
    String? name,
    FoodItemType? type,
    FoodItemStatus? status,
    double? quantity,
    Unit? unit,
    String? description,
    DateTime? storageDate,
    DateTime? expirationDate,
  }) {
    return FoodItem(
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
  String get quantityWithUnit {
    switch (unit) {
      case Unit.gram:
        return '${quantity.toStringAsFixed(0)} ${unit.name}';
      case Unit.kilogram:
        return '${quantity.toStringAsFixed(1)} ${unit.name}';
      case Unit.milliliter:
        return '${quantity.toStringAsFixed(0)} ${unit.name}';
      case Unit.liter:
        return '${quantity.toStringAsFixed(1)} ${unit.name}';
      case Unit.piece:
        return '${quantity.toInt()} ${unit.name}';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FoodItem &&
        other.name == name &&
        other.type == type &&
        other.status == status &&
        other.description == description;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        type.hashCode ^
        status.hashCode ^
        description.hashCode;
  }

  UsedFoodItem toUsedFoodItem(
      {required FoodItemStatus usedStatus,
      required DateTime usedDate,
      required double usedQuantity}) {
    return UsedFoodItem(
        name: name,
        type: type,
        status: usedStatus,
        quantity: usedQuantity,
        unit: unit,
        description: description,
        storageDate: storageDate,
        expirationDate: expirationDate,
        usedDate: usedDate);
  }

  // 將 FoodItem 物件轉換為 JSON 字符串
  String toJson() => json.encode({
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
  static FoodItem fromJson(String jsonString) {
    final data = json.decode(jsonString);
    return FoodItem(
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
}

class UsedFoodItem extends FoodItem {
  final DateTime usedDate;

  UsedFoodItem(
      {required super.name,
      required super.type,
      required super.status,
      required super.quantity,
      required super.unit,
      required super.description,
      required super.storageDate,
      required super.expirationDate,
      required this.usedDate});

  // 將 UsedFoodItem 物件轉換為 JSON 字符串
  @override
  String toJson() => json.encode({
        'name': name,
        'type': type.toString(),
        'status': status.toString(),
        'quantity': quantity,
        'unit': unit.toString(),
        'description': description,
        'storageDate': storageDate.toIso8601String(),
        'expirationDate': expirationDate.toIso8601String(),
        'usedDate': usedDate.toIso8601String(),
      });

  // 從 JSON 字符串創建一個 UsedFoodItem 物件
  static UsedFoodItem fromJson(String jsonString) {
    final data = json.decode(jsonString);
    return UsedFoodItem(
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
    );
  }
}
