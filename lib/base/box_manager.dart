import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:item_minder_flutterapp/base/item.dart';
import 'package:item_minder_flutterapp/base/item_manager.dart';

class BoxManager {
  Future<void> openBox() async {
    var box =
        await Hive.openBox<AppItem>('appItemBox'); // Open a box for AppItem
    var itemManager =
        ItemManager(); //  get the singelton instance of ItemManager
    itemManager.addItem(box);
    itemManager.updateItemList(box); // Update the item list in ItemManager
    if (kDebugMode) {
      print(itemManager.getAllAppItems(box));
    }
  }

  Box<AppItem> get itemBox {
    return Hive.box('appItemBox');
  }

  void clearAllBox() {
    itemBox.clear();
    if (kDebugMode) {
      print("Clearing Database");
    }
  }
}
