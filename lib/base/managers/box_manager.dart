import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/group.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/item.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/notification.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/shopping.dart';

class BoxManager {
  // Singleton pattern to ensure one instance
  static final BoxManager _instance = BoxManager._internal();
  factory BoxManager() => _instance;
  BoxManager._internal();

  Future<void> openBoxes() async {
    var _itemBox = await Hive.openBox<AppItem>('appItemBox');
    var _notificationBox =
        await Hive.openBox<AppNotification>('appNotificationBox');
    var _shoppingBox = await Hive.openBox<AppShopping>('appShoppingBox');
    var _groupBox = await Hive.openBox<AppGroup>('appGroupBox');

    debugPrint('✅ All Hive boxes opened successfully');
  }

  Box<AppItem> get itemBox => Hive.box('appItemBox');
  Box<AppNotification> get notificationBox => Hive.box('appNotificationBox');
  Box<AppShopping> get shoppingBox => Hive.box('appShoppingBox');
  Box<AppGroup> get groupBox => Hive.box('appGroupBox');

  void clearAllBox() {
    itemBox.clear();
    notificationBox.clear();
    shoppingBox.clear();
    groupBox.clear();
    debugPrint('🗑️ All Hive boxes cleared');
  }

  /// Safely close all Hive boxes
  /// Note: Hive auto-saves data, no manual save needed
  Future<void> closeAllBox() async {
    try {
      await itemBox.close();
      await notificationBox.close();
      await shoppingBox.close();
      await groupBox.close();
      debugPrint('✅ All Hive boxes closed safely');
    } catch (e) {
      debugPrint('❌ Error closing Hive boxes: $e');
    }
  }

  /// Graceful shutdown - call this on app termination
  Future<void> dispose() async {
    await closeAllBox();
    debugPrint('📦 BoxManager disposed');
    // ✅ FIXED: Removed recursive dispose() call
  }
}
