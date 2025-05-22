import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/item.dart';
import 'package:item_minder_flutterapp/base/managers/box_manager.dart';
import 'package:item_minder_flutterapp/base/categories.dart';

class AppCategories {
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
