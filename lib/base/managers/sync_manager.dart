import 'package:flutter/foundation.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/item.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/pending_syncs.dart';
import 'package:item_minder_flutterapp/base/managers/box_manager.dart';
import 'package:item_minder_flutterapp/base/managers/firebase_item_manager.dart';

class SyncManager {
  static final SyncManager _instance = SyncManager._internal();

  factory SyncManager() {
    return _instance;
  }

  SyncManager._internal();

  // Add your methods and properties here
  void initSync() {
    final box = BoxManager().pendingSyncsBox;
    if (box.isEmpty) {
      box.add(PendingSyncs()); //default with empty lists
    } else {
      debugPrint(
          'PedingSyncs Lenght: ${box.get(0)?.pendingItems.length} ${box.get(0)?.pendingItems}');
    }
  }

  Future<void> syncPendingItems() async {
    final pendingSyncs = BoxManager().pendingSyncsBox.get(0);
    if (pendingSyncs != null) {
      for (AppItem item in pendingSyncs.pendingItems) {
        if (await FirebaseItemManager().isItemInFirebase(item.key)) {
          // If the item already exists in Firebase, update it
          FirebaseItemManager().updateItemInFirebase(item, item.key).then((_) {
            // Remove the item from the pending list after successful sync
            pendingSyncs.pendingItems.remove(item);
          }).catchError((error) {
            // Handle error if needed
            debugPrint("Error syncing item: $error");
          });
        } else {
          // If the item does not exist in Firebase, add it
          FirebaseItemManager().addItemToFirebase(item.groupID, item).then((_) {
            pendingSyncs.pendingItems.remove(item);
          }).catchError((error) {
            // Handle error if needed
            debugPrint("Error syncing item: $error");
          });
        }
      }
      //deletes items in queu to remove
      if (pendingSyncs.pendingItemsToRemove.isNotEmpty) {
        for (int itemID in pendingSyncs.pendingItemsToRemove) {
          FirebaseItemManager().deleteItemFromFirebase('$itemID');
          pendingSyncs.pendingItemsToRemove.remove(itemID);
        }
      }
      await pendingSyncs.save(); // Save the changes to the box
    }
  }
}
