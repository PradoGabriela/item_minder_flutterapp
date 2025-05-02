import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/group.dart';
import 'package:item_minder_flutterapp/base/managers/box_manager.dart';
import 'package:item_minder_flutterapp/base/managers/firebase_group_manager.dart';
import 'package:item_minder_flutterapp/device_id.dart';
import 'package:item_minder_flutterapp/services/connectivity_service.dart';
import 'package:random_string/random_string.dart';

class GroupManager {
  // Singleton instance
  static final GroupManager _instance = GroupManager._internal();

  // Private constructor
  GroupManager._internal();

  // Factory constructor to return the singleton instance
  factory GroupManager() {
    return _instance;
  }

  List<AppGroup> getHiveGroups() {
    return BoxManager().groupBox.values.toList();
  }

  //create a new group
  Future<void> createGroup(
    String groupName,
    String createdBy,
    String groupIconUrl,
    List<String> categoriesNames,
  ) async {
    debugPrint('✅ Starting to create');
    String newID = await createGroupID();
    var newGroup = AppGroup(
      groupID: newID,
      groupName: groupName,
      createdBy: createdBy,
      members: [createdBy],
      groupIconUrl: groupIconUrl,
      itemsID: [],
      notificationsID: [],
      pendingSyncsID: [],
      shoppingListID: [],
      categoriesNames: categoriesNames,
      lastUpdatedBy: DeviceId().getDeviceId(),
      lastUpdatedDateString: DateTime.now().toString(),
      createdByDeviceId: DeviceId().getDeviceId(),
    );
    debugPrint(newGroup.groupID);
    await BoxManager().groupBox.add(newGroup);
    //SAVE HIVEBOX

    // Add the new group to Firebase
    await FirebaseGroupManager().addGroupToFirebase(newGroup);
    debugPrint(
        '✅ Group created: ${newGroup.groupName} (ID: ${newGroup.groupID})');
  }

  Future<String> createGroupID() async {
    debugPrint("starting to create an id");
    // the user needs connection to create a group
    if (!await ConnectivityService().isOnline) {
      debugPrint('❌ No internet connection. Cannot create group ID.');
      // Return feedback to the user
      // TODO: Use a snackbar or dialog to inform the user
      return 'no id'; // Return a special string if offline
    }

    String id;
    bool exists;

    do {
      id = randomAlphaNumeric(6);
      // Check if the ID exists locally
      bool existsLocally =
          BoxManager().groupBox.values.any((group) => group.groupID == id);

      // Check if the ID exists in Firebase
      final event = await FirebaseDatabase.instance.ref('groups/$id').once();

      bool existsInFirebase = event.snapshot.exists;

      exists = existsLocally || existsInFirebase;
    } while (exists);

    debugPrint("new Id $id");
    return id; // Return the unique ID
  }

  //EditGroup
  Future<void> editItemListGroup(passGroup,
      {required AppGroup group, List<int>? itemsID}) async {
    try {
      if (itemsID != null) group.itemsID = itemsID;
      group.lastUpdatedBy = DeviceId().getDeviceId();
      group.lastUpdatedDateString = DateTime.now().toString();
    } catch (e) {
      debugPrint('❌ Error updating group: $e');
    } finally {
      // Save the updated group to Hive
      await BoxManager().groupBox.put(group.key, group);
      // Update the group in Firebase
      await FirebaseGroupManager().updateListInGroupInFirebase(group);
      debugPrint('✅ Group updated: ${group.groupName} (ID: ${group.groupID})');
    }
  }

  //add an item to the group with the groupID
  Future<void> addItemToGroup(
    String groupID,
    int itemID,
  ) async {
    try {
      // Find the group by ID
      final group = BoxManager().groupBox.values.firstWhere(
            (group) => group.groupID == groupID,
            orElse: () => throw Exception('Group not found'),
          );
      // Add the item ID to the group's itemsID list
      group.itemsID.add(itemID);
      group.lastUpdatedBy = DeviceId().getDeviceId();
      group.lastUpdatedDateString = DateTime.now().toString();

      // Update the group in Firebase
      await FirebaseGroupManager().updateListInGroupInFirebase(group);
    } catch (e) {
      debugPrint('❌ Error adding item to group: $e');
    }
  }
}
