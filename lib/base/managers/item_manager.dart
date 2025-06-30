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
      if (itemID.isEmpty || itemID == null || itemID == "") {
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
    if (quantity != null) item.quantity = quantity;
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
    // Find the item in the local box using the itemID
    final id = BoxManager().itemBox.values.firstWhere(
          (item) => item.itemID == itemID,
          orElse: () => throw Exception('Item not found'),
        );
    AppItem itemToEdit = BoxManager().itemBox.get(id)!;
    //check if the same grupID
    if (itemToEdit.groupID != fireItem.groupID) {
      if (kDebugMode) {
        print(
            "Item group ID mismatch: ${itemToEdit.groupID} vs ${fireItem.groupID}");
      }
      return; // Exit if group IDs do not match
    }
    itemToEdit.brandName = fireItem.brandName;
    itemToEdit.description = fireItem.description;
    itemToEdit.iconUrl = fireItem.iconUrl;
    itemToEdit.imageUrl = fireItem.imageUrl;
    itemToEdit.category = fireItem.category;
    itemToEdit.price = fireItem.price;
    itemToEdit.type = fireItem.type;
    itemToEdit.quantity = fireItem.quantity;
    itemToEdit.minQuantity = fireItem.minQuantity;
    itemToEdit.maxQuantity = fireItem.maxQuantity;
    itemToEdit.isAutoAdd = fireItem.isAutoAdd;
    itemToEdit.addedDateString = fireItem.addedDateString;
    itemToEdit.lastUpdated = fireItem.lastUpdated; // Update last updated date
    itemToEdit.lastUpdatedBy = fireItem.lastUpdatedBy;

    itemToEdit.save();
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
}
