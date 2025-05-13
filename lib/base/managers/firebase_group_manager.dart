import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/group.dart';
import 'package:item_minder_flutterapp/services/connectivity_service.dart';

class FirebaseGroupManager {
  static final FirebaseGroupManager _instance =
      FirebaseGroupManager._internal();

  factory FirebaseGroupManager() {
    return _instance;
  }

  FirebaseGroupManager._internal() {
    // Initialization code here
  }
  get firebaseDatabase => FirebaseDatabase.instance;
  get ref => FirebaseDatabase.instance.ref('groups');
  // Add a group to Firebase
  Future<void> addGroupToFirebase(AppGroup group) async {
    try {
      await ref.child(group.groupID).set(
        {
          'groupID': group.groupID,
          'groupName': group.groupName,
          'createdBy': group.createdBy,
          'members': group.members,
          'groupIconUrl': group.groupIconUrl,
          'itemsID': group.itemsID,
          'pendingSyncsID': group.pendingSyncsID,
          'shoppingListID': group.shoppingListID,
          'categoriesNames': group.categoriesNames,
          'lastUpdatedBy': group.lastUpdatedBy,
          'lastUpdatedDateString': group.lastUpdatedDateString,
          'createdByDeviceId': group.createdByDeviceId,
        },
      );
    } catch (e) {
      debugPrint('❌ Firebase Group write failed: $e');
    }
  }

//delete Group
  Future<void> deleteGroupFromFirebase(String groupId) async {
    if (!await ConnectivityService().isOnline) {
      debugPrint(
          '❌ No internet connection. Cannot delete group from Firebase.');
      //TODO: show snackbar or dialog to inform the user
      return;
    }
    // Check if the group exists in Firebase before attempting to delete
    final snapshot = await ref.child(groupId).once();
    if (snapshot.snapshot.value == null) {
      debugPrint('❌ Group not found in Firebase: $groupId');
      return;
    }
    try {
      await ref.child(groupId).remove();
      debugPrint('✅ Group deleted from Firebase: $groupId');
    } catch (e) {
      debugPrint('❌ Firebase Group delete failed: $e');
    }
  }

  //update only lastUpdatedDateString and LastUpdatedBy
  Future<void> updateGroupLastUpdated(String groupId, String lastUpdatedBy,
      String lastUpdatedDateString) async {
    if (await ConnectivityService().isOnline) {
      try {
        await ref.child(groupId).update(
          {
            'lastUpdatedBy': lastUpdatedBy,
            'lastUpdatedDateString': lastUpdatedDateString,
          },
        );
        debugPrint('✅ Group last updated in Firebase: $groupId');
      } catch (e) {
        debugPrint('❌ Firebase Group last updated failed: $e');
      }
    } else {
      debugPrint(
          '❌ No internet connection. Cannot update group last updated in Firebase.');
    }
  }

  //Join a group
  Future<AppGroup?> joinGroup(
    String groupId,
    String deviceId,
    String newMember,
  ) async {
    if (!await ConnectivityService().isOnline) {
      debugPrint('❌ No internet connection');
      return null;
    }

    try {
      final groupFound = await ref.child(groupId).get();
      if (!groupFound.exists) {
        debugPrint('❌ Group not found');
        return null;
      }

      final groupData =
          Map<String, dynamic>.from(groupFound.value as Map<dynamic, dynamic>);

      final members = List<String>.from(groupData['members'] ?? []);
      if (!members.contains(newMember)) {
        members.add(newMember);
      }

      await ref.child(groupId).update({
        'members': members,
        'lastUpdatedBy': deviceId,
        'lastUpdatedDateString': DateTime.now().toString(),
      });

      final updatedGroup = await ref.child(groupId).get();
      final itemsMap =
          updatedGroup.child('itemsID').value as Map<dynamic, dynamic>?;

      final foundItemsID = itemsMap?.keys
              .map((key) => int.tryParse(key.toString()))
              .where((id) => id != null)
              .cast<int>()
              .toList() ??
          [];
      ;
      //create a group object from the data
      final group = AppGroup(
        groupID: updatedGroup.child('groupID').value as String,
        groupName: updatedGroup.child('groupName').value as String,
        createdBy: updatedGroup.child('createdBy').value as String,
        members: List<String>.from(updatedGroup.child('members').value),
        groupIconUrl: updatedGroup.child('groupIconUrl').value as String,
        itemsID: foundItemsID,
        pendingSyncsID:
            (updatedGroup.child('pendingSyncsID').value as List<dynamic>?)
                    ?.map((e) => int.tryParse(e.toString()) ?? 0)
                    .toList() ??
                [],
        shoppingListID:
            (updatedGroup.child('shoppingListID').value as List<dynamic>?)
                    ?.map((e) => int.tryParse(e.toString()) ?? 0)
                    .toList() ??
                [],
        categoriesNames:
            List<String>.from(updatedGroup.child('categoriesNames').value),
        lastUpdatedBy: updatedGroup.child('lastUpdatedBy').value as String,
        lastUpdatedDateString:
            updatedGroup.child('lastUpdatedDateString').value as String,
        createdByDeviceId:
            updatedGroup.child('createdByDeviceId').value as String,
      );

      return group;
    } catch (e) {
      debugPrint('❌ Failed to join group: $e');
      return null;
    }
  }
}
