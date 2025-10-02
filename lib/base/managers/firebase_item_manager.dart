import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/item.dart';
import 'package:item_minder_flutterapp/base/managers/firebase_group_manager.dart';
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

// Add an item to Firebase
  Future<void> addItemToFirebase(
      String groupID, AppItem item, String itemID) async {
    if (await ConnectivityService().isOnline) {
      try {
        await FirebaseDatabase.instance
            .ref('groups/$groupID/itemsID/$itemID')
            .set(
          {
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
            'itemID': itemID,
          },
        );
        debugPrint('✅ Item added to Firebase: ${item.type} (ID: $itemID)');
      } catch (e) {
        debugPrint('❌ Firebase write failed: $e');
      }
    } else {
      debugPrint('No internet connection.');
    }
  }

  Future<void> updateItemInFirebase(
      String groupID, AppItem item, String itemID) async {
    if (await ConnectivityService().isOnline) {
      try {
        // ✅ Check if item exists first, then update or create
        final itemRef = FirebaseDatabase.instance
            .ref('groups/$groupID/itemsID')
            .child(itemID);

        // Check if item exists
        final snapshot = await itemRef.once();

        if (snapshot.snapshot.exists) {
          // Update existing item
          await itemRef.update({
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
            'lastUpdated': item.lastUpdated.toString(),
            'lastUpdatedBy': item.lastUpdatedBy,
            'groupID': groupID,
            'itemID': itemID,
          });
          debugPrint('✅ Item updated in Firebase: ${item.type}');
        } else {
          // Item doesn't exist, create it
          await itemRef.set({
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
            'lastUpdated': item.lastUpdated.toString(),
            'lastUpdatedBy': item.lastUpdatedBy,
            'groupID': groupID,
            'itemID': itemID,
          });
          debugPrint('✅ Item created in Firebase: ${item.type}');
        }

        // Update the group timestamp
        await FirebaseGroupManager().updateGroupLastUpdated(
            groupID, item.lastUpdatedBy, item.lastUpdated.toString());
      } catch (e) {
        debugPrint('❌ Failed to update item in Firebase: $e');
      }
    } else {
      debugPrint('❌ No internet connection.');
    }
  }

  Future<bool> isItemInFirebase(String groupID, String itemID) async {
    // Check if an item exists in Firebase

    try {
      final snapshot = await FirebaseDatabase.instance
          .ref('groups/$groupID/itemsID/$itemID')
          .once();
      if (snapshot.snapshot.value != null) {
        debugPrint('Item exists in Firebase: $itemID');
        return true;
      } else {
        debugPrint('Item does not exist in Firebase: $itemID');
        return false;
      }
    } catch (e) {
      debugPrint('Failed to check item in Firebase: $e');
      return false;
    }
  }

  Future<void> deleteItemFromFirebase(String groupID, String itemID) async {
    // Delete an item from Firebase
    if (await ConnectivityService().isOnline) {
      try {
        await FirebaseDatabase.instance
            .ref('groups/$groupID/itemsID/$itemID')
            .remove();
        debugPrint('Item deleted from Firebase: $itemID');
      } catch (e) {
        debugPrint('Failed to delete item from Firebase: $e');
      }
    } else {
      debugPrint('No internet connection..');
    }
  }

  Future<AppItem?> fetchItemFromFirebase(String groupID, String itemID) async {
    // Retrieve an item from Firebase
    try {
      final snapshot = await FirebaseDatabase.instance
          .ref('groups/$groupID/itemsID/$itemID')
          .once();

      if (snapshot.snapshot.value != null) {
        final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
        AppItem fetchedItem = AppItem.custom(
          data['brandName'] ?? "No Brand Provided",
          data['description'] ?? "No Description Provided",
          data['iconUrl'] ?? "",
          data['imageUrl'] ?? "",
          data['category'] ?? "uncategorized",
          (data['price'] as num?)?.toDouble() ?? 0.0,
          data['type'] ?? "unknown",
          data['quantity'] ?? 0,
          data['minQuantity'] ?? 1,
          data['maxQuantity'] ?? 4,
          data['isAutoAdd'] ?? false,
          DateTime.parse(data['lastUpdated'] ?? DateTime.now().toString()),
          data['lastUpdatedBy'] ?? "",
          groupID,
          itemID,
        );
        return fetchedItem;
      } else {
        debugPrint('Item not found in Firebase: $itemID');
        return null;
      }
    } catch (e) {
      debugPrint('Failed to retrieve item from Firebase: $e');
      return null;
    }
  }
}
