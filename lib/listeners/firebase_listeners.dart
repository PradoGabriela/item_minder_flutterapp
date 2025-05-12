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
                  '🔄 Group updated in local box: ${event.snapshot.key}, firebase group last date: ${groupData['lastUpdated']?.toString()} and hive box date ${existingGroup.lastUpdatedDateString}, compareT0 $compareTo');
              return;
            } else {
              // Skip adding if it already exists and was not updated by another device
              debugPrint(
                  'Group already exists in local box and was not updated by another device: ${event.snapshot.key}');
              return;
            }
          }
          // If the group doesn't exist, add it to the local box and add the items i
          // to the group
          final groupCratedFromFirebase = AppGroup.fromJson(groupData);

          myGroupManager.addGroupFromFirebase(
              groupCratedFromFirebase); // Use Firebase push ID as key
        }
        //after adding the group, add the items to the group
        for (var itemID in groupData['itemsID']) {
          //Create the item from the firebase data and add it to the local box
          final itemSnapshot = await groupsRef
              .child(groupData['groupID'])
              .child("itemsID")
              .child(itemID.toString())
              .once();

          final itemData =
              Map<String, dynamic>.from(itemSnapshot.snapshot.value as Map);
          final item = AppItem.fromJson(itemData);
          BoxManager().itemBox.add(item); // Use Firebase push ID as key
          debugPrint(
              '🆕 New item added to group: ${event.snapshot.key}, itemID: $itemID');
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
          //chekc if the group already exists in the local box
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
              // Update the existing group if it was updated by another device
              //check if the existing group has different itemIDs
              if (existingGroup.itemsID != groupData['itemsID']) {
                // Remove the items that are not in the new group to the local box
                for (var itemID in existingGroup.itemsID) {
                  if (!groupData['itemsID'].contains(itemID)) {
                    await BoxManager().itemBox.delete(itemID);
                    debugPrint(
                        '🗑️ Item deleted from group(updating Group): ${event.snapshot.key}, itemID: $itemID');
                  }
                }
                // Add the new items to the group to the local box
                for (var itemID in groupData['itemsID']) {
                  if (!existingGroup.itemsID.contains(itemID)) {
                    final itemSnapshot = await groupsRef
                        .child(groupData['groupID'])
                        .child("itemsID")
                        .child(itemID.toString())
                        .once();

                    final itemData = Map<String, dynamic>.from(
                        itemSnapshot.snapshot.value as Map);
                    final item = AppItem.fromJson(itemData);
                    BoxManager()
                        .itemBox
                        .add(item); // Use Firebase push ID as key
                    debugPrint(
                        '🆕 New item added to group(Updating Group): ${event.snapshot.key}, itemID: $itemID');
                  }
                }
              }
              //update the item in local box if the lastUpdated variable is different than the one in firebase
              for (var itemID in groupData['itemsID']) {
                final itemSnapshot = await groupsRef
                    .child(groupData['groupID'])
                    .child("itemsID")
                    .child(itemID.toString())
                    .once();

                final itemData = Map<String, dynamic>.from(
                    itemSnapshot.snapshot.value as Map);
                //Check if the lastUpdated variable are not equal for the item
                var compareTo = BoxManager()
                    .itemBox
                    .get(itemID)
                    ?.lastUpdated
                    .toString()
                    .substring(0, 19)
                    .compareTo(
                        itemData['lastUpdated'].toString().substring(0, 19));
                if (compareTo != 0) {
                  final itemToUpdate = AppItem.fromJson(itemData);
                  ItemManager().editItemFromFirebase(
                      itemID, itemToUpdate); // Use Firebase push ID as key
                }
              }

              // Update the existing group in the local box
              GroupManager().editGroupFromFirebase(
                  event.snapshot.key!, AppGroup.fromJson(groupData));
              debugPrint(
                  '🔄 Group updated in local box: ${event.snapshot.key}, firebase group last date: ${groupData['lastUpdated']?.toString()} and hive box date ${existingGroup.lastUpdatedDateString}, compareT0 $compareTo');
              return;
            } else {
              // Skip adding if it already exists and was not updated by another device
              debugPrint(
                  'Group already exists in local box and was not updated by another device: ${event.snapshot.key}');
              return;
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
          await BoxManager().groupBox.delete(int.parse(groupKey));
          debugPrint('🗑️ Group deleted: $groupKey');
        }
      } catch (e) {
        debugPrint('❌ child_removed error: $e');
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
