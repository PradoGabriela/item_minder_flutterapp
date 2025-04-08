import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:item_minder_flutterapp/base/item.dart';
import 'package:item_minder_flutterapp/base/notification.dart';
import 'package:item_minder_flutterapp/base/shopping.dart';

class BoxManager {
  Future<void> openBoxes() async {
    var _itemBox =
        await Hive.openBox<AppItem>('appItemBox'); // Open a box for AppItem
    var _notificationBox = await Hive.openBox<AppNotification>(
        'appNotificationBox'); // Open a box for AppItem

    var _shoppingBox = await Hive.openBox<AppShopping>(
        'appShoppingBox'); // Open a box for AppItem
  }

  Box<AppItem> get itemBox {
    return Hive.box('appItemBox');
  }

  Box<AppNotification> get notificationBox {
    return Hive.box('appNotificationBox');
  }

  Box<AppShopping> get shoppingBox {
    return Hive.box('appShoppingBox');
  }

  void clearAllBox() {
    itemBox.clear();
    notificationBox.clear();
    shoppingBox.clear();
    if (kDebugMode) {
      print("Clearing Database");
    }
  }
}
