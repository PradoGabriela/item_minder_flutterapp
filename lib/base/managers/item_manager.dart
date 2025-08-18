import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:item_minder_flutterapp/base/managers/box_manager.dart';
import 'package:item_minder_flutterapp/base/categories.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/item.dart';
import 'package:item_minder_flutterapp/base/managers/firebase_item_manager.dart';
import 'package:item_minder_flutterapp/base/managers/group_manager.dart';
import 'package:item_minder_flutterapp/device_id.dart';
import 'package:random_string/random_string.dart';

class ItemManager {
  static final ItemManager _instance = ItemManager._internal();

  factory ItemManager() {
    return _instance;
  }

  ItemManager._internal();

  List<AppItem> currentItems = [];

  void updateItemList(Box<AppItem> box) {
    currentItems = box.values.toList(); // Retrieve all AppItems
    print(currentItems.toString());
  }

  Future<void> addCustomItem(
      {String? brandName,
      String? description,
      required String iconUrl,
      required String imageUrl,
      required String category,
      required double price,
      required String type,
      required int quantity,
      required int minQuantity,
      required int maxQuantity,
      required bool isAutoadd,
      required String groupID,
      required String itemID}) async {
    try {
      // Set default values if null/empty
      brandName =
          brandName?.trim().isEmpty ?? true ? "No Brand Provided" : brandName!;

      description = description?.trim().isEmpty ?? true
          ? "No Description Provided"
          : description!;
      if (itemID.isEmpty || itemID == "") {
        itemID = await createItemID(groupID);
      }
      final customItem = AppItem.custom(
        brandName,
        description,
        iconUrl,
        imageUrl,
        category,
        price,
        type,
        quantity,
        minQuantity,
        maxQuantity,
        isAutoadd,
        DateTime.now(), // Set last updated date to now
        DeviceId().getDeviceId(), // Set last updated by to device ID
        groupID,
        itemID,
      );

      // Add to Hive box (assuming BoxManager().itemBox is a Hive Box)
      await BoxManager().itemBox.add(customItem);
      debugPrint("Custom item key item added to box ID: ${customItem.itemID}");
      await GroupManager().addItemToGroup(groupID, itemID);
      FirebaseItemManager()
          .addItemToFirebase(groupID, customItem, itemID); // Add to Firebase

      if (kDebugMode) {
        print(
            "Custom item added: ${customItem.toString()}, key: ${customItem.itemID}, itemType: ${customItem.type}, itemCategory: ${customItem.category}");
        //print(BoxManager().itemBox.values.toList());
      }
    } catch (e) {
      if (kDebugMode) {
        print("Failed to add item: $e");
      }
      rethrow; // Optional: Re-throw if you want calling code to handle errors
    }
  }

  Future<void> editItem(
    String groupID,
    passItem, {
    required AppItem item,
    String? brandName,
    String? description,
    String? iconUrl,
    String? imageUrl,
    String? category,
    double? price,
    String? type,
    int? quantity,
    int? minQuantity,
    int? maxQuantity,
    bool? isAutoadd,
  }) async {
    try {
      // Update only non-null fields (partial updates allowed)
      if (brandName != null) item.brandName = brandName;
      if (description != null) item.description = description;
      if (iconUrl != null) item.iconUrl = iconUrl;
      if (imageUrl != null) item.imageUrl = imageUrl;
      if (category != null) item.category = category;
      if (price != null) item.price = price;
      if (type != null) item.type = type;
      if (quantity != null) item.quantity = quantity;
      if (minQuantity != null) item.minQuantity = minQuantity;
      if (maxQuantity != null) item.maxQuantity = maxQuantity;
      if (isAutoadd != null) item.isAutoAdd = isAutoadd;
      item.lastUpdatedBy =
          DeviceId().getDeviceId(); // Update last updated by field

      // Save changes (assuming Hive or similar key-value store)
      await BoxManager().itemBox.put(item.key, item);
      FirebaseItemManager().updateItemInFirebase(
          groupID, item, item.itemID); // Update in Firebase

      if (kDebugMode) {
        print("Item updated: ${item.toString()}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Failed to update item: $e");
      }
      rethrow; // Let the caller handle the error if needed
    }
  }

  //Edit only item quantity
  Future<void> editItemQuantity(AppItem item, int quantity) async {
    item.quantity = quantity;
    item.lastUpdated = DateTime.now();
    item.lastUpdatedBy = DeviceId().getDeviceId();
    item.save();
    try {
      // Update in Firebase
      await FirebaseItemManager()
          .updateItemInFirebase(item.groupID, item, item.itemID);

      if (kDebugMode) {
        print("Item quantity updated: ${item.toString()}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Failed to update item quantity: $e");
      }
    }
  }

  Future<void> editItemFromFirebase(String itemID, AppItem fireItem) async {
    try {
      // Find the item in the local box using the itemID
      final existingItem = BoxManager().itemBox.values.firstWhere(
            (item) => item.itemID == itemID,
            orElse: () => throw Exception('Item not found'),
          );

      // Check if the same groupID
      if (existingItem.groupID != fireItem.groupID) {
        if (kDebugMode) {
          print(
              "Item group ID mismatch: ${existingItem.groupID} vs ${fireItem.groupID}");
        }
        return; // Exit if group IDs do not match
      }

      // Update all fields with Firebase data
      existingItem.brandName = fireItem.brandName;
      existingItem.description = fireItem.description;
      existingItem.iconUrl = fireItem.iconUrl;
      existingItem.imageUrl = fireItem.imageUrl;
      existingItem.category = fireItem.category;
      existingItem.price = fireItem.price;
      existingItem.type = fireItem.type;
      existingItem.quantity = fireItem.quantity;
      existingItem.minQuantity = fireItem.minQuantity;
      existingItem.maxQuantity = fireItem.maxQuantity;
      existingItem.isAutoAdd = fireItem.isAutoAdd;
      existingItem.addedDateString = fireItem.addedDateString;
      existingItem.lastUpdated =
          fireItem.lastUpdated; // Update last updated date
      existingItem.lastUpdatedBy = fireItem.lastUpdatedBy;

      // Save the changes to Hive
      existingItem.save();

      if (kDebugMode) {
        print(
            "✅ Item updated from Firebase: ${existingItem.itemID} (${existingItem.type})");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Failed to update item from Firebase: $e");
      }
    }
  }

  Future<bool> removeItem(String groupID, AppItem item) async {
    try {
      // Validate item key
      if (item.key == null) {
        if (kDebugMode) {
          print("Cannot remove item: Key is null");
        }
        return false;
      }

      // Check group ID match
      if (item.groupID != groupID) {
        if (kDebugMode) {
          print("Item group ID mismatch: ${item.groupID} vs $groupID");
        }
        return false;
      }

      // Convert key to String safely
      final tempID = item.itemID;

      // Delete from local storage
      await BoxManager().itemBox.delete(item.key!);

      // Delete from Firebase
      await FirebaseItemManager().deleteItemFromFirebase(groupID, tempID);

      // Remove from group
      await GroupManager().removeItemFromGroup(groupID, tempID);

      if (kDebugMode) {
        print("Item removed from Firebase: $tempID");
        print("Item removed: ${item.type.toString()}");
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print("Error removing item '${item.type}': $e");
      }
      return false;
    }
  }

  List<AppItem> getAllAppItems(Box<AppItem> box) {
    return box.values.toList(); // Retrieve all AppItems
  }

  AppItem? getAppItemByKey(Box<AppItem> box, dynamic key) {
    return box.get(key); // Retrieve a specific AppItem by key
  }

  //String getAppItemName(Box<AppItem> box, Categories category){
  // return box.getAt(category)
  // }

  void showAllCategories() {
    print(
        "Available categories: ${Categories.values}"); //Fix string to toggle Categories. and check if can i sue directly on widgets
  }

  createItemID(String groupID) async {
    // Create a unique item ID
    String itemID = groupID + randomAlphaNumeric(8);
    // Check if the item ID already exists in the group
    final group = BoxManager().groupBox.values.firstWhere(
          (group) => group.groupID == groupID,
          orElse: () => throw Exception('Group not found'),
        );
    while (group.itemsID.contains(itemID)) {
      itemID = groupID + randomAlphaNumeric(8);
    }
    return itemID; // Return the unique item ID
  }

  // ======================================================================
  // FIREBASE LISTENER SUPPORT METHODS
  // These methods provide controlled access to Hive storage for Firebase listeners
  // without exposing direct BoxManager access
  // ======================================================================

  /**
   * Finds an item in local storage by itemID
   * Used by Firebase listeners to locate items for updates/comparisons
   */
  AppItem? findItemByID(String itemID) {
    try {
      // Search through all items in the box to find one with matching itemID
      for (var item in BoxManager().itemBox.values) {
        if (item.itemID == itemID) {
          return item;
        }
      }
      return null; // Item not found
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error finding item by ID: $e');
      }
      return null;
    }
  }

  /**
   * Adds an item from Firebase data to local storage
   * Used by Firebase listeners when syncing new items
   */
  Future<void> addItemFromFirebase(AppItem firebaseItem) async {
    try {
      await BoxManager().itemBox.add(firebaseItem);
      if (kDebugMode) {
        print(
            '🆕 Item added from Firebase: ${firebaseItem.itemID} (${firebaseItem.type})');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to add item from Firebase: $e');
      }
      rethrow;
    }
  }

  /**
   * Removes an item from local storage by itemID
   * Used by Firebase listeners when items are deleted from groups
   */
  Future<bool> removeItemByID(String itemID) async {
    try {
      final itemToDelete = findItemByID(itemID);
      if (itemToDelete != null && itemToDelete.key != null) {
        await BoxManager().itemBox.delete(itemToDelete.key!);
        if (kDebugMode) {
          print('🗑️ Item removed by ID: $itemID');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('⚠️ Item not found for deletion: $itemID');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error removing item by ID: $e');
      }
      return false;
    }
  }

  /**
   * Removes multiple items from local storage by itemIDs
   * Used by Firebase listeners when groups are deleted (cascade delete)
   */
  Future<void> removeItemsByIDs(List<String> itemIDs) async {
    for (var itemID in itemIDs) {
      try {
        await removeItemByID(itemID);
      } catch (e) {
        if (kDebugMode) {
          print('❌ Error removing item $itemID during cascade delete: $e');
        }
      }
    }
  }

  /**
   * Determines if a local item should be updated with Firebase data
   * Uses timestamp comparison to resolve conflicts
   */
  bool shouldUpdateItem(AppItem localItem, AppItem firebaseItem) {
    try {
      // Compare lastUpdated timestamps
      var compareTo = localItem.lastUpdated
          .toString()
          .substring(0, 19)
          .compareTo(firebaseItem.lastUpdated.toString().substring(0, 19));

      // Returns true if local version is older (negative comparison result)
      return compareTo < 0; // Local version is older, should update
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error comparing item timestamps: $e');
      }
      return false; // Fail-safe: don't update if comparison fails
    }
  }

  /**
   * Gets all items from local storage
   * Used by Firebase listeners for bulk operations
   */
  List<AppItem> getAllItems() {
    try {
      return BoxManager().itemBox.values.toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting all items: $e');
      }
      return [];
    }
  }
}
