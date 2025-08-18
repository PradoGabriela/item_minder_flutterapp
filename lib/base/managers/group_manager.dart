import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/group.dart';
import 'package:item_minder_flutterapp/base/managers/box_manager.dart';
import 'package:item_minder_flutterapp/base/managers/firebase_group_manager.dart';
import 'package:item_minder_flutterapp/base/managers/shopping_manager.dart';
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
    String memberName,
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
      memberName: memberName,
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

//Remove updated deleted group from hive box
  Future<void> removeGroupFromHiveBox(String groupID) async {
    try {
      // Find the group by ID
      final group = BoxManager().groupBox.values.firstWhere(
            (group) => group.groupID == groupID,
            orElse: () => throw Exception('Group not found'),
          );

      // Remove the group from Hive
      await BoxManager().groupBox.delete(group.key);
      debugPrint('✅ Group removed from Hive: ${group.groupName}');
    } catch (e) {
      debugPrint('❌ Error removing group from Hive: $e');
    }
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

  //joing a group, create and empty group in the hive box them get the info from the firebase
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
        final newGroup = await FirebaseGroupManager().joinGroupFromFirebase(
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
  Future<void> deleteGroup(
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

  //Leave joined Group
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
      String memberName = group.memberName;

      debugPrint('🚪 Starting to leave group: $groupName');
      debugPrint('   Member leaving: $memberName');
      debugPrint('   Group ID: $groupID');

      // IMPORTANT: Update Firebase FIRST, then remove local data
      // This ensures other members get notified before we lose local reference
      await FirebaseGroupManager().removeGroupMemberFromFirebase(groupID,
          memberName, DeviceId().getDeviceId(), DateTime.now().toString());

      debugPrint('✅ Firebase updated - member removed from group');

      // Now remove the group from local Hive storage
      await BoxManager().groupBox.delete(group.key);
      debugPrint('✅ Group removed from local Hive: $groupName');
    } catch (e) {
      debugPrint('❌ Error leaving group: $e');
    }
  }

  //delete member from group
  Future<void> deleteMemberFromGroup(
    String groupID,
    String memberID,
  ) async {
    try {
      // Find the group by ID
      final group = BoxManager().groupBox.values.firstWhere(
            (group) => group.groupID == groupID,
            orElse: () => throw Exception('Group not found'),
          );

      // Remove the member from the group's members list
      final groupToUpdate =
          BoxManager().groupBox.get(group.key); // Get the group from Hive
      if (groupToUpdate != null && groupToUpdate.members.contains(memberID)) {
        groupToUpdate.members.remove(memberID);
        groupToUpdate.lastUpdatedBy = DeviceId().getDeviceId();
        groupToUpdate.lastUpdatedDateString = DateTime.now().toString();
        groupToUpdate.save();
        // Update the group in Firebase
        await FirebaseGroupManager().removeGroupMemberFromFirebase(
            groupID,
            memberID,
            groupToUpdate.lastUpdatedBy,
            groupToUpdate.lastUpdatedDateString);
      }
    } catch (e) {
      debugPrint('❌ Error deleting member from group: $e');
    }
  }

  //Add member to group
  Future<void> addMemberToGroup(
    String groupID,
    String memberID,
    String lastUpdatedBy,
    String lastUpdatedDateString,
  ) async {
    try {
      // Find the group by ID
      final group = BoxManager().groupBox.values.firstWhere(
            (group) => group.groupID == groupID,
            orElse: () => throw Exception('Group not found'),
          );

      // Add the member to the group's members list
      final groupToUpdate =
          BoxManager().groupBox.get(group.key); // Get the group from Hive
      if (groupToUpdate != null && !groupToUpdate.members.contains(memberID)) {
        groupToUpdate.members.add(memberID);
        groupToUpdate.lastUpdatedBy = lastUpdatedBy;
        groupToUpdate.lastUpdatedDateString = lastUpdatedDateString;
        groupToUpdate.save();
      }
    } catch (e) {
      debugPrint('❌ Error adding member to group: $e');
    }
  }

  //Remove GroupMemberFromListener
  Future<void> removeGroupMemberFromListener(
    String groupID,
    String memberID,
    String lastUpdatedBy,
    String lastUpdatedDateString,
  ) async {
    try {
      // Find the group by ID
      final group = BoxManager().groupBox.values.firstWhere(
            (group) => group.groupID == groupID,
            orElse: () => throw Exception('Group not found'),
          );

      // Remove the member from the group's members list
      final groupToUpdate =
          BoxManager().groupBox.get(group.key); // Get the group from Hive
      if (groupToUpdate != null && groupToUpdate.members.contains(memberID)) {
        groupToUpdate.members.remove(memberID);
        groupToUpdate.lastUpdatedBy = lastUpdatedBy;
        groupToUpdate.lastUpdatedDateString = lastUpdatedDateString;
        groupToUpdate.save();
        debugPrint('✅ Member removed from group via listener: $memberID');
      } else {
        debugPrint('⚠️ Member not found in group or group is null: $memberID');
      }
    } catch (e) {
      debugPrint('❌ Error removing member from listener: $e');
    }
  }

  //change group status
  Future<void> updateGroupStatus(
    String groupID,
    bool isOnline,
  ) async {
    try {
      // Find the group by ID
      final group = BoxManager().groupBox.values.firstWhere(
            (group) => group.groupID == groupID,
            orElse: () => throw Exception('Group not found'),
          );

      // Update the group's status
      final groupToUpdate =
          BoxManager().groupBox.get(group.key); // Get the group from Hive
      if (groupToUpdate != null) {
        groupToUpdate.isOnline = isOnline;
        groupToUpdate.lastUpdatedBy = DeviceId().getDeviceId();
        groupToUpdate.lastUpdatedDateString = DateTime.now().toString();
        groupToUpdate.save();
        // Update the group in Firebase
        await FirebaseGroupManager().updateGroupStatusInFirebase(
          group,
          isOnline,
        );
      }
    } catch (e) {
      debugPrint('❌ Error updating group status: $e');
    }
  }

  //UpdateGroupName
  Future<void> updateGroupName(
    String passGroupID,
    String newGroupName,
  ) async {
    try {
      // Find the group by ID
      final group = BoxManager().groupBox.values.firstWhere(
            (group) => group.groupID == passGroupID,
            orElse: () => throw Exception('Group not found'),
          );

      // Update the group's name
      final groupToUpdate =
          BoxManager().groupBox.get(group.key); // Get the group from Hive
      if (groupToUpdate != null) {
        groupToUpdate.groupName = newGroupName;
        groupToUpdate.lastUpdatedBy = DeviceId().getDeviceId();
        groupToUpdate.lastUpdatedDateString = DateTime.now().toString();
        groupToUpdate.save();
        // Update the group in Firebase
        await FirebaseGroupManager().updateGroupNameInFirebase(
          groupToUpdate,
          newGroupName,
        );
      }
    } catch (e) {
      debugPrint('❌ Error updating group name: $e');
    }
  }

  //Update group img in hivebox and firebase
  Future<void> updateGroupIconUrl(
      String groupID, String newGroupIconUrl) async {
    try {
      // Update the group icon URL in Hive
      final group = BoxManager().groupBox.values.firstWhere(
            (group) => group.groupID == groupID,
            orElse: () => throw Exception('Group not found'),
          );
      final groupToUpdate = BoxManager().groupBox.get(group.key);
      if (groupToUpdate != null) {
        groupToUpdate.groupIconUrl = newGroupIconUrl;
        groupToUpdate.lastUpdatedBy = DeviceId().getDeviceId();
        groupToUpdate.lastUpdatedDateString = DateTime.now().toString();
        groupToUpdate.save();
      }

      // Update the group icon URL in Firebase
      await FirebaseGroupManager().updateGroupIconUrlInFirebase(
        groupToUpdate!,
        newGroupIconUrl,
      );
    } catch (e) {
      debugPrint('❌ Error updating group icon URL: $e');
    }
  }

  //Edit Base information Group, edit group imgURL, name, members and status
  Future<void> editGroupBaseInfo(
    String groupID,
    String groupName,
    String groupIconUrl,
    List<String> membersToDelete,
    bool isOnline,
  ) async {
    try {
      // Find the group by ID
      final group = BoxManager().groupBox.values.firstWhere(
            (group) => group.groupID == groupID,
            orElse: () => throw Exception('Group not found'),
          );

      // Update the group's base information
      final groupToUpdate =
          BoxManager().groupBox.get(group.key); // Get the group from Hive
      if (groupToUpdate != null) {
        // Check if the group icon URL has changed
        if (groupToUpdate.groupIconUrl != groupIconUrl) {
          updateGroupIconUrl(groupID, groupIconUrl);
        }

        //Check if the groups members has changed
        if (membersToDelete.isNotEmpty) {
          for (var member in membersToDelete) {
            deleteMemberFromGroup(groupID, member);
          }
        }
        //Check if the group state have changed
        if (groupToUpdate.isOnline != isOnline) {
          updateGroupStatus(groupID, isOnline);
        }
        // Check if the group name has changed
        if (groupToUpdate.groupName != groupName) {
          updateGroupName(groupID, groupName);
        }
      }
    } catch (e) {
      debugPrint('❌ Error editing group base info: $e');
    }
  }

  //Edit group base info from firebase
  Future<void> editGroupBaseInfoFromFirebase(
    String groupID,
    String newGroupName,
    String newGroupIconUrl,
    String lastUpdatedBy,
    String lastUpdatedDateString,
  ) async {
    try {
      // Find the group by ID
      final group = BoxManager().groupBox.values.firstWhere(
            (group) => group.groupID == groupID,
            orElse: () => throw Exception('Group not found'),
          );

      // Update the group's base information
      final groupToUpdate =
          BoxManager().groupBox.get(group.key); // Get the group from Hive
      if (groupToUpdate != null) {
        // Check if the group icon URL has changed
        if (groupToUpdate.groupIconUrl != newGroupIconUrl) {
          groupToUpdate.groupIconUrl = newGroupIconUrl;
          debugPrint('✅ Group icon URL updated: ${groupToUpdate.groupIconUrl}');
        }
        // Check if the group name has changed
        if (groupToUpdate.groupName != newGroupName) {
          groupToUpdate.groupName = newGroupName;
          debugPrint('✅ Group name updated: ${groupToUpdate.groupName}');
        }
        groupToUpdate.lastUpdatedBy = lastUpdatedBy;
        groupToUpdate.lastUpdatedDateString = lastUpdatedDateString;
        groupToUpdate.save();
      }
    } catch (e) {
      debugPrint('❌ Error editing group base info: $e');
    }
  }
}
