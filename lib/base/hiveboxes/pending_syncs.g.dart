// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_syncs.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PendingSyncsAdapter extends TypeAdapter<PendingSyncs> {
  @override
  final int typeId = 4;

  @override
  PendingSyncs read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PendingSyncs()
      ..pendingItems = (fields[0] as List).cast<AppItem>()
      ..pendingNotifications = (fields[1] as List).cast<Notification>()
      ..pendingShopping = (fields[2] as List).cast<AppShopping>()
      ..pendingItemsToRemove = (fields[3] as List).cast<int>();
  }

  @override
  void write(BinaryWriter writer, PendingSyncs obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.pendingItems)
      ..writeByte(1)
      ..write(obj.pendingNotifications)
      ..writeByte(2)
      ..write(obj.pendingShopping)
      ..writeByte(3)
      ..write(obj.pendingItemsToRemove);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingSyncsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
