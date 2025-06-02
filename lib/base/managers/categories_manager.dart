import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/item.dart';
import 'package:item_minder_flutterapp/base/managers/box_manager.dart';
import 'package:item_minder_flutterapp/base/categories.dart';

class AppCategories {
  Map<Categories, String> categoryEmojis = {
    Categories.bathroom: "🛁",
    Categories.bedroom: "🛏️",
    Categories.kitchen: "🍽️",
    Categories.laundryroom: "🧺",
    Categories.pets: "🐾",
    Categories.livingroom: "🛋️",
    Categories.pantry: "🥫",
    Categories.office: "💼",
    Categories.outdoor: "🌳",
    Categories.storage: "📦",
    Categories.diningroom: "🍴",
    Categories.garage: "🚗",
    Categories.nursery: "🍼",
    Categories.playroom: "🧸",
    Categories.gym: "🏋️",
    Categories.studyroom: "📚",
    Categories.garden: "🌱",
    Categories.carmaintenance: "🔧",
    Categories.kidsschool: "🎒",
    Categories.medicines: "💊",
    Categories.cleaningsupplies: "🧼",
    Categories.other: "📁",
  };

// Convert a string to a Categories enum value
  Categories? categoryFromString(String value) {
    return Categories.values.firstWhere(
      (e) => e.name == value,
      orElse: () => Categories.other,
    );
  }

  final List<Categories> _categoriesDB = Categories.values.toList();
  String textToTrim = "Categories.";

  List<String> get categoriesDB {
    List<String> myCategories = [];
    for (var i = 0; i < _categoriesDB.length; i++) {
      String tempCategory =
          _categoriesDB[i].toString().replaceAll(textToTrim, "");
      myCategories.add(tempCategory);
    }
    return myCategories;
  }

  List<String>? currentGroupCategories(String groupID) {
    var currentGroup = BoxManager()
        .groupBox
        .values
        .firstWhere((group) => group.groupID == groupID);

    List<String>? boxGroupsCategories =
        BoxManager().groupBox.get(currentGroup.key)?.categoriesNames;
    if (boxGroupsCategories == null) {
      debugPrint("No categories in the group box for group ID: $groupID");
      return null; // Return an empty list if no items found
    }

    return boxGroupsCategories;
  }

  List<Categories> get categoriesDBRaw {
    return Categories.values;
  }

  Future<List<dynamic>> getItemsByCategory(
      String groupID, String category) async {
    //Get all the items id from the groupbox
    //check wich group has the currentid in the box group
    //get the items id from the group box
    var currentGroup = BoxManager()
        .groupBox
        .values
        .firstWhere((group) => group.groupID == groupID);

    var boxGroupItemsID = BoxManager().groupBox.get(currentGroup.key)?.itemsID;
    debugPrint("Group ID: $groupID");
    debugPrint("Items ID(${boxGroupItemsID?.length}): $boxGroupItemsID");

    if (boxGroupItemsID == null) {
      debugPrint("No items found in the group box for group ID: $groupID");
      return []; // Return an empty list if no items found
    }
    List<AppItem> itemsTofilter = [];
    for (var i = 0; i < boxGroupItemsID.length; i++) {
      //Find the item key by it id
      final tempItem = BoxManager().itemBox.values.firstWhere((item) {
        return item.itemID == boxGroupItemsID[i];
      });

      AppItem? item = BoxManager().itemBox.get(tempItem.key);
      debugPrint("Item In the box from that group: $item ");

      if (item != null) {
        itemsTofilter.add(item);
        debugPrint(
            "Item found: ${item.type} Category: ${item.category}"); //TODO delete
      } else {
        // Handle the case where the item is not found in the box
        debugPrint("Item with ID ${boxGroupItemsID[i]} not found in item box.");
      }
    }
    List<AppItem> filteredItems = itemsTofilter.where((item) {
      debugPrint("Filtering woth this category: $category");
      return item.category == category;
    }).toList();

    debugPrint(
        "Items found in category $category: ${filteredItems.length}, filtered items: ${filteredItems[1].type}");
    return filteredItems;
  }
}
