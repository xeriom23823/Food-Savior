// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class FoodItemAdapter extends TypeAdapter<FoodItem> {
  @override
  final int typeId = 0;

  @override
  FoodItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FoodItem(
      id: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as FoodItemType,
      status: fields[3] as FoodItemStatus,
      quantity: (fields[4] as num).toInt(),
      unit: fields[5] as Unit,
      description: fields[6] as String,
      storageDate: fields[7] as DateTime,
      expirationDate: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FoodItem obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.quantity)
      ..writeByte(5)
      ..write(obj.unit)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.storageDate)
      ..writeByte(8)
      ..write(obj.expirationDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UsedFoodItemAdapter extends TypeAdapter<UsedFoodItem> {
  @override
  final int typeId = 1;

  @override
  UsedFoodItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UsedFoodItem(
      id: fields[2] as String,
      name: fields[3] as String,
      type: fields[4] as FoodItemType,
      status: fields[5] as FoodItemStatus,
      quantity: (fields[6] as num).toInt(),
      unit: fields[7] as Unit,
      description: fields[8] as String,
      storageDate: fields[9] as DateTime,
      expirationDate: fields[10] as DateTime,
      usedDate: fields[0] as DateTime,
      affectFoodPoint: (fields[1] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, UsedFoodItem obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.usedDate)
      ..writeByte(1)
      ..write(obj.affectFoodPoint)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.quantity)
      ..writeByte(7)
      ..write(obj.unit)
      ..writeByte(8)
      ..write(obj.description)
      ..writeByte(9)
      ..write(obj.storageDate)
      ..writeByte(10)
      ..write(obj.expirationDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsedFoodItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FoodItemTypeAdapter extends TypeAdapter<FoodItemType> {
  @override
  final int typeId = 2;

  @override
  FoodItemType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FoodItemType.vegetable;
      case 1:
        return FoodItemType.fruit;
      case 2:
        return FoodItemType.meat;
      case 3:
        return FoodItemType.eggAndMilk;
      case 4:
        return FoodItemType.seafood;
      case 5:
        return FoodItemType.cannedFood;
      case 6:
        return FoodItemType.cookedFood;
      case 7:
        return FoodItemType.drink;
      case 8:
        return FoodItemType.snack;
      case 9:
        return FoodItemType.bread;
      case 10:
        return FoodItemType.others;
      default:
        return FoodItemType.vegetable;
    }
  }

  @override
  void write(BinaryWriter writer, FoodItemType obj) {
    switch (obj) {
      case FoodItemType.vegetable:
        writer.writeByte(0);
      case FoodItemType.fruit:
        writer.writeByte(1);
      case FoodItemType.meat:
        writer.writeByte(2);
      case FoodItemType.eggAndMilk:
        writer.writeByte(3);
      case FoodItemType.seafood:
        writer.writeByte(4);
      case FoodItemType.cannedFood:
        writer.writeByte(5);
      case FoodItemType.cookedFood:
        writer.writeByte(6);
      case FoodItemType.drink:
        writer.writeByte(7);
      case FoodItemType.snack:
        writer.writeByte(8);
      case FoodItemType.bread:
        writer.writeByte(9);
      case FoodItemType.others:
        writer.writeByte(10);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodItemTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FoodItemStatusAdapter extends TypeAdapter<FoodItemStatus> {
  @override
  final int typeId = 3;

  @override
  FoodItemStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FoodItemStatus.fresh;
      case 1:
        return FoodItemStatus.nearExpired;
      case 2:
        return FoodItemStatus.expired;
      case 3:
        return FoodItemStatus.consumed;
      case 4:
        return FoodItemStatus.wasted;
      default:
        return FoodItemStatus.fresh;
    }
  }

  @override
  void write(BinaryWriter writer, FoodItemStatus obj) {
    switch (obj) {
      case FoodItemStatus.fresh:
        writer.writeByte(0);
      case FoodItemStatus.nearExpired:
        writer.writeByte(1);
      case FoodItemStatus.expired:
        writer.writeByte(2);
      case FoodItemStatus.consumed:
        writer.writeByte(3);
      case FoodItemStatus.wasted:
        writer.writeByte(4);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodItemStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UnitAdapter extends TypeAdapter<Unit> {
  @override
  final int typeId = 4;

  @override
  Unit read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Unit.gram;
      case 1:
        return Unit.milliliter;
      case 2:
        return Unit.piece;
      default:
        return Unit.gram;
    }
  }

  @override
  void write(BinaryWriter writer, Unit obj) {
    switch (obj) {
      case Unit.gram:
        writer.writeByte(0);
      case Unit.milliliter:
        writer.writeByte(1);
      case Unit.piece:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
