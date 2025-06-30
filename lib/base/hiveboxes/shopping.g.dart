// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppShoppingAdapter extends TypeAdapter<AppShopping> {
  @override
  final int typeId = 2;

  @override
  AppShopping read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppShopping(
      groupID: fields[1] as String,
    )..items = (fields[0] as List).cast<AppItem>();
  }

  @override
  void write(BinaryWriter writer, AppShopping obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.items)
      ..writeByte(1)
      ..write(obj.groupID);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppShoppingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
