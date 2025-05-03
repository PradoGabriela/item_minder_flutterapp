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

  //update group in firebase
  Future<void> updateListInGroupInFirebase(AppGroup group) async {
    if (await ConnectivityService().isOnline) {
      try {
        await ref.child(group.groupID).update(
          {
            'itemsID': group.itemsID,
            'pendingSyncsID': group.pendingSyncsID,
            'shoppingListID': group.shoppingListID,
            'lastUpdatedBy': group.lastUpdatedBy,
            'lastUpdatedDateString': group.lastUpdatedDateString,
          },
        );
        debugPrint('✅ Group updated in Firebase: ${group.groupName}');
      } catch (e) {
        debugPrint('❌ Firebase Group update failed: $e');
      }
    } else {
      debugPrint('❌ No internet connection. Cannot update group in Firebase.');
    }
  }
}
