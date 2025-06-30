import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/group.dart';
import 'package:item_minder_flutterapp/base/managers/box_manager.dart';
import 'package:item_minder_flutterapp/base/managers/firebase_group_manager.dart';
import 'package:item_minder_flutterapp/base/managers/shopping_manager.dart';
import 'package:item_minder_flutterapp/base/managers/snack_manager.dart';
import 'package:item_minder_flutterapp/base/managers/templates_manager.dart';
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
  Future<bool> createGroup(
    String groupName,
    String createdBy,
    String groupIconUrl,
    List<String> categoriesNames,
  ) async {
    debugPrint('✅ Starting to create');
    String newID = await createGroupID();
    //check if categoriesNames is empty, if so, set it to default categories
    if (categoriesNames.isEmpty) {
      categoriesNames = ['Other'];
    }
    var newGroup = AppGroup(
      groupID: newID,
      groupName: groupName,
      createdBy: createdBy,
      members: [createdBy],
      groupIconUrl: groupIconUrl,
      itemsID: [],
      shoppingListID: [],
      categoriesNames: categoriesNames,
      lastUpdatedBy: DeviceId().getDeviceId(),
      lastUpdatedDateString: DateTime.now().toString(),
      createdByDeviceId: DeviceId().getDeviceId(),
      //When creating the group, is goiung to be always offlibe first
      isOnline: false,
    );
    debugPrint(newGroup.groupID);

    // Add the new group to the local box
    await BoxManager().groupBox.add(newGroup);

    // Add the new group to Firebase
    await FirebaseGroupManager().addGroupToFirebase(newGroup);
    debugPrint(
        '✅ Group created: ${newGroup.groupName} (ID: ${newGroup.groupID})');

    //add template items
    TemplatesManager().addTemplateItemsToGroup(
        groupID: newGroup.groupID, categoriesNames: newGroup.categoriesNames);

    //init shopping list for that group
    await ShoppingManager()
        .initShoppingList(newGroup.groupID); // Initialize the shopping list
    return true;
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

  //add an item to the group with the groupID
  Future<void> addItemToGroup(
    String groupID,
    String itemID,
  ) async {
    try {
      // Find the group by ID
      final group = BoxManager().groupBox.values.firstWhere(
            (group) => group.groupID == groupID,
            orElse: () => throw Exception('Group not found'),
          );

      // Add the item ID to the group's itemsID list
      final groupToUpdate =
          BoxManager().groupBox.get(group.key); // Get the group from Hive
      if (groupToUpdate != null && !groupToUpdate.itemsID.contains(itemID)) {
        groupToUpdate.itemsID.add(itemID);
      }
      groupToUpdate?.lastUpdatedBy = DeviceId().getDeviceId();
      groupToUpdate?.lastUpdatedDateString = DateTime.now().toString();
      groupToUpdate?.save();
      // Update the group in Firebase
      //await FirebaseGroupManager().updateListInGroupInFirebase(groupToUpdate!); //todo UPDATE IN ANOTHER FUNCTION
    } catch (e) {
      debugPrint('❌ Error adding item to group: $e');
    }
  }

  //remove an item from the group with the groupID
  Future<void> removeItemFromGroup(
    String groupID,
    String itemID,
  ) async {
    try {
      // Find the group by ID
      final group = BoxManager().groupBox.values.firstWhere(
            (group) => group.groupID == groupID,
            orElse: () => throw Exception('Group not found'),
          );

      // Remove the item ID from the group's itemsID list
      final groupToUpdate =
          BoxManager().groupBox.get(group.key); // Get the group from Hive
      groupToUpdate?.itemsID.remove(itemID);
      groupToUpdate?.lastUpdatedBy = DeviceId().getDeviceId();
      groupToUpdate?.lastUpdatedDateString = DateTime.now().toString();
      groupToUpdate?.save();
      // Update the group in Firebase'
      await FirebaseGroupManager().updateGroupLastUpdated(
          groupID, DeviceId().getDeviceId(), DateTime.now().toString());
    } catch (e) {
      debugPrint('❌ Error removing item from group: $e');
    }
  }

  //get a group by its ID
  AppGroup? getGroupByID(String groupID) {
    try {
      final group = BoxManager().groupBox.values.firstWhere(
            (group) => group.groupID == groupID,
            orElse: () => throw Exception('Group not found'),
          );

      return group;
    } catch (e) {
      debugPrint('❌ Error getting group by ID: $e');
      return null;
    }
  }

  //Add group from firebase
  Future<void> addGroupFromFirebase(
    AppGroup fireGroup,
  ) async {
    // Add the new group to the local box
    await BoxManager().groupBox.add(fireGroup);
  }

  //Edit group from firebase
  Future<void> editGroupFromFirebase(
    String id,
    AppGroup fireGroup,
  ) async {
    final group = getGroupByID(id);
    if (group == null) {
      throw Exception('Group not found');
    }
    AppGroup groupToEdit = BoxManager().groupBox.get(group.key)!;
    groupToEdit.groupName = fireGroup.groupName;
    groupToEdit.members = fireGroup.members;
    groupToEdit.groupIconUrl = fireGroup.groupIconUrl;
    groupToEdit.itemsID = fireGroup.itemsID;
    //here i need to check if the item is in the group, if not i need to add it
    //i hvae to edit the items here

    groupToEdit.shoppingListID = fireGroup.shoppingListID;
    groupToEdit.categoriesNames = fireGroup.categoriesNames;
    groupToEdit.lastUpdatedDateString = fireGroup.lastUpdatedDateString;
    groupToEdit.lastUpdatedBy = fireGroup.lastUpdatedBy;

    groupToEdit.save();
  }

  //joing a group, create and empy group in the hive box them get the info from the firebase
  Future<bool> joinGroup(
    String groupID,
    String userName,
    BuildContext context,
  ) async {
    try {
      // Check if group exists locally
      if (BoxManager().groupBox.values.any((g) => g.groupID == groupID)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Group already exists')));
        }
        return false;
      } else {
        // Join group in Firebase
        final newGroup = await FirebaseGroupManager().joinGroup(
          groupID,
          DeviceId().getDeviceId(),
          userName,
        );

        if (newGroup == null) {
          if (context.mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Failed to join group')));
          }
          return false;
        }

        // Add to local storage
        await BoxManager().groupBox.add(newGroup);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Successfully joined group')));
        }
        return true;
      }
    } catch (e) {
      debugPrint('❌ Error joining group: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error joining group')));
      }
      return false;
    }
  }

  //leave a group, remove the group from the hive box and firebase
  Future<void> leaveGroup(
    String groupID,
  ) async {
    try {
      // Find the group by ID
      final group = BoxManager().groupBox.values.firstWhere(
            (group) => group.groupID == groupID,
            orElse: () => throw Exception('Group not found'),
          );
      String groupName = group.groupName;
      // Remove the group from Hive
      await BoxManager().groupBox.delete(group.key);
      debugPrint('✅ Group removed from Hive: $groupName');

      // Remove the group from Firebase
      await FirebaseGroupManager().deleteGroupFromFirebase(groupID);
    } catch (e) {
      debugPrint('❌ Error leaving group: $e');
    }
  }
}
