// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class FoodItemTypeAdapter extends TypeAdapter<FoodItemType> {
  @override
  final typeId = 0;

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
  final typeId = 1;

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
      case 5:
        return FoodItemStatus.unknownExpiry;
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
      case FoodItemStatus.unknownExpiry:
        writer.writeByte(5);
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
  final typeId = 2;

  @override
  Unit read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Unit.gram;
      case 1:
        return Unit.milliliter;
      case 2:
        return Unit.piece;
      case 3:
        return Unit.pack;
      case 4:
        return Unit.box;
      case 5:
        return Unit.bottle;
      case 6:
        return Unit.bag;
      case 7:
        return Unit.can;
      case 8:
        return Unit.serving;
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
      case Unit.pack:
        writer.writeByte(3);
      case Unit.box:
        writer.writeByte(4);
      case Unit.bottle:
        writer.writeByte(5);
      case Unit.bag:
        writer.writeByte(6);
      case Unit.can:
        writer.writeByte(7);
      case Unit.serving:
        writer.writeByte(8);
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

class RemainingFractionAdapter extends TypeAdapter<RemainingFraction> {
  @override
  final typeId = 3;

  @override
  RemainingFraction read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RemainingFraction.full;
      case 1:
        return RemainingFraction.mostly;
      case 2:
        return RemainingFraction.half;
      case 3:
        return RemainingFraction.low;
      case 4:
        return RemainingFraction.almostGone;
      default:
        return RemainingFraction.full;
    }
  }

  @override
  void write(BinaryWriter writer, RemainingFraction obj) {
    switch (obj) {
      case RemainingFraction.full:
        writer.writeByte(0);
      case RemainingFraction.mostly:
        writer.writeByte(1);
      case RemainingFraction.half:
        writer.writeByte(2);
      case RemainingFraction.low:
        writer.writeByte(3);
      case RemainingFraction.almostGone:
        writer.writeByte(4);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RemainingFractionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExpiryPrecisionAdapter extends TypeAdapter<ExpiryPrecision> {
  @override
  final typeId = 4;

  @override
  ExpiryPrecision read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExpiryPrecision.exact;
      case 1:
        return ExpiryPrecision.range;
      case 2:
        return ExpiryPrecision.monthOnly;
      case 3:
        return ExpiryPrecision.unknown;
      default:
        return ExpiryPrecision.exact;
    }
  }

  @override
  void write(BinaryWriter writer, ExpiryPrecision obj) {
    switch (obj) {
      case ExpiryPrecision.exact:
        writer.writeByte(0);
      case ExpiryPrecision.range:
        writer.writeByte(1);
      case ExpiryPrecision.monthOnly:
        writer.writeByte(2);
      case ExpiryPrecision.unknown:
        writer.writeByte(3);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpiryPrecisionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WasteReasonAdapter extends TypeAdapter<WasteReason> {
  @override
  final typeId = 5;

  @override
  WasteReason read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WasteReason.forgotten;
      case 1:
        return WasteReason.boughtTooMuch;
      case 2:
        return WasteReason.spoiled;
      case 3:
        return WasteReason.disliked;
      case 4:
        return WasteReason.expiredTooLong;
      case 5:
        return WasteReason.other;
      default:
        return WasteReason.forgotten;
    }
  }

  @override
  void write(BinaryWriter writer, WasteReason obj) {
    switch (obj) {
      case WasteReason.forgotten:
        writer.writeByte(0);
      case WasteReason.boughtTooMuch:
        writer.writeByte(1);
      case WasteReason.spoiled:
        writer.writeByte(2);
      case WasteReason.disliked:
        writer.writeByte(3);
      case WasteReason.expiredTooLong:
        writer.writeByte(4);
      case WasteReason.other:
        writer.writeByte(5);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WasteReasonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DisposalMethodAdapter extends TypeAdapter<DisposalMethod> {
  @override
  final typeId = 6;

  @override
  DisposalMethod read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DisposalMethod.eaten;
      case 1:
        return DisposalMethod.eatenAtRisk;
      case 2:
        return DisposalMethod.givenAway;
      case 3:
        return DisposalMethod.composted;
      case 4:
        return DisposalMethod.discarded;
      default:
        return DisposalMethod.eaten;
    }
  }

  @override
  void write(BinaryWriter writer, DisposalMethod obj) {
    switch (obj) {
      case DisposalMethod.eaten:
        writer.writeByte(0);
      case DisposalMethod.eatenAtRisk:
        writer.writeByte(1);
      case DisposalMethod.givenAway:
        writer.writeByte(2);
      case DisposalMethod.composted:
        writer.writeByte(3);
      case DisposalMethod.discarded:
        writer.writeByte(4);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DisposalMethodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LocationKindAdapter extends TypeAdapter<LocationKind> {
  @override
  final typeId = 7;

  @override
  LocationKind read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LocationKind.refrigerated;
      case 1:
        return LocationKind.frozen;
      case 2:
        return LocationKind.ambient;
      case 3:
        return LocationKind.other;
      default:
        return LocationKind.refrigerated;
    }
  }

  @override
  void write(BinaryWriter writer, LocationKind obj) {
    switch (obj) {
      case LocationKind.refrigerated:
        writer.writeByte(0);
      case LocationKind.frozen:
        writer.writeByte(1);
      case LocationKind.ambient:
        writer.writeByte(2);
      case LocationKind.other:
        writer.writeByte(3);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationKindAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FoodItemAdapter extends TypeAdapter<FoodItem> {
  @override
  final typeId = 8;

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
      storageDate: fields[4] as DateTime,
      amount: (fields[5] as num?)?.toDouble(),
      unit: fields[6] as Unit?,
      remainingFraction: fields[7] as RemainingFraction?,
      description: fields[8] == null ? '' : fields[8] as String,
      expiryEarliest: fields[9] as DateTime?,
      expiryLatest: fields[10] as DateTime?,
      expiryPrecision: fields[11] == null
          ? ExpiryPrecision.unknown
          : fields[11] as ExpiryPrecision,
      openedDate: fields[12] as DateTime?,
      shelfLifeAfterOpenDays: (fields[13] as num?)?.toInt(),
      storageLocationId: fields[14] as String?,
      priceTotal: (fields[15] as num?)?.toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, FoodItem obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.storageDate)
      ..writeByte(5)
      ..write(obj.amount)
      ..writeByte(6)
      ..write(obj.unit)
      ..writeByte(7)
      ..write(obj.remainingFraction)
      ..writeByte(8)
      ..write(obj.description)
      ..writeByte(9)
      ..write(obj.expiryEarliest)
      ..writeByte(10)
      ..write(obj.expiryLatest)
      ..writeByte(11)
      ..write(obj.expiryPrecision)
      ..writeByte(12)
      ..write(obj.openedDate)
      ..writeByte(13)
      ..write(obj.shelfLifeAfterOpenDays)
      ..writeByte(14)
      ..write(obj.storageLocationId)
      ..writeByte(15)
      ..write(obj.priceTotal);
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
  final typeId = 9;

  @override
  UsedFoodItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UsedFoodItem(
      id: fields[4] as String,
      name: fields[5] as String,
      type: fields[6] as FoodItemType,
      status: fields[7] as FoodItemStatus,
      storageDate: fields[8] as DateTime,
      usedDate: fields[0] as DateTime,
      disposalMethod: fields[1] as DisposalMethod,
      affectFoodPoint: (fields[3] as num).toInt(),
      wasteReason: fields[2] as WasteReason?,
      amount: (fields[9] as num?)?.toDouble(),
      unit: fields[10] as Unit?,
      remainingFraction: fields[11] as RemainingFraction?,
      description: fields[12] == null ? '' : fields[12] as String,
      expiryEarliest: fields[13] as DateTime?,
      expiryLatest: fields[14] as DateTime?,
      expiryPrecision: fields[15] == null
          ? ExpiryPrecision.unknown
          : fields[15] as ExpiryPrecision,
      openedDate: fields[16] as DateTime?,
      shelfLifeAfterOpenDays: (fields[17] as num?)?.toInt(),
      storageLocationId: fields[18] as String?,
      priceTotal: (fields[19] as num?)?.toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, UsedFoodItem obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.usedDate)
      ..writeByte(1)
      ..write(obj.disposalMethod)
      ..writeByte(2)
      ..write(obj.wasteReason)
      ..writeByte(3)
      ..write(obj.affectFoodPoint)
      ..writeByte(4)
      ..write(obj.id)
      ..writeByte(5)
      ..write(obj.name)
      ..writeByte(6)
      ..write(obj.type)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.storageDate)
      ..writeByte(9)
      ..write(obj.amount)
      ..writeByte(10)
      ..write(obj.unit)
      ..writeByte(11)
      ..write(obj.remainingFraction)
      ..writeByte(12)
      ..write(obj.description)
      ..writeByte(13)
      ..write(obj.expiryEarliest)
      ..writeByte(14)
      ..write(obj.expiryLatest)
      ..writeByte(15)
      ..write(obj.expiryPrecision)
      ..writeByte(16)
      ..write(obj.openedDate)
      ..writeByte(17)
      ..write(obj.shelfLifeAfterOpenDays)
      ..writeByte(18)
      ..write(obj.storageLocationId)
      ..writeByte(19)
      ..write(obj.priceTotal);
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

class StorageLocationAdapter extends TypeAdapter<StorageLocation> {
  @override
  final typeId = 10;

  @override
  StorageLocation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StorageLocation(
      id: fields[0] as String,
      name: fields[1] as String,
      kind: fields[2] as LocationKind,
      sortOrder: (fields[3] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, StorageLocation obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.kind)
      ..writeByte(3)
      ..write(obj.sortOrder);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StorageLocationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
