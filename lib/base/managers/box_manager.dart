import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/item.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/notification.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/pending_syncs.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/shopping.dart';

class BoxManager {
  Future<void> openBoxes() async {
    var _itemBox =
        await Hive.openBox<AppItem>('appItemBox'); // Open a box for AppItem
    var _notificationBox = await Hive.openBox<AppNotification>(
        'appNotificationBox'); // Open a box for AppItem

    var _shoppingBox = await Hive.openBox<AppShopping>(
        'appShoppingBox'); // Open a box for AppItem

    var _pendingSyncsBox = await Hive.openBox<PendingSyncs>(
        'pendingSyncsBox'); // Open a box for AppItem
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

  Box<PendingSyncs> get pendingSyncsBox {
    return Hive.box('pendingSyncsBox');
  }

  void clearAllBox() {
    itemBox.clear();
    notificationBox.clear();
    shoppingBox.clear();
    pendingSyncsBox.clear();
    if (kDebugMode) {
      print("Clearing Database");
    }
  }

  void closeAllBox() {
    itemBox.close();
    notificationBox.close();
    shoppingBox.close();
    pendingSyncsBox.close();
  }
}
