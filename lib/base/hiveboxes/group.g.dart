// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppGroupAdapter extends TypeAdapter<AppGroup> {
  @override
  final int typeId = 5;

  @override
  AppGroup read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppGroup(
      groupID: fields[0] as String,
      groupName: fields[1] as String,
      members: (fields[2] as List).cast<String>(),
      createdBy: fields[3] as String,
      groupIconUrl: fields[4] as String,
      itemsID: (fields[5] as List).cast<String>(),
      pendingSyncsID: (fields[6] as List).cast<int>(),
      shoppingListID: (fields[7] as List).cast<int>(),
      categoriesNames: (fields[8] as List).cast<String>(),
      lastUpdatedBy: fields[9] as String,
      lastUpdatedDateString: fields[10] as String,
      createdByDeviceId: fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AppGroup obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.groupID)
      ..writeByte(1)
      ..write(obj.groupName)
      ..writeByte(2)
      ..write(obj.members)
      ..writeByte(3)
      ..write(obj.createdBy)
      ..writeByte(4)
      ..write(obj.groupIconUrl)
      ..writeByte(5)
      ..write(obj.itemsID)
      ..writeByte(6)
      ..write(obj.pendingSyncsID)
      ..writeByte(7)
      ..write(obj.shoppingListID)
      ..writeByte(8)
      ..write(obj.categoriesNames)
      ..writeByte(9)
      ..write(obj.lastUpdatedBy)
      ..writeByte(10)
      ..write(obj.lastUpdatedDateString)
      ..writeByte(11)
      ..write(obj.createdByDeviceId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppGroupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
