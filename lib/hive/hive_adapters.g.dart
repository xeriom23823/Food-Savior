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
