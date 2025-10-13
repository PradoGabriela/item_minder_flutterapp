import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/group.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/item.dart';
import 'package:item_minder_flutterapp/base/managers/firebase_group_manager.dart';
import 'package:item_minder_flutterapp/base/managers/group_manager.dart';
import 'package:item_minder_flutterapp/base/managers/item_manager.dart';
import 'package:item_minder_flutterapp/device_id.dart';

/**
 * CRITICAL CLASS: Firebase Realtime Database Listeners
 * 
 * This class implements the real-time synchronization layer of the dual-persistence architecture.
 * It handles Firebase → Hive data flow through database listeners.
 * 
 * ARCHITECTURE OVERVIEW:
 * - Firebase serves as the shared source of truth for real-time collaboration
 * - Hive serves as the local offline-first storage
 * - This class bridges the two by listening to Firebase changes and updating Hive
 * 
 * KEY DESIGN PRINCIPLES:
 * 1. CONFLICT RESOLUTION: Uses timestamps to determine which version is newer
 * 2. LOOP PREVENTION: Checks deviceId to avoid infinite update loops
 * 3. EXPLICIT MEMBERSHIP: Only syncs groups that exist locally (user must join first)
 * 4. ERROR ISOLATION: Each operation is wrapped in try-catch to prevent cascading failures
 * 5. SCALABLE LISTENERS: Individual listeners per group for better performance
 */
class FirebaseListeners {
  // Store active listeners to manage cleanup and prevent memory leaks
  final Map<String, StreamSubscription> _activeGroupListeners = {};

  /**
   * MAIN SETUP METHOD: Initializes Firebase listeners for user's groups
   * 
   * OPTIMIZED APPROACH: Creates individual listeners for each group the user is a member of
   * This prevents unnecessary processing of irrelevant group changes from other users
   * 
   * SCALABILITY: Performance doesn't degrade as total groups in database increases
   */
  Future<void> setupFirebaseListeners() async {
    GroupManager().debugTrackAllGroupStatuses('BEFORE_FIREBASE_LISTENER');

    // Clean up any existing listeners before setting up new ones
    await _cleanupAllListeners();

    // Get all groups user is member of from local Hive storage
    final userGroups = GroupManager().getHiveGroups();

    debugPrint(
        '🎯 Setting up Firebase listeners for ${userGroups.length} user groups');

    // Create individual listeners for each group user is member of
    for (final group in userGroups) {
      await _setupGroupSpecificListener(group.groupID);
    }

    GroupManager().debugTrackAllGroupStatuses('AFTER_FIREBASE_LISTENER');

    debugPrint(
        '✅ Firebase listeners setup complete for ${userGroups.length} groups');
  }

  /**
   * OPTIMIZED APPROACH: Individual group listeners
   * Only listens to specific groups the user is actually a member of
   * 
   * This replaces the global groupsRef.onChildChanged/onChildRemoved pattern
   * with targeted listeners that only fire for relevant group changes
   */
  Future<void> _setupGroupSpecificListener(String groupID) async {
    final currentDeviceId = DeviceId().getDeviceId();
    final groupRef = FirebaseDatabase.instance.ref('groups/$groupID');

    debugPrint('🎯 Setting up listener for specific group: $groupID');

    // Listen to changes on this specific group
    final changeListener = groupRef.onValue.listen((event) async {
      try {
        if (!event.snapshot.exists) {
          // GROUP DELETED: Handle deletion of this specific group
          debugPrint('🗑️ Group deleted: $groupID');
          await _handleGroupDeletion(groupID);

          // Remove the listener since group no longer exists
          await _removeGroupListener(groupID);
          return;
        }

        // GROUP UPDATED: Handle updates to this specific group
        final groupData =
            Map<String, dynamic>.from(event.snapshot.value as Map);
        await _handleGroupUpdate(groupID, groupData, currentDeviceId);
      } catch (e) {
        debugPrint('❌ Error in group-specific listener for $groupID: $e');
      }
    });

    // Store listener reference for cleanup
    _activeGroupListeners[groupID] = changeListener;
    debugPrint('📡 Active listener created for group: $groupID');
  }

  /**
   * Handle group deletion - only called for groups user was actually in
   * Replaces the old onChildRemoved global listener with targeted processing
   */
  Future<void> _handleGroupDeletion(String groupID) async {
    try {
      final existingGroup = GroupManager().getGroupByID(groupID);

      if (existingGroup != null) {
        debugPrint('🗑️ Processing deletion of user group: $groupID');

        // Clean up all items associated with this group
        final groupItemsToRemove = existingGroup.itemsID;
        if (groupItemsToRemove.isNotEmpty) {
          await ItemManager().removeItemsByIDs(groupItemsToRemove);
          debugPrint(
              '✅ ${groupItemsToRemove.length} items removed from local storage');
        }

        // Remove the group from local storage
        await GroupManager().removeGroupFromHiveBox(groupID);
        debugPrint('✅ Group successfully removed from local storage');

        // Notify Firebase Group Manager
        final firebaseGroupManager = FirebaseGroupManager();
        firebaseGroupManager.deletedGroupDetected(groupID);
      } else {
        debugPrint(
            '⚠️ Group deletion detected but group not found locally: $groupID');
      }
    } catch (e) {
      debugPrint('❌ Error handling group deletion for $groupID: $e');
    }
  }

  /**
   * Handle group updates - consolidated from your existing onChildChanged logic
   * This maintains all your existing functionality but only processes relevant groups
   */
  Future<void> _handleGroupUpdate(String groupID,
      Map<String, dynamic> groupData, String currentDeviceId) async {
    try {
      debugPrint('🔥 FIREBASE LISTENER TRIGGERED for group: $groupID');
      debugPrint('   Last updated by: ${groupData['lastUpdatedBy']}');
      debugPrint('   Current device: $currentDeviceId');
      debugPrint('   Members in Firebase: ${groupData['members']}');

      // LOOP PREVENTION: Skip changes made by this device
      if (groupData['lastUpdatedBy']?.toString() == currentDeviceId) {
        debugPrint(
            '🔄 Skipping group change - updated by current device: $currentDeviceId');
        return;
      }

      final groupManager = GroupManager();
      final existingGroup = groupManager.getGroupByID(groupID);

      debugPrint('   Local group found: ${existingGroup != null}');

      if (existingGroup != null) {
        // MEMBER CHANGE DETECTION: Check if member list actually changed
        final oldMembers = existingGroup.members;
        final newMembers = _extractMembersList(groupData['members']);
        final memberListChanged = !_listsEqual(oldMembers, newMembers);

        // TIMESTAMP-BASED CONFLICT RESOLUTION + MEMBER CHANGE DETECTION
        final shouldUpdateByTimestamp =
            _shouldUpdateGroup(existingGroup, groupData);

        debugPrint('   Member list changed: $memberListChanged');
        debugPrint('   Should update by timestamp: $shouldUpdateByTimestamp');

        if (shouldUpdateByTimestamp || memberListChanged) {
          if (memberListChanged) {
            await _handleMemberChanges(
                groupID, existingGroup, oldMembers, newMembers, groupData);

            // Check if current user was removed from group
            final currentMemberName = existingGroup.memberName;
            final currentMemberStillInGroup =
                newMembers.contains(currentMemberName);
            final membersListEmpty = newMembers.isEmpty;

            if ((!currentMemberStillInGroup && currentMemberName.isNotEmpty) ||
                membersListEmpty) {
              await _handleCurrentUserRemoval(
                  groupID, existingGroup, newMembers, membersListEmpty);

              // Remove listener since user is no longer in group
              await _removeGroupListener(groupID);
              return;
            }
          } else {
            debugPrint('✅ Processing update due to newer timestamp');
          }

          // Check if the Name or Icon have been changed
          if (existingGroup.groupName != groupData['groupName'] ||
              existingGroup.groupIconUrl != groupData['groupIconUrl']) {
            groupData.remove('isOnline'); // Remove isOnline from Firebase data
            GroupManager().editGroupBaseInfoFromFirebase(
                groupID,
                groupData['groupName'],
                groupData['groupIconUrl'],
                groupData['lastUpdatedBy'],
                groupData['lastUpdatedDateString']);
            debugPrint(
                '📝 Group info changed in Firebase: ${groupData['groupName']}');
          }
        } else {
          debugPrint(
              '❌ No updates needed - timestamps equal and no member changes');
        }
      } else {
        // This should rarely happen since we only listen to user's groups
        debugPrint(
            '🔄 Skipping - group not in local storage (listener cleanup needed)');
        await _removeGroupListener(groupID);
      }
    } catch (e) {
      debugPrint('❌ Error in group update handler for $groupID: $e');
    }
  }

  /**
   * Handle member list changes (additions and removals)
   * Extracted from existing logic for better organization
   */
  Future<void> _handleMemberChanges(
      String groupID,
      AppGroup existingGroup,
      List<String> oldMembers,
      List<String> newMembers,
      Map<String, dynamic> groupData) async {
    debugPrint(
        '✅ Processing update due to member list change (overriding timestamp)');

    // Find members that were added (exist in new but not in old)
    final addedMembers =
        newMembers.where((member) => !oldMembers.contains(member)).toList();

    // Find members that were removed (exist in old but not in new)
    final removedMembers =
        oldMembers.where((member) => !newMembers.contains(member)).toList();

    debugPrint('👥 MEMBER LIST CHANGED in group: $groupID');
    debugPrint('   Old members: $oldMembers');
    debugPrint('   New members: $newMembers');
    debugPrint('   Added members: $addedMembers');
    debugPrint('   Removed members: $removedMembers');

    // Handle member additions
    for (String addedMember in addedMembers) {
      await FirebaseGroupManager().addGroupMemberFromFirebase(
          groupID,
          addedMember,
          groupData['lastUpdatedBy'],
          groupData['lastUpdatedDateString']);
      debugPrint('➕ Member added to local group: $addedMember');
    }

    // Handle member removals
    for (String removedMember in removedMembers) {
      await GroupManager().removeGroupMemberFromListener(groupID, removedMember,
          groupData['lastUpdatedBy'], groupData['lastUpdatedDateString']);
      //remove
      debugPrint('➖ Member removed from local group: $removedMember');
    }
  }

  /**
   * Handle current user removal from group
   * Extracted from existing logic for better organization
   */
  Future<void> _handleCurrentUserRemoval(String groupID, AppGroup existingGroup,
      List<String> newMembers, bool membersListEmpty) async {
    if (membersListEmpty) {
      debugPrint('🚨 ALL MEMBERS REMOVED from group: $groupID');
    } else {
      debugPrint('🚨 CURRENT MEMBER REMOVED from group: $groupID');
      debugPrint('   Current member name: ${existingGroup.memberName}');
    }
    debugPrint('   New members list: $newMembers');
    debugPrint(
        '   🗑️ Deleting group and associated items from local storage...');

    try {
      // Step 1: Clean up all items associated with this group
      final groupItemsToRemove = existingGroup.itemsID;
      if (groupItemsToRemove.isNotEmpty) {
        await ItemManager().removeItemsByIDs(groupItemsToRemove);
        debugPrint(
            '✅ ${groupItemsToRemove.length} items removed from local storage');
      }

      // Step 2: Remove the group from local Hive storage
      await GroupManager().removeGroupFromHiveBox(groupID);
      debugPrint('✅ Group successfully removed from local storage');

      // Optional: Trigger UI notification about removal
      // NotificationManager().showMemberRemovedNotification(existingGroup.groupName);
    } catch (e) {
      debugPrint('❌ Error removing group and items from local storage: $e');
    }
  }

  /**
   * Add a new group listener when user joins a group
   * Call this from GroupManager.joinGroup() method
   */
  Future<void> addGroupListener(String groupID) async {
    if (!_activeGroupListeners.containsKey(groupID)) {
      await _setupGroupSpecificListener(groupID);
      debugPrint('✅ Added listener for new group: $groupID');
    } else {
      debugPrint('⚠️ Listener already exists for group: $groupID');
    }
  }

  /**
   * Remove group listener when user leaves a group
   * Call this from GroupManager.leaveGroup() or similar methods
   */
  Future<void> _removeGroupListener(String groupID) async {
    final listener = _activeGroupListeners[groupID];
    if (listener != null) {
      await listener.cancel();
      _activeGroupListeners.remove(groupID);
      debugPrint('🧹 Removed listener for group: $groupID');
    }
  }

  /**
   * Public method to remove group listener (for external calls)
   */
  Future<void> removeGroupListener(String groupID) async {
    await _removeGroupListener(groupID);
  }

  /**
   * Clean up all active listeners
   * Call this when user logs out or app is disposed
   */
  Future<void> _cleanupAllListeners() async {
    final listenerCount = _activeGroupListeners.length;

    for (final listener in _activeGroupListeners.values) {
      await listener.cancel();
    }
    _activeGroupListeners.clear();

    if (listenerCount > 0) {
      debugPrint('🧹 Cleaned up $listenerCount Firebase listeners');
    }
  }

  /**
   * Public method for cleanup (call when user leaves app)
   */
  Future<void> dispose() async {
    await _cleanupAllListeners();
    debugPrint('🧹 Firebase listeners disposed');
  }

  // ============================================================================
  // HELPER METHODS (unchanged from your existing implementation)
  // ============================================================================

  /**
   * HELPER METHOD: Synchronizes all items from a Firebase group to local storage
   */
  Future<void> _syncGroupItems(DatabaseReference groupsRef,
      Map<String, dynamic> groupData, String groupKey) async {
    try {
      if (groupData['itemsID'] != null) {
        List<String> itemIDs = [];

        if (groupData['itemsID'] is Map) {
          itemIDs = (groupData['itemsID'] as Map)
              .keys
              .map((key) => key.toString())
              .toList();
        } else if (groupData['itemsID'] is List) {
          itemIDs = List<String>.from(groupData['itemsID']);
        }

        debugPrint('🔄 Syncing ${itemIDs.length} items for group: $groupKey');

        for (var itemID in itemIDs) {
          try {
            final itemSnapshot = await groupsRef
                .child(groupData['groupID'].toString())
                .child("itemsID")
                .child(itemID.toString())
                .once();

            if (itemSnapshot.snapshot.value != null) {
              final itemData =
                  Map<String, dynamic>.from(itemSnapshot.snapshot.value as Map);

              final existingItem = ItemManager().findItemByID(itemID);

              if (existingItem == null) {
                final item = AppItem.fromJson(itemData);
                await ItemManager().addItemFromFirebase(item);
                debugPrint(
                    '🆕 Item synced from Firebase: $itemID (${item.type})');
              } else {
                final firebaseItem = AppItem.fromJson(itemData);
                if (ItemManager()
                    .shouldUpdateItem(existingItem, firebaseItem)) {
                  await ItemManager()
                      .editItemFromFirebase(itemID, firebaseItem);
                  debugPrint(
                      '🔄 Item updated from Firebase: $itemID (${firebaseItem.type})');
                }
              }
            } else {
              debugPrint('⚠️ Item data not found in Firebase: $itemID');
            }
          } catch (e) {
            debugPrint('❌ Error syncing item $itemID: $e');
          }
        }

        debugPrint('✅ Completed syncing items for group: $groupKey');
      }
    } catch (e) {
      debugPrint('❌ Error in _syncGroupItems: $e');
    }
  }

  /**
   * HELPER METHOD: Handles complex item synchronization between Firebase and local storage
   */
  Future<void> _handleItemChanges(
      DatabaseReference groupsRef,
      AppGroup existingGroup,
      Map<String, dynamic> groupData,
      String groupKey) async {
    try {
      List<String> newItemIDs = [];
      if (groupData['itemsID'] is Map) {
        newItemIDs = (groupData['itemsID'] as Map)
            .keys
            .map((key) => key.toString())
            .toList();
      } else if (groupData['itemsID'] is List) {
        newItemIDs = List<String>.from(groupData['itemsID'] ?? []);
      }

      final oldItemIDs = existingGroup.itemsID;

      // STEP 1: REMOVE DELETED ITEMS
      for (var itemID in oldItemIDs) {
        if (!newItemIDs.contains(itemID)) {
          final success = await ItemManager().removeItemByID(itemID);
          if (success) {
            debugPrint('🗑️ Item removed from group: $itemID');
          }
        }
      }

      // STEP 2: ADD NEW ITEMS
      for (var itemID in newItemIDs) {
        if (!oldItemIDs.contains(itemID)) {
          try {
            final itemSnapshot = await groupsRef
                .child(groupData['groupID'].toString())
                .child("itemsID")
                .child(itemID.toString())
                .once();

            if (itemSnapshot.snapshot.value != null) {
              final itemData =
                  Map<String, dynamic>.from(itemSnapshot.snapshot.value as Map);
              final item = AppItem.fromJson(itemData);
              await ItemManager().addItemFromFirebase(item);
              debugPrint('🆕 New item added to group: $itemID (${item.type})');
            }
          } catch (e) {
            debugPrint('❌ Error adding new item $itemID: $e');
          }
        }
      }

      // STEP 3: UPDATE MODIFIED ITEMS
      for (var itemID in newItemIDs) {
        if (oldItemIDs.contains(itemID)) {
          try {
            final itemSnapshot = await groupsRef
                .child(groupData['groupID'].toString())
                .child("itemsID")
                .child(itemID.toString())
                .once();

            if (itemSnapshot.snapshot.value != null) {
              final itemData =
                  Map<String, dynamic>.from(itemSnapshot.snapshot.value as Map);
              final localItem = ItemManager().findItemByID(itemID);

              if (localItem != null) {
                final firebaseItem = AppItem.fromJson(itemData);
                if (ItemManager().shouldUpdateItem(localItem, firebaseItem)) {
                  await ItemManager()
                      .editItemFromFirebase(itemID, firebaseItem);
                  debugPrint('🔄 Item updated: $itemID (${firebaseItem.type})');
                }
              }
            }
          } catch (e) {
            debugPrint('❌ Error updating item $itemID: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error in _handleItemChanges: $e');
    }
  }

  /**
   * HELPER METHOD: Determines if a local group should be updated with Firebase data
   */
  bool _shouldUpdateGroup(
      AppGroup existingGroup, Map<String, dynamic> firebaseData) {
    try {
      var compareTo = existingGroup.lastUpdatedDateString
          .toString()
          .substring(0, 19)
          .compareTo(firebaseData['lastUpdatedDateString']
              .toString()
              .substring(0, 19));

      return compareTo < 0; // Local version is older, should update
    } catch (e) {
      debugPrint('❌ Error comparing group timestamps: $e');
      return false; // Fail-safe: don't update if comparison fails
    }
  }

  /**
   * UTILITY METHOD: Compares two lists for equality
   */
  bool _listsEqual<T>(List<T> list1, List<T> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  /**
   * UTILITY METHOD: Safely extracts a List<String> from Firebase data
   */
  List<String> _extractMembersList(dynamic membersData) {
    try {
      if (membersData == null) {
        return <String>[];
      }

      if (membersData is List) {
        return List<String>.from(membersData);
      }

      if (membersData is Map) {
        return membersData.values.map((value) => value.toString()).toList();
      }

      debugPrint(
          '⚠️ Unexpected members data format: ${membersData.runtimeType}');
      return <String>[];
    } catch (e) {
      debugPrint('❌ Error extracting members list: $e');
      return <String>[];
    }
  }
}
