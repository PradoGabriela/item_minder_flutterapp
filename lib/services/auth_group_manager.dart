import 'package:flutter/foundation.dart';
import 'package:item_minder_flutterapp/services/auth_service.dart';
import 'package:item_minder_flutterapp/base/managers/group_manager.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/group.dart';

/// **Authentication-aware group management service.**
///
/// [AuthGroupManager] extends the existing gr    final group = _groupManager.getHiveGroups()
///        .where((g) => g.groupID == groupId)
///        .firstOrNull; management functionality
/// to integrate with Firebase Authentication. It ensures that all group
/// operations are performed with proper user authentication and provides
/// secure user-group associations.
///
/// **Core Responsibilities:**
/// * **User-Group Association**: Link authenticated users to their groups
/// * **Secure Group Access**: Ensure only authorized users can access groups
/// * **User ID Integration**: Use Firebase Auth UIDs for group membership
/// * **Migration Support**: Handle transition from device-based to user-based IDs
///
/// **Integration with Existing System:**
/// * Works alongside existing [GroupManager] and [ItemManager]
/// * Maintains backward compatibility with device-based identification
/// * Enhances security without breaking existing functionality
/// * Provides seamless authentication integration
///
/// **Usage:**
/// ```dart
/// final authGroupManager = AuthGroupManager();
///
/// // Create group with authenticated user
/// await authGroupManager.createGroupAsUser(
///   groupName: "Family Inventory",
///   userName: "John Doe",
/// );
///
/// // Get user's groups
/// final userGroups = await authGroupManager.getUserGroups();
/// ```
class AuthGroupManager {
  // Singleton pattern
  static final AuthGroupManager _instance = AuthGroupManager._internal();
  factory AuthGroupManager() => _instance;
  AuthGroupManager._internal();

  final AuthService _authService = AuthService();
  final GroupManager _groupManager = GroupManager();

  /// **Current authenticated user ID.**
  ///
  /// Returns the Firebase Auth UID of the currently signed-in user.
  /// Returns null if no user is authenticated.
  String? get currentUserId => _authService.userUid;

  /// **Current user display name.**
  ///
  /// Returns the display name of the current user for UI purposes.
  /// Falls back to email prefix if display name is not available.
  String? get currentUserName => _authService.userDisplayName;

  /// **Current user email address.**
  String? get currentUserEmail => _authService.userEmail;

  /// **Check if user is authenticated.**
  bool get isUserAuthenticated => _authService.isSignedIn;

  /// **Create a new group with authenticated user as owner.**
  ///
  /// Creates a group where the authenticated user is automatically set as
  /// the creator and initial member. The user's Firebase Auth UID is used
  /// for secure identification instead of device ID.
  ///
  /// **Parameters:**
  /// * [groupName] - Display name for the group
  /// * [groupIconUrl] - Optional icon URL for the group
  /// * [categoriesNames] - List of available categories for the group
  ///
  /// **Returns:**
  /// * [bool] - true if group was created successfully, false otherwise
  ///
  /// **Throws:**
  /// * [Exception] - If user is not authenticated
  /// * [Exception] - If group creation fails
  Future<bool> createGroupAsUser({
    required String groupName,
    String? groupIconUrl,
    List<String>? categoriesNames,
  }) async {
    if (!isUserAuthenticated) {
      throw Exception('User must be authenticated to create groups');
    }

    final userId = currentUserId!;
    final userName = currentUserName ?? 'User';

    try {
      debugPrint(
          '🏠 Creating group as authenticated user: $userName ($userId)');

      // Use existing group creation logic but with user ID
      return await _groupManager.createGroup(
        groupName,
        userId, // Use Firebase Auth UID instead of device ID
        groupIconUrl ?? '',
        categoriesNames ?? [],
        userName,
      );
    } catch (e) {
      debugPrint('❌ Failed to create group as user: $e');
      rethrow;
    }
  }

  /// **Join an existing group as authenticated user.**
  ///
  /// Allows the current authenticated user to join a group using the group ID.
  /// The user's Firebase Auth UID is added to the group's member list.
  ///
  /// **Parameters:**
  /// * [groupId] - The unique identifier of the group to join
  /// * [context] - Build context for showing user feedback
  ///
  /// **Returns:**
  /// * [bool] - true if successfully joined, false otherwise
  ///
  /// **Throws:**
  /// * [Exception] - If user is not authenticated
  Future<bool> joinGroupAsUser(String groupId, context) async {
    if (!isUserAuthenticated) {
      throw Exception('User must be authenticated to join groups');
    }

    final userId = currentUserId!;
    final userName = currentUserName ?? 'User';

    try {
      debugPrint('🤝 Joining group as authenticated user: $userName ($userId)');

      return await _groupManager.joinGroup(groupId, userId, context);
    } catch (e) {
      debugPrint('❌ Failed to join group as user: $e');
      rethrow;
    }
  }

  /// **Get all groups the current user belongs to.**
  ///
  /// Returns a list of groups where the current authenticated user is a member.
  /// This provides a user-centric view of available groups.
  ///
  /// **Returns:**
  /// * [List<AppGroup>] - List of groups the user belongs to
  ///
  /// **Note:** Returns empty list if user is not authenticated
  List<AppGroup> getUserGroups() {
    if (!isUserAuthenticated) {
      debugPrint('ℹ️ No authenticated user - returning empty group list');
      return [];
    }

    final userId = currentUserId!;

    try {
      // Get all groups from local storage
      final allGroups = _groupManager.getHiveGroups();

      // Filter groups where user is a member
      final userGroups = allGroups.where((group) {
        // Check if user is in members list (supports both new UID and legacy device ID)
        return group.members.contains(userId) || (group.createdBy == userId);
      }).toList();

      debugPrint('👥 Found ${userGroups.length} groups for user: $userId');

      return userGroups;
    } catch (e) {
      debugPrint('❌ Error getting user groups: $e');
      return [];
    }
  }

  /// **Check if current user owns a specific group.**
  ///
  /// Determines if the authenticated user is the creator/owner of the given group.
  /// Group owners have additional privileges like editing group settings.
  ///
  /// **Parameters:**
  /// * [group] - The group to check ownership for
  ///
  /// **Returns:**
  /// * [bool] - true if user owns the group, false otherwise
  bool isUserGroupOwner(AppGroup group) {
    if (!isUserAuthenticated) return false;

    final userId = currentUserId!;
    return group.createdBy == userId;
  }

  /// **Remove current user from a group.**
  ///
  /// Allows the authenticated user to leave a group. If the user is the owner
  /// and the only member, the group will be deleted. Otherwise, ownership
  /// may transfer to another member.
  ///
  /// **Parameters:**
  /// * [groupId] - The ID of the group to leave
  ///
  /// **Throws:**
  /// * [Exception] - If user is not authenticated
  /// * [Exception] - If user is not a member of the group
  Future<void> leaveGroupAsUser(String groupId) async {
    if (!isUserAuthenticated) {
      throw Exception('User must be authenticated to leave groups');
    }

    final userId = currentUserId!;

    try {
      // Find the group
      final group = _groupManager
          .getHiveGroups()
          .where((g) => g.groupID == groupId)
          .firstOrNull;

      if (group == null) {
        throw Exception('Group not found');
      }

      if (!group.members.contains(userId) && group.createdBy != userId) {
        throw Exception('User is not a member of this group');
      }

      debugPrint('👋 User leaving group: $userId from ${group.groupName}');

      // If user is the only member, delete the group
      if (group.members.length == 1 && group.members.contains(userId)) {
        await _groupManager.deleteGroup(groupId);
        debugPrint('🗑️ Group deleted as user was the only member');
      } else {
        // Remove user from group manually since method doesn't exist
        group.members.remove(userId);
        group.lastUpdatedBy = userId;
        group.lastUpdatedDateString = DateTime.now().toString();
        await group.save();
        debugPrint('✅ User removed from group successfully');
      }
    } catch (e) {
      debugPrint('❌ Failed to leave group: $e');
      rethrow;
    }
  }

  /// **Get user information for group operations.**
  ///
  /// Returns current user information formatted for display in group contexts.
  /// Useful for showing current user status in group management UI.
  ///
  /// **Returns:**
  /// * [Map<String, String?>] - User information map
  Map<String, String?> getCurrentUserInfo() {
    return {
      'userId': currentUserId,
      'userName': currentUserName,
      'userEmail': currentUserEmail,
      'isAuthenticated': isUserAuthenticated.toString(),
    };
  }

  /// **Migrate device-based groups to user-based groups.**
  ///
  /// Helps transition existing groups that use device IDs to use Firebase Auth UIDs.
  /// This ensures groups created before authentication can be properly associated
  /// with the authenticated user.
  ///
  /// **Parameters:**
  /// * [deviceId] - The device ID to migrate from
  ///
  /// **Returns:**
  /// * [int] - Number of groups migrated
  ///
  /// **Note:** This is a one-time migration helper for existing users
  Future<int> migrateDeviceGroupsToUser(String deviceId) async {
    if (!isUserAuthenticated) {
      throw Exception('User must be authenticated to migrate groups');
    }

    final userId = currentUserId!;
    int migratedCount = 0;

    try {
      debugPrint('🔄 Migrating groups from device $deviceId to user $userId');

      final allGroups = _groupManager.getHiveGroups();

      for (final group in allGroups) {
        bool needsUpdate = false;

        // Migrate creator
        if (group.createdBy == deviceId) {
          group.createdBy = userId;
          needsUpdate = true;
        }

        // Migrate members list
        if (group.members.contains(deviceId)) {
          group.members.remove(deviceId);
          if (!group.members.contains(userId)) {
            group.members.add(userId);
          }
          needsUpdate = true;
        }

        // Migrate lastUpdatedBy if it matches
        if (group.lastUpdatedBy == deviceId) {
          group.lastUpdatedBy = userId;
          needsUpdate = true;
        }

        if (needsUpdate) {
          await group.save(); // Save to Hive
          migratedCount++;
          debugPrint('✅ Migrated group: ${group.groupName}');
        }
      }

      debugPrint('🎉 Migration completed: $migratedCount groups migrated');
      return migratedCount;
    } catch (e) {
      debugPrint('❌ Migration failed: $e');
      rethrow;
    }
  }

  /// **Validate user access to a group.**
  ///
  /// Checks if the current authenticated user has access to perform operations
  /// on the specified group. Used for security validation in group operations.
  ///
  /// **Parameters:**
  /// * [groupId] - The group ID to validate access for
  ///
  /// **Returns:**
  /// * [bool] - true if user has access, false otherwise
  bool validateUserGroupAccess(String groupId) {
    if (!isUserAuthenticated) return false;

    final userId = currentUserId!;
    final userGroups = getUserGroups();

    return userGroups.any((group) =>
        group.groupID == groupId &&
        (group.members.contains(userId) || group.createdBy == userId));
  }

  /// **Get group role for current user.**
  ///
  /// Determines the user's role within a specific group (owner, member, or none).
  ///
  /// **Parameters:**
  /// * [groupId] - The group ID to check role for
  ///
  /// **Returns:**
  /// * [String] - 'owner', 'member', or 'none'
  String getUserGroupRole(String groupId) {
    if (!isUserAuthenticated) return 'none';

    final group = _groupManager
        .getHiveGroups()
        .where((g) => g.groupID == groupId)
        .firstOrNull;

    if (group == null) return 'none';

    final userId = currentUserId!;

    if (group.createdBy == userId) return 'owner';
    if (group.members.contains(userId)) return 'member';

    return 'none';
  }
}
