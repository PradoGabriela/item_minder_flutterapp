import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/group.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/item.dart';
import 'package:item_minder_flutterapp/base/managers/box_manager.dart';
import 'package:item_minder_flutterapp/base/managers/group_manager.dart';
import 'package:item_minder_flutterapp/base/managers/item_manager.dart';
import 'package:item_minder_flutterapp/device_id.dart';

class FirebaseListeners {
  /// This method sets up Firebase listeners to listen for changes in the Firebase database.
  /// It listens for changes in the 'items' node and updates the local Hive box with the new data.
  ///
  /// Future<void> setupFirebaseListeners() async {
//TODO: FIX THE LISTENERS TO WORK WITH THE NEW FIREBASE STRUCTURE
  Future<void> setupFirebaseListeners() async {
    final currentDeviceId =
        await DeviceId().getDeviceId(); // Don't forget await!

    final groupsRef = FirebaseDatabase.instance.ref('groups');

    // Listen for new groups
    groupsRef.onChildAdded.listen((event) async {
      try {
        GroupManager myGroupManager = GroupManager();
        final groupData =
            Map<String, dynamic>.from(event.snapshot.value as Map);
        if (groupData['createdByDeviceId']?.toString() != currentDeviceId) {
          // Check if the group already exists in the local box
          final existingGroup =
              myGroupManager.getGroupByID(event.snapshot.key!);

          if (existingGroup == null) {
            return;
          }

          if (existingGroup != null) {
            var compareTo = existingGroup.lastUpdatedDateString
                .toString()
                .substring(0, 19)
                .compareTo(groupData['lastUpdatedDateString']
                    .toString()
                    .substring(0, 19));
            if (compareTo != 0) {
              //TODO: check if i need this updated here
              // Update the existing group if it was updated by another device
              // Update the existing group in the local box
              myGroupManager.editGroupFromFirebase(
                  event.snapshot.key!, AppGroup.fromJson(groupData));
              debugPrint(
                  '🔄 Group updated in local box(Listener): ${event.snapshot.key}, firebase group last date: ${groupData['lastUpdated']?.toString()} and hive box date ${existingGroup.lastUpdatedDateString}, compareT0 $compareTo');
              return;
            } else {
              // Skip adding if it already exists and was not updated by another device
              debugPrint(
                  'Group already exists in local box and was not updated by another device: ${event.snapshot.key}');
              return;
            }
          }

          // Handle items - CORRECTED APPROACH
          if (groupData['itemsID'] != null) {
            // If itemsID is a Map (key-value pairs)
            if (groupData['itemsID'] is Map) {
              // Get all item IDs (keys of the map)
              final itemIDs = (groupData['itemsID'] as Map).keys.toList();

              for (var itemID in itemIDs) {
                try {
                  final itemSnapshot = await groupsRef
                      .child(groupData['groupID'].toString())
                      .child("itemsID")
                      .child(itemID.toString())
                      .once();

                  if (itemSnapshot.snapshot.value != null) {
                    final itemData = Map<String, dynamic>.from(
                        itemSnapshot.snapshot.value as Map);
                    final item = AppItem.fromJson(itemData);
                    BoxManager().itemBox.add(item);
                    debugPrint(
                        '🆕 New item added to group(Listener): ${event.snapshot.key}, itemID: $itemID');
                  }
                } catch (e) {
                  debugPrint('❌ Error processing item $itemID: $e');
                }
              }
            }
            // If itemsID is a List
            else if (groupData['itemsID'] is List) {
              for (var itemID in groupData['itemsID']) {
                try {
                  final itemSnapshot = await groupsRef
                      .child(groupData['groupID'].toString())
                      .child("itemsID")
                      .child(itemID.toString())
                      .once();

                  if (itemSnapshot.snapshot.value != null) {
                    final itemData = Map<String, dynamic>.from(
                        itemSnapshot.snapshot.value as Map);
                    final item = AppItem.fromJson(itemData);
                    BoxManager().itemBox.add(item);
                    debugPrint(
                        '🆕 New item added to group(Listener): ${event.snapshot.key}, itemID: $itemID');
                  }
                } catch (e) {
                  debugPrint('❌ Error processing item $itemID: $e');
                }
              }
            }
          }
        }
      } catch (e) {
        debugPrint('❌ child_added error: $e');
      }
    });

    //Listen for updated groups
    groupsRef.onChildChanged.listen((event) async {
      try {
        final groupData =
            Map<String, dynamic>.from(event.snapshot.value as Map);
        if (groupData['createdByDeviceId']?.toString() != currentDeviceId) {
          final existingGroup =
              GroupManager().getGroupByID(event.snapshot.key!);

          if (existingGroup != null) {
            var compareTo = existingGroup.lastUpdatedDateString
                .toString()
                .substring(0, 19)
                .compareTo(groupData['lastUpdatedDateString']
                    .toString()
                    .substring(0, 19));

            if (compareTo != 0) {
              // Handle items - check if itemsID structure changed
              final newItemsIDs = groupData['itemsID'] is Map
                  ? (groupData['itemsID'] as Map).keys.toList()
                  : List.from(groupData['itemsID'] ?? []);

              final oldItemsIDs = existingGroup.itemsID;

              // Remove items that are no longer in the group
              for (var itemID in oldItemsIDs) {
                if (!newItemsIDs.contains(itemID.toString())) {
                  await BoxManager().itemBox.delete(itemID);
                  debugPrint(
                      '🗑️ Item deleted from group(updating Group): ${event.snapshot.key}, itemID: $itemID');
                }
              }

              // Add new items to the group
              for (var itemID in newItemsIDs) {
                if (!oldItemsIDs.contains(itemID.toString())) {
                  try {
                    final itemSnapshot = await groupsRef
                        .child(groupData['groupID'].toString())
                        .child("itemsID")
                        .child(itemID.toString())
                        .once();

                    if (itemSnapshot.snapshot.value != null) {
                      final itemData = Map<String, dynamic>.from(
                          itemSnapshot.snapshot.value as Map);
                      final item = AppItem.fromJson(itemData);
                      BoxManager().itemBox.add(item);
                      debugPrint(
                          '🆕 New item added to group(Updating Group): ${event.snapshot.key}, itemID: $itemID');
                    }
                  } catch (e) {
                    debugPrint('❌ Error adding new item $itemID: $e');
                  }
                }
              }

              // Update existing items if they changed
              for (var itemID in newItemsIDs) {
                try {
                  final itemSnapshot = await groupsRef
                      .child(groupData['groupID'].toString())
                      .child("itemsID")
                      .child(itemID.toString())
                      .once();

                  if (itemSnapshot.snapshot.value != null) {
                    final itemData = Map<String, dynamic>.from(
                        itemSnapshot.snapshot.value as Map);
                    final localItem = BoxManager().itemBox.get(itemID);

                    if (localItem != null) {
                      var itemCompareTo = localItem.lastUpdated
                          .toString()
                          .substring(0, 19)
                          .compareTo(itemData['lastUpdated']
                              .toString()
                              .substring(0, 19));

                      if (itemCompareTo != 0) {
                        final itemToUpdate = AppItem.fromJson(itemData);
                        ItemManager()
                            .editItemFromFirebase(itemID, itemToUpdate);
                      }
                    }
                  }
                } catch (e) {
                  debugPrint('❌ Error updating item $itemID: $e');
                }
              }

              // Update the group itself
              GroupManager().editGroupFromFirebase(
                  event.snapshot.key!, AppGroup.fromJson(groupData));
              debugPrint(
                  '🔄 Group updated in local box: ${event.snapshot.key}');
            } else {
              debugPrint(
                  'Group already exists in local box and was not updated by another device: ${event.snapshot.key}');
            }
          }
        }
      } catch (e) {
        debugPrint('❌ child_changed error: $e');
      }
    });

    // Listen for deleted groups
    groupsRef.onChildRemoved.listen((event) async {
      try {
        final groupKey = event.snapshot.key;
        if (groupKey != null) {
          // First get the group from local storage to access its items
          final groupToRemove = GroupManager().getGroupByID(groupKey);

          if (groupToRemove != null) {
            // Remove all items associated with this group
            for (var itemID in groupToRemove.itemsID) {
              try {
                await BoxManager().itemBox.delete(itemID);
                debugPrint('🗑️ Item deleted (via group removal): $itemID');
              } catch (e) {
                debugPrint('❌ Error deleting item $itemID: $e');
              }
            }

            // Then remove the group itself
            await BoxManager().groupBox.delete(int.parse(groupKey));
            debugPrint(
                '🗑️ Group deleted: $groupKey with ${groupToRemove.itemsID.length} items');
          } else {
            debugPrint('ℹ️ Group not found in local storage: $groupKey');
          }
        }
      } catch (e) {
        debugPrint('❌ child_removed error: $e');
        // Consider adding error reporting here
      }
    });

    /*    // Listen for NEW items
    itemsRef.onChildAdded.listen((event) async {
      try {
        final itemData = Map<String, dynamic>.from(event.snapshot.value as Map);
        if (itemData['lastUpdatedBy']?.toString() != currentDeviceId) {
          // Check if the item already exists in the local box
          final existingItem =
              BoxManager().itemBox.get(int.parse(event.snapshot.key!));
          if (existingItem != null) {
            var compareTo = existingItem.lastUpdated
                .toString()
                .substring(0, 19)
                .compareTo(itemData['lastUpdated'].toString().substring(0, 19));
            if (compareTo != 0) {
              // Update the existing item if it was updated by another device
              ItemManager().editItemFromFirebase(
                  int.parse(event.snapshot.key!), AppItem.fromJson(itemData));
              debugPrint(
                  '🔄 Item updated in local box: ${event.snapshot.key}, firebase item last date: ${itemData['lastUpdated']?.toString()} and hive box date ${existingItem.lastUpdated}, compareT0 $compareTo');
              return;
            } else {
              // Skip adding if it already exists and was not updated by another device
              debugPrint(
                  'Item already exists in local box and was not updated: ${event.snapshot.key}');
              return;
            }
          }
          final item = AppItem.fromJson(itemData);
          BoxManager().itemBox.add(item); // Use Firebase push ID as key
          debugPrint('🆕 New item added: ${event.snapshot.key}');
        }
      } catch (e) {
        debugPrint('❌ child_added error: $e');
      }
    }); */

/*     // Listen for UPDATED items
    itemsRef.onChildChanged.listen((event) async {
      try {
        final itemData = Map<String, dynamic>.from(event.snapshot.value as Map);
        if (itemData['lastUpdatedBy']?.toString() != currentDeviceId) {
          final item = AppItem.fromJson(itemData);

          ItemManager()
              .editItemFromFirebase(int.parse(event.snapshot.key!), item);
          debugPrint('🔄 Item updated: ${event.snapshot.key}');
        }
      } catch (e) {
        debugPrint('❌ child_changed error: $e');
      }
    });
    //Listen for DELETED items
    itemsRef.onChildRemoved.listen((event) async {
      try {
        final itemKey = event.snapshot.key;
        if (itemKey != null) {
          await BoxManager().itemBox.delete(int.parse(itemKey));
          debugPrint('🗑️ Item deleted: $itemKey');
        }
      } catch (e) {
        debugPrint('❌ child_removed error: $e');
      }
    });*/
  }
}
