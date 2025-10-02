import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:item_minder_flutterapp/base/managers/box_manager.dart';
import 'package:item_minder_flutterapp/base/categories.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/item.dart';
import 'package:item_minder_flutterapp/base/managers/firebase_item_manager.dart';
import 'package:item_minder_flutterapp/base/managers/group_manager.dart';
import 'package:item_minder_flutterapp/device_id.dart';
import 'package:random_string/random_string.dart';

/// **Central inventory item management service with dual-persistence architecture.**
///
/// [ItemManager] serves as the primary business logic layer for all inventory item
/// operations in the Item Minder app. It implements a **dual-persistence strategy**
/// where [Hive] acts as the offline-first local storage (source of truth) and
/// [Firebase Realtime Database] provides real-time synchronization across devices.
///
/// **Core Responsibilities:**
/// * **CRUD Operations**: Create, read, update, and delete inventory items
/// * **Dual Persistence**: Automatically sync between local Hive storage and Firebase
/// * **Conflict Resolution**: Handle concurrent updates using timestamp-based resolution
/// * **Group Association**: Manage item membership within user groups
/// * **Firebase Listener Support**: Provide controlled access for real-time sync
///
/// **Critical Usage Rules:**
/// * **Never bypass this manager** - all item operations must go through [ItemManager]
/// * **Group context required** - all items must belong to a valid group
/// * **Device tracking** - all changes automatically track the originating device
///
/// This singleton class ensures data consistency and proper synchronization
/// across the app's dual-persistence architecture.
///
/// {@tool snippet}
/// ```dart
/// // Create a new inventory item
/// final itemManager = ItemManager();
/// await itemManager.addCustomItem(
///   groupID: "group123",
///   brandName: "Tide",
///   type: "laundry detergent",
///   category: "laundry",
///   quantity: 2,
///   minQuantity: 1,
///   maxQuantity: 5,
///   price: 12.99,
///   iconUrl: "assets/images/laundry_detergent.png",
///   imageUrl: "",
///   isAutoadd: true,
///   itemID: "",
/// );
///
/// // Update item quantity (common operation)
/// await itemManager.editItemQuantity(item, 3);
///
/// // Remove item from inventory
/// await itemManager.removeItem(groupID, item);
/// ```
/// {@end-tool}
class ItemManager {
  /// Singleton instance for global access to item management functionality.
  static final ItemManager _instance = ItemManager._internal();

  /// Factory constructor returns the singleton instance.
  ///
  /// This ensures all parts of the app use the same [ItemManager] instance,
  /// maintaining consistency in item operations and state management.
  factory ItemManager() {
    return _instance;
  }

  /// Private constructor for singleton pattern implementation.
  ItemManager._internal();

  /// Current cached list of items for quick access.
  ///
  /// This list is updated when [updateItemList] is called and provides
  /// fast access to items without repeated box queries.
  List<AppItem> currentItems = [];

  /// Updates the internal item cache from the provided Hive box.
  ///
  /// This method refreshes [currentItems] with all items from the Hive storage.
  /// It should be called after significant changes to ensure the cache reflects
  /// the current state of persistent storage.
  ///
  /// **Parameters:**
  /// * [box] - The Hive box containing [AppItem] objects
  ///
  /// **Side Effects:**
  /// * Updates [currentItems] list
  /// * Prints current items to debug console
  void updateItemList(Box<AppItem> box) {
    currentItems = box.values.toList(); // Retrieve all AppItems
    print(currentItems.toString());
  }

  /// Creates and persists a new inventory item with dual-storage persistence.
  ///
  /// This is the **primary method** for adding items to the inventory system.
  /// It handles the complete workflow: validation, ID generation, local storage,
  /// group association, and Firebase synchronization.
  ///
  /// **Parameters:**
  /// * [brandName] - Product brand (defaults to "No Brand Provided" if null/empty)
  /// * [description] - Item description (defaults to "No Description Provided" if null/empty)
  /// * [iconUrl] - Asset path for item category icon (required)
  /// * [imageUrl] - Custom image URL or path (required, can be empty string)
  /// * [category] - Category classification (required)
  /// * [price] - Item price (required)
  /// * [type] - Specific item type within category (required)
  /// * [quantity] - Current inventory quantity (required)
  /// * [minQuantity] - Minimum threshold for low-stock alerts (required)
  /// * [maxQuantity] - Maximum inventory capacity (required)
  /// * [isAutoadd] - Whether to auto-add to shopping list when low (required)
  /// * [groupID] - Parent group identifier (required)
  /// * [itemID] - Unique item ID (auto-generated if empty)
  ///
  /// **Workflow:**
  /// 1. Validates and sanitizes input parameters
  /// 2. Generates unique itemID if not provided
  /// 3. Creates [AppItem] with current timestamp and device tracking
  /// 4. Persists to local Hive storage
  /// 5. Associates item with group via [GroupManager]
  /// 6. Syncs to Firebase via [FirebaseItemManager]
  ///
  /// **Throws:**
  /// * [Exception] if group is not found or other validation failures
  /// * Re-throws any persistence-related exceptions
  ///
  /// {@tool snippet}
  /// ```dart
  /// await ItemManager().addCustomItem(
  ///   groupID: "family-kitchen",
  ///   brandName: "Charmin",
  ///   type: "toilet paper",
  ///   category: "bathroom",
  ///   quantity: 8,
  ///   minQuantity: 2,
  ///   maxQuantity: 12,
  ///   price: 15.99,
  ///   iconUrl: "assets/images/toilet_paper.png",
  ///   imageUrl: "",
  ///   isAutoadd: true,
  ///   itemID: "", // Auto-generated
  /// );
  /// ```
  /// {@end-tool}
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

      if (GroupManager().isGroupOnline(groupID)) {
        await FirebaseItemManager()
            .addItemToFirebase(groupID, customItem, itemID); // Add to Firebase
      }

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

  /// Updates an existing inventory item with selective field modification.
  ///
  /// This method provides **partial update capability** - only non-null parameters
  /// are applied to the existing item. It maintains data integrity by automatically
  /// updating tracking fields and syncing changes to Firebase.
  ///
  /// **Parameters:**
  /// * [groupID] - Parent group identifier for validation
  /// * [passItem] - Legacy parameter (unused, kept for compatibility)
  /// * [item] - The [AppItem] instance to update (required)
  /// * [brandName] - New brand name (optional)
  /// * [description] - New description (optional)
  /// * [iconUrl] - New icon asset path (optional)
  /// * [imageUrl] - New image URL (optional)
  /// * [category] - New category classification (optional)
  /// * [price] - New price (optional)
  /// * [type] - New item type (optional)
  /// * [quantity] - New inventory quantity (optional)
  /// * [minQuantity] - New minimum threshold (optional)
  /// * [maxQuantity] - New maximum capacity (optional)
  /// * [isAutoadd] - New auto-add setting (optional)
  ///
  /// **Automatic Updates:**
  /// * Sets `lastUpdatedBy` to current device ID
  /// * Updates `lastUpdated` timestamp during persistence
  /// * Triggers Firebase synchronization
  ///
  /// **Throws:**
  /// * Re-throws any persistence or Firebase sync exceptions
  ///
  /// {@tool snippet}
  /// ```dart
  /// // Update only specific fields
  /// await ItemManager().editItem(
  ///   groupID,
  ///   null, // passItem (legacy)
  ///   item: myItem,
  ///   quantity: 5,        // Only update quantity
  ///   price: 14.99,       // and price
  ///   // Other fields remain unchanged
  /// );
  /// ```
  /// {@end-tool}
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
      item.lastUpdated = DateTime.now(); // Update last updated timestamp
      item.lastUpdatedBy =
          DeviceId().getDeviceId(); // Update last updated by field

      // Save changes (assuming Hive or similar key-value store)
      await BoxManager().itemBox.put(item.key, item);
      debugPrint(
          "is the group online: ${GroupManager().isGroupOnline(groupID)}");
      if (GroupManager().isGroupOnline(groupID)) {
        // Sync to Firebase only if group is online
        await FirebaseItemManager()
            .updateItemInFirebase(groupID, item, item.itemID);
      }

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

  //Connect all the items in the group to update the items in firebase
  Future<void> connectAllItems(String groupID) async {
    if (GroupManager().isGroupOnline(groupID)) {
      // Get all items in the group
      final items = getItemsInGroup(groupID);
      if (kDebugMode) {
        print(items);
      }
      for (var item in items) {
        await FirebaseItemManager()
            .updateItemInFirebase(groupID, item, item.itemID);
      }
    }
  }

  /// Updates only the quantity of an inventory item with automatic sync.
  ///
  /// This **optimized method** is specifically designed for frequent quantity
  /// changes (increment/decrement operations). It's more efficient than [editItem]
  /// for quantity-only updates as it directly saves the item and syncs to Firebase.
  ///
  /// **Use Cases:**
  /// * User tapping +/- buttons in the UI
  /// * Automatic quantity adjustments
  /// * Shopping list integration
  /// * Consumption tracking
  ///
  /// **Parameters:**
  /// * [item] - The [AppItem] to update
  /// * [quantity] - New quantity value
  ///
  /// **Automatic Updates:**
  /// * Sets `lastUpdated` to current timestamp
  /// * Sets `lastUpdatedBy` to current device ID
  /// * Persists changes to Hive storage
  /// * Syncs to Firebase immediately
  ///
  /// **Note:** This method directly calls `item.save()` which is more efficient
  /// than going through the full [BoxManager] persistence cycle.
  ///
  /// {@tool snippet}
  /// ```dart
  /// // Common usage in quantity adjustment buttons
  /// void _incrementQuantity() {
  ///   ItemManager().editItemQuantity(myItem, myItem.quantity + 1);
  /// }
  ///
  /// void _decrementQuantity() {
  ///   if (myItem.quantity > 0) {
  ///     ItemManager().editItemQuantity(myItem, myItem.quantity - 1);
  ///   }
  /// }
  /// ```
  /// {@end-tool}
  Future<void> editItemQuantity(AppItem item, int quantity) async {
    item.quantity = quantity;
    item.lastUpdated = DateTime.now();
    item.lastUpdatedBy = DeviceId().getDeviceId();
    item.save();
    try {
      // Update in Firebase
      if (GroupManager().isGroupOnline(item.groupID)) {
        await FirebaseItemManager()
            .updateItemInFirebase(item.groupID, item, item.itemID);
      }

      if (kDebugMode) {
        print("Item quantity updated: ${item.toString()}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Failed to update item quantity: $e");
      }
    }
  }

  /// Updates an item from Firebase data with conflict resolution.
  ///
  /// This method is **exclusively used by Firebase listeners** to update local
  /// storage when remote changes are detected. It includes safety checks to
  /// prevent data corruption and ensure group consistency.
  ///
  /// **Parameters:**
  /// * [itemID] - Unique identifier of the item to update
  /// * [fireItem] - The [AppItem] data received from Firebase
  ///
  /// **Safety Checks:**
  /// * Verifies item exists in local storage
  /// * Validates group ID consistency
  /// * Prevents cross-group data corruption
  ///
  /// **Update Process:**
  /// 1. Locates existing item by itemID
  /// 2. Validates group membership consistency
  /// 3. Overwrites all fields with Firebase data
  /// 4. Persists changes to local storage
  ///
  /// **Important:** This method should **never be called directly** by UI code.
  /// It's designed for internal use by [FirebaseListeners] only.
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

  /// Removes an inventory item from all storage systems with validation.
  ///
  /// This method performs a **complete removal workflow** that safely deletes
  /// the item from local storage, Firebase, and group associations. It includes
  /// multiple validation checks to prevent data corruption.
  ///
  /// **Parameters:**
  /// * [groupID] - Expected group ID for validation
  /// * [item] - The [AppItem] instance to remove
  ///
  /// **Returns:**
  /// * `true` if removal was successful
  /// * `false` if validation failed or removal was unsuccessful
  ///
  /// **Validation Checks:**
  /// * Item key must not be null
  /// * Item's group ID must match provided groupID
  /// * Item must exist in storage
  ///
  /// **Removal Workflow:**
  /// 1. Validates item integrity and group membership
  /// 2. Captures itemID before deletion
  /// 3. Removes from local Hive storage
  /// 4. Removes from Firebase database
  /// 5. Removes from group's item list
  ///
  /// **Error Handling:**
  /// * Returns `false` on validation failures
  /// * Logs detailed error information in debug mode
  /// * Continues with remaining cleanup steps if possible
  ///
  /// {@tool snippet}
  /// ```dart
  /// // Safe item removal with validation
  /// bool removed = await ItemManager().removeItem(groupID, item);
  /// if (removed) {
  ///   ScaffoldMessenger.of(context).showSnackBar(
  ///     SnackBar(content: Text('Item removed successfully')),
  ///   );
  /// } else {
  ///   // Handle removal failure
  ///   ScaffoldMessenger.of(context).showSnackBar(
  ///     SnackBar(content: Text('Failed to remove item')),
  ///   );
  /// }
  /// ```
  /// {@end-tool}
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
      if (GroupManager().isGroupOnline(groupID)) {
        await FirebaseItemManager().deleteItemFromFirebase(groupID, tempID);
      }

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

  /// Retrieves all items from the specified Hive box.
  ///
  /// This is a **utility method** that provides direct access to all items
  /// in storage. Primarily used for bulk operations, reporting, and debugging.
  ///
  /// **Parameters:**
  /// * [box] - The Hive box containing [AppItem] objects
  ///
  /// **Returns:**
  /// * List of all [AppItem] objects in the box
  ///
  /// **Note:** This method returns items across all groups. For group-specific
  /// items, filter the results by `groupID` or use group-specific methods.
  List<AppItem> getAllAppItems(Box<AppItem> box) {
    return box.values.toList(); // Retrieve all AppItems
  }

  /// Retrieves a specific item by its Hive key.
  ///
  /// **Parameters:**
  /// * [box] - The Hive box to search
  /// * [key] - The Hive key of the item to retrieve
  ///
  /// **Returns:**
  /// * The [AppItem] if found, `null` otherwise
  ///
  /// **Note:** This uses Hive keys, not itemIDs. For itemID-based lookup,
  /// use [findItemByID] instead.
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

  /// Generates a unique item ID for the specified group.
  ///
  /// Creates a collision-free identifier by combining the group ID with
  /// a random alphanumeric string. Ensures uniqueness by checking against
  /// existing items in the group.
  ///
  /// **Parameters:**
  /// * [groupID] - The parent group identifier
  ///
  /// **Returns:**
  /// * A unique item ID string in format: `{groupID}{8-char-random}`
  ///
  /// **Algorithm:**
  /// 1. Generate ID as groupID + 8 random alphanumeric characters
  /// 2. Check if ID already exists in group's item list
  /// 3. Regenerate if collision detected (rare but possible)
  /// 4. Return guaranteed unique ID
  ///
  /// **Throws:**
  /// * [Exception] if the specified group is not found
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
  // without exposing direct BoxManager access. They maintain the manager pattern
  // while enabling real-time synchronization from Firebase.
  // ======================================================================

  /// Locates an item in local storage by its unique itemID.
  ///
  /// This method is **specifically designed for Firebase listeners** to find
  /// items during real-time sync operations. It performs a linear search through
  /// all items to match the itemID (not the Hive key).
  ///
  /// **Parameters:**
  /// * [itemID] - The unique item identifier to search for
  ///
  /// **Returns:**
  /// * The matching [AppItem] if found
  /// * `null` if no item with the specified itemID exists
  ///
  /// **Performance Note:** This method searches all items in storage. For
  /// performance-critical operations with large datasets, consider implementing
  /// an index-based lookup system.
  ///
  /// **Usage:** Exclusively used by [FirebaseListeners] for sync operations.
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

  /// Adds an item received from Firebase to local storage.
  ///
  /// This method handles the **local persistence** of items that were created
  /// on other devices and received through Firebase real-time listeners.
  /// It bypasses the normal validation workflow since the item data comes
  /// from a trusted Firebase source.
  ///
  /// **Parameters:**
  /// * [firebaseItem] - The complete [AppItem] received from Firebase
  ///
  /// **Important:** This method should **only be called by Firebase listeners**
  /// during real-time synchronization. Direct UI calls should use [addCustomItem].
  ///
  /// **Workflow:**
  /// 1. Directly adds the item to local Hive storage
  /// 2. Logs the operation for debugging
  /// 3. Re-throws any persistence exceptions
  ///
  /// **Error Handling:**
  /// * Logs errors with emoji prefix for easy identification
  /// * Re-throws exceptions for listener error handling
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

  /// Removes an item from local storage by itemID.
  ///
  /// This method provides **ID-based removal** specifically for Firebase listeners
  /// during cascade delete operations (e.g., when groups are deleted and all
  /// associated items must be removed).
  ///
  /// **Parameters:**
  /// * [itemID] - The unique identifier of the item to remove
  ///
  /// **Returns:**
  /// * `true` if the item was found and removed successfully
  /// * `false` if the item was not found or removal failed
  ///
  /// **Process:**
  /// 1. Locates the item using [findItemByID]
  /// 2. Validates the item has a valid Hive key
  /// 3. Removes from local storage
  /// 4. Logs the operation result
  ///
  /// **Usage:** Called by Firebase listeners during group deletion or
  /// when items are removed from other devices.
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

  /// Removes multiple items by their IDs in a single operation.
  ///
  /// This **bulk removal method** is used during cascade delete operations,
  /// particularly when entire groups are deleted and all associated items
  /// must be removed from local storage.
  ///
  /// **Parameters:**
  /// * [itemIDs] - List of item identifiers to remove
  ///
  /// **Process:**
  /// * Iterates through each itemID
  /// * Calls [removeItemByID] for each item
  /// * Continues processing even if individual removals fail
  /// * Logs errors for failed removals without stopping the operation
  ///
  /// **Error Resilience:** This method continues processing all items even
  /// if some removals fail, ensuring maximum cleanup during group deletion.
  ///
  /// **Usage:** Exclusively called by Firebase listeners during group
  /// deletion operations.
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

  /// Determines whether a local item should be updated with Firebase data.
  ///
  /// This method implements **timestamp-based conflict resolution** for the
  /// dual-persistence architecture. It compares the `lastUpdated` timestamps
  /// to determine which version of the item data is more recent.
  ///
  /// **Parameters:**
  /// * [localItem] - The item currently stored in local Hive storage
  /// * [firebaseItem] - The item data received from Firebase
  ///
  /// **Returns:**
  /// * `true` if the local item should be updated (Firebase version is newer)
  /// * `false` if the local item is current or newer
  ///
  /// **Conflict Resolution Algorithm:**
  /// 1. Extracts timestamp strings from both items' `lastUpdated` fields
  /// 2. Compares timestamps using string comparison (ISO format)
  /// 3. Returns `true` if local version is older (negative comparison)
  ///
  /// **Date Format:** Uses substring(0, 19) to extract 'YYYY-MM-DD HH:MM:SS'
  /// portion of the timestamp, ensuring consistent comparison format.
  ///
  /// **Error Handling:** Returns `false` as fail-safe if timestamp comparison
  /// fails, preventing unintended overwrites of local data.
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

  /// Retrieves all items from local storage for bulk operations.
  ///
  /// This method provides **safe access** to all items in the Hive storage
  /// specifically for Firebase listeners that need to perform bulk operations
  /// or comprehensive synchronization checks.
  ///
  /// **Returns:**
  /// * List of all [AppItem] objects in local storage
  /// * Empty list if an error occurs during retrieval
  ///
  /// **Error Handling:** Returns an empty list rather than throwing exceptions,
  /// allowing Firebase listeners to continue operating even if storage access fails.
  ///
  /// **Usage:** Used by Firebase listeners for bulk synchronization operations.
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

  //get all the items from the current groupID
  List<AppItem> getItemsInGroup(String groupID) {
    try {
      return BoxManager()
          .itemBox
          .values
          .where((item) => item.groupID == groupID)
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting items in group $groupID: $e');
      }
      return [];
    }
  }

  Future<void> fetchAndAddItemsForGroup(
      String groupID, List<String> itemIDs) async {
    for (var itemID in itemIDs) {
      try {
        final fetchedItem =
            await FirebaseItemManager().fetchItemFromFirebase(groupID, itemID);
        if (fetchedItem != null) {
          await addItemFromFirebase(fetchedItem);
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Error fetching/adding item $itemID for group $groupID: $e');
        }
      }
    }
  }
}
