import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:item_minder_flutterapp/base/item.dart';
import 'package:item_minder_flutterapp/base/notification.dart';

class BoxManager {
  Future<void> openBoxes() async {
    var _itemBox =
        await Hive.openBox<AppItem>('appItemBox'); // Open a box for AppItem
    var _notificationBox = await Hive.openBox<AppNotification>(
        'appNotificationBox'); // Open a box for AppItem
  }

  Box<AppItem> get itemBox {
    return Hive.box('appItemBox');
  }

  Box<AppNotification> get notificationBox {
    return Hive.box('appNotificationBox');
  }

  void clearAllBox() {
    itemBox.clear();
    notificationBox.clear();
    if (kDebugMode) {
      print("Clearing Database");
    }
  }
}
