import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/item.dart';
import 'package:item_minder_flutterapp/base/managers/box_manager.dart';
import 'package:item_minder_flutterapp/services/connectivity_service.dart';

class FirebaseItemManager {
  // FirebaseItemManager class implementation
  // This class is responsible for managing items in Firebase
  // It includes methods for adding, updating, deleting, and retrieving items

  // Singleton instance
  static final FirebaseItemManager _instance = FirebaseItemManager._internal();

  // Private constructor
  FirebaseItemManager._internal();

  factory FirebaseItemManager() {
    return _instance;
  }

  get firebaseDatabase => FirebaseDatabase.instance;
  get ref => FirebaseDatabase.instance.ref('items');

// Add an item to Firebase
  Future<void> addItemToFirebase(String groupID, AppItem item) async {
    if (await ConnectivityService().isOnline) {
      try {
        await FirebaseDatabase.instance.ref('$groupID/items/${item.key}').set(
          {
            'id': item.key,
            'brandName': item.brandName,
            'description': item.description,
            'iconUrl': item.iconUrl,
            'imageUrl': item.imageUrl,
            'category': item.category,
            'price': item.price,
            'type': item.type,
            'quantity': item.quantity,
            'minQuantity': item.minQuantity,
            'maxQuantity': item.maxQuantity,
            'isAutoAdd': item.isAutoAdd,
            'addedDateString': item.addedDateString,
            'lastUpdated': DateTime.now().toString(),
            'lastUpdatedBy': item.lastUpdatedBy,
            'groupID': groupID,
          },
        );
        debugPrint('✅ Item added to Firebase: ${item.type} (ID: ${item.key})');
      } catch (e) {
        debugPrint('❌ Firebase write failed: $e');
      }
    } else {
      BoxManager().pendingSyncsBox.get(0)?.pendingItems.add(item);
      BoxManager().pendingSyncsBox.get(0)?.save();
      debugPrint('No internet connection. Item added to pending syncs.');
    }
  }

  Future<void> updateItemInFirebase(AppItem item, dynamic itemKey) async {
    // Update an item in Firebase
    // Implement the logic to update the item in Firebase
    if (await ConnectivityService().isOnline) {
      try {
        await FirebaseDatabase.instance.ref('items/$itemKey').update(
          {
            'id': '$itemKey',
            'brandName': item.brandName,
            'description': item.description,
            'iconUrl': item.iconUrl,
            'imageUrl': item.imageUrl,
            'category': item.category,
            'price': item.price,
            'type': item.type,
            'quantity': item.quantity,
            'minQuantity': item.minQuantity,
            'maxQuantity': item.maxQuantity,
            'isAutoAdd': item.isAutoAdd,
            'lastUpdated': DateTime.now().toString(),
            'lastUpdatedBy': item.lastUpdatedBy,
          },
        );
        debugPrint('Item updated in Firebase: ${item.type}');
      } catch (e) {
        debugPrint('Failed to update item in Firebase: $e');
      }
    } else {
      // If offline, add the item to pending syncs
      //First check if the item is already in pending syncs

      for (var pendingItem
          in BoxManager().pendingSyncsBox.get(0)!.pendingItems) {
        if (pendingItem.key == item.key) {
          // If the item is already in pending syncs, delete it from the list and add the new item
          BoxManager().pendingSyncsBox.get(0)?.pendingItems.removeWhere(
              (pendingItem) => pendingItem.key == item.key); // Remove old item
          BoxManager()
              .pendingSyncsBox
              .get(0)
              ?.pendingItems
              .add(item); // Add new item
          debugPrint('Item is already in pending syncs. No action taken.');
        } else {
          BoxManager().pendingSyncsBox.get(0)?.pendingItems.add(item);
          BoxManager().pendingSyncsBox.get(0)?.save();
          debugPrint('No internet connection. Item added to pending syncs.');
        }
      }
    }
  }

  Future<bool> isItemInFirebase(String itemId) async {
    // Check if an item exists in Firebase

    try {
      final snapshot =
          await FirebaseDatabase.instance.ref('items/$itemId').once();
      if (snapshot.snapshot.value != null) {
        debugPrint('Item exists in Firebase: $itemId');
        return true;
      } else {
        debugPrint('Item does not exist in Firebase: $itemId');
        return false;
      }
    } catch (e) {
      debugPrint('Failed to check item in Firebase: $e');
      return false;
    }
  }

  Future<void> deleteItemFromFirebase(String itemId) async {
    // Delete an item from Firebase
    if (await ConnectivityService().isOnline) {
      try {
        await FirebaseDatabase.instance.ref('items/$itemId').remove();
        debugPrint('Item deleted from Firebase: $itemId');
      } catch (e) {
        debugPrint('Failed to delete item from Firebase: $e');
      }
    } else {
      // If offline, add the item to pending remove syncs
      BoxManager().pendingSyncsBox.get(0)?.pendingItems.removeWhere(
          (pendingItem) => pendingItem.key == itemId); // Remove old item
      BoxManager()
          .pendingSyncsBox
          .get(0)
          ?.pendingItemsToRemove
          .add(int.parse(itemId));
      BoxManager().pendingSyncsBox.get(0)?.save();
      debugPrint('No internet connection. Item added to pending syncs.');
    }
  }
}
