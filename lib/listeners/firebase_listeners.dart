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
 */
class FirebaseListeners {
  /**
   * MAIN SETUP METHOD: Initializes all Firebase realtime listeners
   * 
   * This method sets up two critical listeners for group synchronization:
   * 1. onChildChanged - Handles updates to existing groups (member changes, item updates, etc.)
   * 2. onChildRemoved - Handles group deletions
   * 
   * IMPORTANT: Groups must exist locally before syncing (explicit membership model)
   * New groups are added only through GroupManager.joinGroup() method
   */
  Future<void> setupFirebaseListeners() async {
    // Get current device ID for loop prevention
    final currentDeviceId = DeviceId().getDeviceId();
    final groupsRef = FirebaseDatabase.instance.ref('groups');

    // =====================================================================
    // LISTENER 1: onChildChanged - Handles updates to existing groups
    // =====================================================================
    // CRITICAL: This fires when group properties change (members, name, items, etc.)
    // This is the main listener for detecting when new members join existing groups
    groupsRef.onChildChanged.listen((event) async {
      try {
        final groupData =
            Map<String, dynamic>.from(event.snapshot.value as Map);

        debugPrint(
            '🔥 FIREBASE LISTENER TRIGGERED for group: ${event.snapshot.key}');
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
        final existingGroup = groupManager.getGroupByID(event.snapshot.key!);

        debugPrint('   Local group found: ${existingGroup != null}');
        if (existingGroup != null) {
          debugPrint('   Local members: ${existingGroup.members}');
          debugPrint(
              '   Local lastUpdated: ${existingGroup.lastUpdatedDateString}');
          debugPrint(
              '   Firebase lastUpdated: ${groupData['lastUpdatedDateString']}');
        }

        if (existingGroup != null) {
          // MEMBER CHANGE DETECTION: Check if member list actually changed
          final oldMembers = existingGroup.members;
          final newMembers = _extractMembersList(groupData['members']);
          final memberListChanged = !_listsEqual(oldMembers, newMembers);

          // TIMESTAMP-BASED CONFLICT RESOLUTION + MEMBER CHANGE DETECTION
          // Process update if: Firebase is newer OR member list actually changed
          final shouldUpdateByTimestamp =
              _shouldUpdateGroup(existingGroup, groupData);

          debugPrint('   Member list changed: $memberListChanged');
          debugPrint('   Should update by timestamp: $shouldUpdateByTimestamp');

          if (shouldUpdateByTimestamp || memberListChanged) {
            if (memberListChanged) {
              debugPrint(
                  '✅ Processing update due to member list change (overriding timestamp)');
            } else {
              debugPrint('✅ Processing update due to newer timestamp');
            }

            if (memberListChanged) {
              // MEMBER CHANGE DETECTION: Handle both additions and removals
              // Compare old vs new to determine what changed

              // Find members that were added (exist in new but not in old)
              final addedMembers = newMembers
                  .where((member) => !oldMembers.contains(member))
                  .toList();

              // Find members that were removed (exist in old but not in new)
              final removedMembers = oldMembers
                  .where((member) => !newMembers.contains(member))
                  .toList();

              debugPrint(
                  '👥 MEMBER LIST CHANGED in group: ${event.snapshot.key}');
              debugPrint('   Old members: $oldMembers');
              debugPrint('   New members: $newMembers');
              debugPrint('   Added members: $addedMembers');
              debugPrint('   Removed members: $removedMembers');

              // Handle member additions
              for (String addedMember in addedMembers) {
                await FirebaseGroupManager().addGroupMemberFromFirebase(
                    event.snapshot.key!,
                    addedMember,
                    groupData['lastUpdatedBy'],
                    groupData['lastUpdatedDateString']);
                debugPrint('➕ Member added to local group: $addedMember');
              }

              // Handle member removals
              for (String removedMember in removedMembers) {
                await GroupManager().removeGroupMemberFromListener(
                    event.snapshot.key!,
                    removedMember,
                    groupData['lastUpdatedBy'],
                    groupData['lastUpdatedDateString']);
                debugPrint('➖ Member removed from local group: $removedMember');
              }

              // CRITICAL: Check if current member has been removed from the group
              // If the current user (identified by memberName) is no longer in the members list,
              // they have been kicked out and should delete the group locally
              final currentMemberName = existingGroup.memberName;
              final currentMemberStillInGroup =
                  newMembers.contains(currentMemberName);

              // Also check if the members list is empty (everyone was removed)
              final membersListEmpty = newMembers.isEmpty;

              if ((!currentMemberStillInGroup &&
                      currentMemberName.isNotEmpty) ||
                  membersListEmpty) {
                if (membersListEmpty) {
                  debugPrint(
                      '🚨 ALL MEMBERS REMOVED from group: ${event.snapshot.key}');
                } else {
                  debugPrint(
                      '🚨 CURRENT MEMBER REMOVED from group: ${event.snapshot.key}');
                  debugPrint('   Current member name: $currentMemberName');
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

                  // Step 2: Remove the group from local Hive storage since current user is no longer a member
                  await GroupManager()
                      .removeGroupFromHiveBox(event.snapshot.key!);
                  debugPrint('✅ Group successfully removed from local storage');

                  // Optional: You could trigger a UI notification here to inform the user
                  // that they have been removed from the group
                  // Example: NotificationManager().showMemberRemovedNotification(existingGroup.groupName);
                } catch (e) {
                  debugPrint(
                      '❌ Error removing group and items from local storage: $e');
                }

                return; // Exit early since group has been removed locally
              }

              return;
              // This is where you could trigger UI notifications about member changes
            }

            //Check if the Name or Icon have been changed
            if (existingGroup.groupName != groupData['groupName'] ||
                existingGroup.groupIconUrl != groupData['groupIconUrl']) {
              GroupManager().editGroupBaseInfoFromFirebase(
                  event.snapshot.key!,
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
          // EXPLICIT MEMBERSHIP: Skip groups not in local storage
          // This maintains the security model where users only sync joined groups
          debugPrint('🔄 Skipping - group not in local storage');
        }
      } catch (e) {
        debugPrint('❌ Error in onChildChanged listener: $e');
      }
    });

    // ================================================================
    // LISTENER 2: onChildRemoved - Handles group deletions
    // ================================================================
    // CRITICAL: This fires when a group is deleted from Firebase
    // Must clean up all associated local data to prevent orphaned records
    groupsRef.onChildRemoved.listen((event) async {
      try {
        final groupID = event.snapshot.key;
        if (groupID != null) {
          final firebaseGroupManager = FirebaseGroupManager();
          final groupData =
              Map<String, dynamic>.from(event.snapshot.value as Map);
          firebaseGroupManager.deletedGroupDetected(groupData['groupID']);
          debugPrint('🗑️ Group deleted: $groupID');
        }
      } catch (e) {
        debugPrint('❌ Error in onChildRemoved listener: $e');
      }
    });
  }

  /**
   * HELPER METHOD: Synchronizes all items from a Firebase group to local storage
   * 
   * CRITICAL OPERATION: This method ensures data consistency when:
   * - A new member joins a group (they need all existing items)
   * - Group structure changes (items added/removed)
   * - Conflict resolution requires a full sync
   * 
   * FLEXIBILITY: Handles both Map and List formats for itemsID to support
   * different Firebase data structures
   * 
   * @param groupsRef Firebase reference to groups node
   * @param groupData Group data from Firebase
   * @param groupKey The group ID being synced
   */
  Future<void> _syncGroupItems(DatabaseReference groupsRef,
      Map<String, dynamic> groupData, String groupKey) async {
    try {
      if (groupData['itemsID'] != null) {
        List<String> itemIDs = [];

        // FLEXIBLE DATA HANDLING: Support both Map and List formats
        // Firebase can store arrays as Maps (when sparse) or Lists (when dense)
        if (groupData['itemsID'] is Map) {
          itemIDs = (groupData['itemsID'] as Map)
              .keys
              .map((key) => key.toString())
              .toList();
        } else if (groupData['itemsID'] is List) {
          itemIDs = List<String>.from(groupData['itemsID']);
        }

        debugPrint('🔄 Syncing ${itemIDs.length} items for group: $groupKey');

        // Fetch and add each item from Firebase
        for (var itemID in itemIDs) {
          try {
            // NESTED FIREBASE READ: Items are stored under groups/{groupId}/itemsID/{itemId}
            final itemSnapshot = await groupsRef
                .child(groupData['groupID'].toString())
                .child("itemsID")
                .child(itemID.toString())
                .once();

            if (itemSnapshot.snapshot.value != null) {
              final itemData =
                  Map<String, dynamic>.from(itemSnapshot.snapshot.value as Map);

              // DUPLICATE PREVENTION: Check if item already exists locally by itemID
              final existingItem = ItemManager().findItemByID(itemID);

              if (existingItem == null) {
                // CREATE NEW ITEM: Use AppItem.fromJson to create from Firebase data
                final item = AppItem.fromJson(itemData);

                // ADD TO HIVE BOX: Use ItemManager to properly store the item
                await ItemManager().addItemFromFirebase(item);
                debugPrint(
                    '🆕 Item synced from Firebase: $itemID (${item.type})');
              } else {
                // ITEM EXISTS: Check if Firebase version is newer and update if needed
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
   * 
   * This method performs a sophisticated 3-way comparison:
   * 1. Items to REMOVE (exist locally but not in Firebase)
   * 2. Items to ADD (exist in Firebase but not locally)
   * 3. Items to UPDATE (exist in both but Firebase version is newer)
   * 
   * CRITICAL FOR COLLABORATION: Ensures all group members have consistent item data
   * when items are added, removed, or modified by other users
   * 
   * @param groupsRef Firebase reference to groups node
   * @param existingGroup Local group data from Hive
   * @param groupData Updated group data from Firebase
   * @param groupKey The group ID being processed
   */
  Future<void> _handleItemChanges(
      DatabaseReference groupsRef,
      AppGroup existingGroup,
      Map<String, dynamic> groupData,
      String groupKey) async {
    try {
      // Extract item IDs from Firebase data (flexible format handling)
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
      // Items that exist locally but are no longer in Firebase
      for (var itemID in oldItemIDs) {
        if (!newItemIDs.contains(itemID)) {
          // Use ItemManager to remove the item properly
          final success = await ItemManager().removeItemByID(itemID);
          if (success) {
            debugPrint('🗑️ Item removed from group: $itemID');
          }
        }
      }

      // STEP 2: ADD NEW ITEMS
      // Items that exist in Firebase but not locally
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
      // Items that exist in both but may have changed
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

              // Find local item by itemID using ItemManager
              final localItem = ItemManager().findItemByID(itemID);

              if (localItem != null) {
                // TIMESTAMP-BASED CONFLICT RESOLUTION
                // Compare timestamps to determine which version is newer
                final firebaseItem = AppItem.fromJson(itemData);

                if (ItemManager().shouldUpdateItem(localItem, firebaseItem)) {
                  // Firebase version is newer - update local item
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
   * 
   * CONFLICT RESOLUTION STRATEGY: Uses timestamp comparison to resolve conflicts
   * - Compares lastUpdatedDateString fields (YYYY-MM-DD HH:mm:ss format)
   * - Only updates if Firebase version is newer than local version
   * - Substring(0,19) extracts date/time portion for comparison
   * 
   * CRITICAL: This prevents older changes from overwriting newer ones
   * 
   * @param existingGroup Local group from Hive storage
   * @param firebaseData Group data from Firebase
   * @return true if local group should be updated, false otherwise
   */
  bool _shouldUpdateGroup(
      AppGroup existingGroup, Map<String, dynamic> firebaseData) {
    try {
      // Extract and compare timestamp strings (YYYY-MM-DD HH:mm:ss)
      var compareTo = existingGroup.lastUpdatedDateString
          .toString()
          .substring(0, 19)
          .compareTo(firebaseData['lastUpdatedDateString']
              .toString()
              .substring(0, 19));

      // Returns true if local version is older (negative comparison result)
      return compareTo < 0; // Local version is older, should update
    } catch (e) {
      debugPrint('❌ Error comparing group timestamps: $e');
      return false; // Fail-safe: don't update if comparison fails
    }
  }

  /**
   * UTILITY METHOD: Compares two lists for equality
   * 
   * Used for detecting member list changes in groups.
   * Standard Dart list comparison (==) compares references, not contents.
   * This method compares actual list contents element by element.
   * 
   * CRITICAL FOR MEMBER DETECTION: Enables precise tracking of when
   * users join or leave groups for proper UI updates and notifications
   * 
   * @param list1 First list to compare
   * @param list2 Second list to compare
   * @return true if lists have same contents in same order
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
   * 
   * Firebase can return member lists as either:
   * - List<dynamic> (normal array format)
   * - Map<Object?, Object?> (when array has gaps or specific indices)
   * 
   * This method handles both formats to prevent type casting errors.
   * 
   * @param membersData The raw members data from Firebase (can be List or Map)
   * @return List<String> of member names, empty list if null or invalid format
   */
  List<String> _extractMembersList(dynamic membersData) {
    try {
      if (membersData == null) {
        return <String>[];
      }

      // Handle List format (standard array)
      if (membersData is List) {
        return List<String>.from(membersData);
      }

      // Handle Map format (Firebase sometimes converts arrays to maps)
      if (membersData is Map) {
        // Extract values from the map and convert to List<String>
        return membersData.values.map((value) => value.toString()).toList();
      }

      // Fallback for unexpected formats
      debugPrint(
          '⚠️ Unexpected members data format: ${membersData.runtimeType}');
      return <String>[];
    } catch (e) {
      debugPrint('❌ Error extracting members list: $e');
      return <String>[];
    }
  }
}
