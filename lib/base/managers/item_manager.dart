import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:item_minder_flutterapp/base/box_manager.dart';
import 'package:item_minder_flutterapp/base/categories.dart';
import 'package:item_minder_flutterapp/base/item.dart';

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

  void addItem(Box<AppItem> box) async {
    // Add a new AppItem to the list and box
    AppItem newItem = AppItem();
    box.add(newItem); // Add the new item to the Hive box
    if (kDebugMode) {
      print("Item added: ${newItem.toString()}"); // Print the added item
    }
  }

  void addCustomItem(
      String brandName,
      String description,
      String iconUrl,
      String imageUrl,
      String category,
      double price,
      String type,
      int quantity,
      int minQuantity,
      int maxQuantity,
      bool isAutoadd) async {
    // Create a new AppItem with custom values
    // and add it to the list and box
    if (brandName.isEmpty || brandName == null || brandName == "") {
      {
        brandName =
            "No Brand Provided"; // Default brand name is an empty string
      }
      if (description.isEmpty || description == null || description == "") {
        description =
            "No Description Provided"; // Default description is an empty string
      }

      AppItem customItem = AppItem.custom(
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
          isAutoadd);
      // Add a new AppItem to the list and box
      BoxManager().itemBox.add(customItem);
      if (kDebugMode) {
        print(
            "Custom item added: ${customItem.toString()}"); // Print the added item
      }
    }
  }

  void editItem(
      AppItem item,
      String brandName,
      String description,
      String iconUrl,
      String imageUrl,
      String category,
      double price,
      String type,
      int quantity,
      int minQuantity,
      int maxQuantity,
      bool isAutoadd) async {
    // Edit an existing AppItem in the list and box
    item.brandName = brandName;
    item.description = description;
    item.iconUrl = iconUrl;
    item.imageUrl = imageUrl;
    item.category = category;
    item.price = price;
    item.type = type;
    item.quantity = quantity;
    item.minQuantity = minQuantity;
    item.maxQuantity = maxQuantity;
    item.isAutoAdd = isAutoadd;

    // Save the changes to the Hive box
    await BoxManager().itemBox.put(item.key, item);
  }

  void addMiscItem() async {
    AppItem miscItem = AppItem();
    BoxManager().itemBox.add(miscItem);
  }

  void removeItem(AppItem item) {
    //currentItems.remove(item);
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
}
