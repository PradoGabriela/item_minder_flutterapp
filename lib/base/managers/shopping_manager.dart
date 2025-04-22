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

  Future<void> initShoppingList() async {
    if (BoxManager().shoppingBox.isEmpty) {
      BoxManager().shoppingBox.add(AppShopping());
    }
    debugPrint("Current Shopping List: ${BoxManager().shoppingBox.getAt(0)}");
  }

  Future<void> addShoppingItem({required AppItem item}) async {
    // Add a new item to the shopping list
    AppShopping shoppingList = BoxManager().shoppingBox.getAt(0)!;
    shoppingList.items.add(item);
    await shoppingList.save(); // Save the updated shopping list to Hive
    debugPrint("Item added to shopping list: ${item.type}");
  }

  Future<void> removeShoppingItem({required AppItem item}) async {
    // Remove an item from the shopping list
    AppShopping shoppingList = BoxManager().shoppingBox.getAt(0)!;
    shoppingList.items.remove(item);
    await shoppingList.save(); // Save the updated shopping list to Hive
  }

  Future<void> clearShoppingList() async {
    // Clear the shopping list
    AppShopping shoppingList = BoxManager().shoppingBox.getAt(0)!;
    shoppingList.items.clear();
    await shoppingList.save(); // Save the cleared shopping list to Hive
  }

  Future<List<AppItem>> getShoppingList() async {
    // Retrieve the shopping list
    AppShopping shoppingList = BoxManager().shoppingBox.getAt(0)!;
    return shoppingList.items; // Return the list of items in the shopping list
  }
}
