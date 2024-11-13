import 'package:flutter/material.dart';
import 'package:food_savior/languages/app_localizations.dart';
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

  String name(BuildContext context) {
    switch (this) {
      case FoodItemType.vegetable:
        return AppLocalizations.of(context).foodItemTypeVegetable;
      case FoodItemType.fruit:
        return AppLocalizations.of(context).foodItemTypeFruit;
      case FoodItemType.meat:
        return AppLocalizations.of(context).foodItemTypeMeat;
      case FoodItemType.eggAndMilk:
        return AppLocalizations.of(context).foodItemTypeEggAndMilk;
      case FoodItemType.seafood:
        return AppLocalizations.of(context).foodItemTypeSeafood;
      case FoodItemType.cannedFood:
        return AppLocalizations.of(context).foodItemTypeCannedFood;
      case FoodItemType.cookedFood:
        return AppLocalizations.of(context).foodItemTypeCookedFood;
      case FoodItemType.drink:
        return AppLocalizations.of(context).foodItemTypeDrink;
      case FoodItemType.snack:
        return AppLocalizations.of(context).foodItemTypeSnack;
      case FoodItemType.bread:
        return AppLocalizations.of(context).foodItemTypeBread;
      case FoodItemType.others:
        return AppLocalizations.of(context).foodItemTypeOthers;
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
      default:
        return Colors.red;
    }
  }

  String name(BuildContext context) {
    switch (this) {
      case FoodItemStatus.fresh:
        return AppLocalizations.of(context).foodItemStatusFresh;
      case FoodItemStatus.nearExpired:
        return AppLocalizations.of(context).foodItemStatusNearExpired;
      case FoodItemStatus.expired:
        return AppLocalizations.of(context).foodItemStatusExpired;
      case FoodItemStatus.consumed:
        return AppLocalizations.of(context).foodItemStatusConsumed;
      case FoodItemStatus.wasted:
        return AppLocalizations.of(context).foodItemStatusWasted;
      default:
        return AppLocalizations.of(context).foodItemStatusUnknown;
    }
  }
}

enum Unit { gram, milliliter, piece }

extension UnitExtension on Unit {
  String name(BuildContext context) {
    switch (this) {
      case Unit.gram:
        return AppLocalizations.of(context).unitGram;
      case Unit.milliliter:
        return AppLocalizations.of(context).unitMilliliter;
      case Unit.piece:
        return AppLocalizations.of(context).unitPiece;
    }
  }
}

class FoodItem {
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
    String? id = '',
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
  String quantityWithUnit(context) {
    switch (unit) {
      case Unit.gram:
        return '$quantity ${unit.name(context)}';
      case Unit.milliliter:
        return '$quantity ${unit.name(context)}';
      case Unit.piece:
        return '$quantity ${unit.name(context)}';
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
        affectFoodPoint: 0);
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString(),
      'status': status.toString(),
      'quantity': quantity,
      'unit': unit.toString(),
      'description': description,
      'storageDate': storageDate.toIso8601String(),
      'expirationDate': expirationDate.toIso8601String(),
    };
  }

  // 複寫 == 運算符，以便在比較 FoodItem 物件時使用
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FoodItem && other.id == id;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      id.hashCode ^
      name.hashCode ^
      type.hashCode ^
      status.hashCode ^
      quantity.hashCode ^
      unit.hashCode ^
      description.hashCode ^
      storageDate.hashCode ^
      expirationDate.hashCode;
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

  // 複寫 == 運算符，以便在比較 UsedFoodItem 物件時使用
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UsedFoodItem && other.id == id;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      id.hashCode ^
      name.hashCode ^
      type.hashCode ^
      status.hashCode ^
      quantity.hashCode ^
      unit.hashCode ^
      description.hashCode ^
      storageDate.hashCode ^
      expirationDate.hashCode ^
      usedDate.hashCode ^
      affectFoodPoint.hashCode;
}
