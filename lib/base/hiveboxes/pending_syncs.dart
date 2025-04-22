import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/item.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/shopping.dart';
part 'pending_syncs.g.dart';

@HiveType(typeId: 4) // Define a unique typeId for this class
class PendingSyncs extends HiveObject {
  @HiveField(0)
  List<AppItem> pendingItems = [];

  @HiveField(1)
  List<Notification> pendingNotifications = [];

  @HiveField(2)
  List<AppShopping> pendingShopping = [];
}
