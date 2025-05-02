import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/item.dart';
import 'package:item_minder_flutterapp/base/managers/box_manager.dart';
import 'package:item_minder_flutterapp/base/managers/item_manager.dart';
import 'package:item_minder_flutterapp/device_id.dart';

class FirebaseListeners {
  /// This method sets up Firebase listeners to listen for changes in the Firebase database.
  /// It listens for changes in the 'items' node and updates the local Hive box with the new data.
  ///
  /// Future<void> setupFirebaseListeners() async {
//TODO: FIX THE LISTENERS TO WORK WITH THE NEW FIREBASE STRUCTURE
  Future<void> setupFirebaseListeners() async {
    final currentDeviceId =
        await DeviceId().getDeviceId(); // Don't forget await!

    final itemsRef = FirebaseDatabase.instance.ref('items');

    // Listen for NEW items
    itemsRef.onChildAdded.listen((event) async {
      try {
        final itemData = Map<String, dynamic>.from(event.snapshot.value as Map);
        if (itemData['lastUpdatedBy']?.toString() != currentDeviceId) {
          // Check if the item already exists in the local box
          final existingItem =
              BoxManager().itemBox.get(int.parse(event.snapshot.key!));
          if (existingItem != null) {
            var compareTo = existingItem.lastUpdated
                .toString()
                .substring(0, 19)
                .compareTo(itemData['lastUpdated'].toString().substring(0, 19));
            if (compareTo != 0) {
              // Update the existing item if it was updated by another device
              ItemManager().editItemFromFirebase(
                  int.parse(event.snapshot.key!), AppItem.fromJson(itemData));
              debugPrint(
                  '🔄 Item updated in local box: ${event.snapshot.key}, firebase item last date: ${itemData['lastUpdated']?.toString()} and hive box date ${existingItem.lastUpdated}, compareT0 $compareTo');
              return;
            } else {
              // Skip adding if it already exists and was not updated by another device
              debugPrint(
                  'Item already exists in local box and was not updated: ${event.snapshot.key}');
              return;
            }
          }
          final item = AppItem.fromJson(itemData);
          BoxManager().itemBox.add(item); // Use Firebase push ID as key
          debugPrint('🆕 New item added: ${event.snapshot.key}');
        }
      } catch (e) {
        debugPrint('❌ child_added error: $e');
      }
    });

    // Listen for UPDATED items
    itemsRef.onChildChanged.listen((event) async {
      try {
        final itemData = Map<String, dynamic>.from(event.snapshot.value as Map);
        if (itemData['lastUpdatedBy']?.toString() != currentDeviceId) {
          final item = AppItem.fromJson(itemData);

          ItemManager()
              .editItemFromFirebase(int.parse(event.snapshot.key!), item);
          debugPrint('🔄 Item updated: ${event.snapshot.key}');
        }
      } catch (e) {
        debugPrint('❌ child_changed error: $e');
      }
    });
    //Listen for DELETED items
    itemsRef.onChildRemoved.listen((event) async {
      try {
        final itemKey = event.snapshot.key;
        if (itemKey != null) {
          await BoxManager().itemBox.delete(int.parse(itemKey));
          debugPrint('🗑️ Item deleted: $itemKey');
        }
      } catch (e) {
        debugPrint('❌ child_removed error: $e');
      }
    });
  }
}
