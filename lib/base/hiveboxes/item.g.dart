// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppItemAdapter extends TypeAdapter<AppItem> {
  @override
  final int typeId = 0;

  @override
  AppItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppItem()
      ..brandName = fields[0] as String
      ..description = fields[1] as String
      ..iconUrl = fields[2] as String
      ..imageUrl = fields[3] as String
      ..category = fields[4] as String
      ..price = fields[5] as double
      ..type = fields[6] as String
      ..quantity = fields[7] as int
      ..minQuantity = fields[8] as int
      ..maxQuantity = fields[9] as int
      ..isAutoAdd = fields[10] as bool
      ..addedDateString = fields[11] as String
      ..lastUpdated = fields[12] as DateTime
      ..lastUpdatedBy = fields[13] as String
      ..groupID = fields[14] as String
      ..itemID = fields[15] as String;
  }

  @override
  void write(BinaryWriter writer, AppItem obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.brandName)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.iconUrl)
      ..writeByte(3)
      ..write(obj.imageUrl)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.price)
      ..writeByte(6)
      ..write(obj.type)
      ..writeByte(7)
      ..write(obj.quantity)
      ..writeByte(8)
      ..write(obj.minQuantity)
      ..writeByte(9)
      ..write(obj.maxQuantity)
      ..writeByte(10)
      ..write(obj.isAutoAdd)
      ..writeByte(11)
      ..write(obj.addedDateString)
      ..writeByte(12)
      ..write(obj.lastUpdated)
      ..writeByte(13)
      ..write(obj.lastUpdatedBy)
      ..writeByte(14)
      ..write(obj.groupID)
      ..writeByte(15)
      ..write(obj.itemID);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
