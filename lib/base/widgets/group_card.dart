import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';
import 'package:item_minder_flutterapp/base/widgets/bottom_nav_bar.dart';

/// **Interactive group selection card for multi-user collaboration.**
///
/// [GroupCard] represents a **user group** in the group selection interface,
/// providing essential group information and direct navigation to the group's
/// inventory management system. It serves as the primary entry point for
/// users to access their collaborative inventory spaces.
///
/// **Core Features:**
/// * **Group Information Display**: Shows group name, icon, and member list
/// * **Navigation Integration**: Direct tap-to-enter group functionality
/// * **Status Indication**: Online/offline status for group connectivity
/// * **Visual Consistency**: Branded styling with primary color scheme
/// * **Interactive Feedback**: Tap animations and visual response
///
/// **Group Data Display:**
/// * **Group Icon**: Visual identifier for easy recognition
/// * **Group Name**: Primary group identifier
/// * **Member List**: Shows all users with access to the group
/// * **Status Indicator**: Current connectivity status (online/offline)
/// * **Visual Hierarchy**: Clear information organization
///
/// **User Interaction:**
/// * **Tap to Enter**: Navigates to main app interface with group context
/// * **Visual Feedback**: Splash animation on interaction
/// * **State Management**: Updates UI state after navigation returns
///
/// **Design System Integration:**
/// * Uses [AppStyles] primary color for consistent branding
/// * Implements standard card shadow and border radius
/// * Maintains visual consistency across the group selection interface
///
/// **Navigation Behavior:**
/// * Passes group ID to [BottomNavBar] for context-aware navigation
/// * Returns to group selection when user navigates back
/// * Preserves group context throughout the app experience
///
/// {@tool snippet}
/// ```dart
/// // Display a group card in the selection interface
/// GroupCard(
///   groupId: group.groupID,
///   groupName: group.groupName,
///   groupIconUrl: group.groupIconUrl,
///   members: group.members,
///   status: group.isOnline,
/// )
///
/// // Used within ListView for group selection
/// ListView.builder(
///   itemBuilder: (context, index) => GroupCard(
///     groupId: groups[index].groupID,
///     groupName: groups[index].groupName,
///     groupIconUrl: groups[index].groupIconUrl,
///     members: groups[index].members,
///     status: groups[index].isOnline,
///   ),
/// )
/// ```
/// {@end-tool}
class GroupCard extends StatefulWidget {
  /// **Unique group identifier** for navigation and data filtering.
  ///
  /// Used to pass group context to the main app interface and ensure
  /// all subsequent operations are performed within the correct group scope.
  final String groupId;

  /// **Display name** of the group for user identification.
  ///
  /// The human-readable name that helps users identify and distinguish
  /// between different collaborative inventory groups.
  final String groupName;

  /// **Asset path** to the group's visual icon.
  ///
  /// Points to an image asset that provides visual identification for the group,
  /// helping users quickly recognize their groups in the selection interface.
  final String groupIconUrl;

  /// **List of group members** for collaboration transparency.
  ///
  /// Contains the names or identifiers of all users who have access to
  /// this group's inventory, promoting transparency in collaborative spaces.
  final List<String> members;

  /// **Connectivity status** indicator for real-time collaboration.
  ///
  /// Indicates whether the group is currently online and available for
  /// real-time synchronization and collaboration features.
  final bool status;

  /// Creates a [GroupCard] with the specified group information.
  ///
  /// **Parameters:**
  /// * [groupId] - Unique identifier for the group
  /// * [groupName] - Display name for user identification
  /// * [groupIconUrl] - Asset path for the group icon
  /// * [members] - List of group member names
  /// * [status] - Online/offline status for the group
  const GroupCard({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.groupIconUrl,
    required this.members,
    required this.status,
  });

  @override
  State<GroupCard> createState() => _GroupCardState();
}

/// **State management for group card interactions and navigation.**
///
/// Handles user tap interactions, navigation to the main app interface,
/// and state updates for the group selection card.
class _GroupCardState extends State<GroupCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 30),
      decoration: BoxDecoration(
        color: AppStyles().getPrimaryColor(),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(89, 116, 114, 114), // Shadow color adjustment
            offset: Offset(5, 5), // Position the shadow to the right and bottom
            blurRadius: 1, // Control the blur effect
          ),
        ],
      ),
      child: Material(
        clipBehavior: Clip.hardEdge,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              24), // Use the same border radius as the Card
        ),
        child: InkResponse(
          onTap: () {
            HapticFeedback.lightImpact();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    BottomNavBar(currentGroupId: widget.groupId),
              ),
            ).then((result) {
              setState(() {});
            });
          },
          splashColor: Colors.white30, // Customize splash color
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(widget.groupIconUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 4),
                Column(
                  children: [
                    Text(widget.groupName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        )),
                    Text('Members: ${widget.members.join(', ')}'),
                    SizedBox(height: 4),
                    Text(
                      widget.status ? " Online 🟢" : "Offline 🔴",
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
