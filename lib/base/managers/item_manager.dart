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

  Future<void> addCustomItem({
    String? brandName,
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
  }) async {
    try {
      // Set default values if null/empty
      brandName =
          brandName?.trim().isEmpty ?? true ? "No Brand Provided" : brandName!;

      description = description?.trim().isEmpty ?? true
          ? "No Description Provided"
          : description!;

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
      );

      // Add to Hive box (assuming BoxManager().itemBox is a Hive Box)
      await BoxManager().itemBox.add(customItem);

      if (kDebugMode) {
        print("Custom item added: ${customItem.toString()}");
        print(BoxManager().itemBox.values.toList());
      }
    } catch (e) {
      if (kDebugMode) {
        print("Failed to add item: $e");
      }
      rethrow; // Optional: Re-throw if you want calling code to handle errors
    }
  }

  Future<void> editItem(
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

      // Save changes (assuming Hive or similar key-value store)
      await BoxManager().itemBox.put(item.key, item);

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

  void addMiscItem() async {
    AppItem miscItem = AppItem();
    BoxManager().itemBox.add(miscItem);
  }

  Future<bool> removeItem(AppItem item) async {
    try {
      if (item.key == null) {
        if (kDebugMode) {
          print("Cannot remove item: Key is null");
        }
        return false;
      }

      await BoxManager().itemBox.delete(item.key!);

      if (kDebugMode) {
        print("Item removed: ${item.toString()}");
      }
      return true; // Success
    } catch (e) {
      if (kDebugMode) {
        print("Error removing item '${item.brandName}': $e");
      }
      return false; // Failure
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
}
