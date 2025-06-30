import 'package:flutter/cupertino.dart';
import 'package:item_minder_flutterapp/base/managers/box_manager.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/item.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/shopping.dart';

class ShoppingManager {
  // Singleton instance
  static final ShoppingManager _instance = ShoppingManager._internal();

  // Private constructor
  ShoppingManager._internal();

  // Factory constructor to return the singleton instance
  factory ShoppingManager() {
    return _instance;
  }

  Future<void> initShoppingList(String groupID) async {
    BoxManager().shoppingBox.add(AppShopping(groupID: groupID));
    debugPrint("Shopping list initialized for group: $groupID");
  }

  Future<void> addShoppingItem(
      {required AppItem item, required String groupID}) async {
    //find the shopping list for the group
    AppShopping? shoppingList = BoxManager().shoppingBox.values.firstWhere(
          (list) => list.groupID == groupID,
          orElse: () => AppShopping(groupID: groupID),
        );
    if (shoppingList == null) {
      // If no shopping list exists for the group, create a new one
      shoppingList = AppShopping(groupID: groupID);
      BoxManager().shoppingBox.add(shoppingList);
      debugPrint("New shopping list created for group: $groupID");
    }
    // Check if the item already exists by its ID in the shopping list
    if (shoppingList.items
        .any((existingItem) => existingItem.itemID == item.itemID)) {
      debugPrint("Item already exists in the shopping list: ${item.type}");
      return; // Item already exists, do not add it again
    }
    // Add a new item to the shopping list
    shoppingList.items.add(item);
    await shoppingList.save(); // Save the updated shopping list to Hive
    debugPrint("Item added to shopping list: ${item.type}");
  }

  Future<void> removeShoppingItem(
      {required AppItem item, required String groupID}) async {
    // Remove an item from the shopping list
    AppShopping shoppingList = BoxManager().shoppingBox.values.firstWhere(
          (list) => list.groupID == groupID,
          orElse: () => AppShopping(groupID: groupID),
        );
    //find the item by its ID in the shopping list and remove it
    if (!shoppingList.items
        .any((existingItem) => existingItem.itemID == item.itemID)) {
      debugPrint("Item not found in the shopping list: ${item.type}");
      return; // Item not found, do not remove it
    }
    // Remove the item from the shopping list
    shoppingList.items
        .removeWhere((existingItem) => existingItem.itemID == item.itemID);
    await shoppingList.save(); // Save the updated shopping list to Hive
  }

  Future<void> clearShoppingList() async {
    // Clear the shopping list
    AppShopping shoppingList = BoxManager().shoppingBox.getAt(0)!;
    shoppingList.items.clear();
    await shoppingList.save(); // Save the cleared shopping list to Hive
  }

  Future<List<AppItem>> getShoppingList(String groupID) async {
    // Retrieve the shopping list
    AppShopping shoppingList = BoxManager().shoppingBox.values.firstWhere(
          (list) => list.groupID == groupID,
          orElse: () => AppShopping(groupID: groupID),
        );
    return shoppingList.items; // Return the list of items in the shopping list
  }
}
