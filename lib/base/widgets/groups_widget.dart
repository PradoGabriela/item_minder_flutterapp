import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/group.dart';
import 'package:item_minder_flutterapp/base/managers/box_manager.dart';
import 'package:item_minder_flutterapp/base/managers/group_manager.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';
import 'package:item_minder_flutterapp/base/widgets/create_group_popup.dart';
import 'package:item_minder_flutterapp/base/widgets/edit_group_popup.dart';
import 'package:item_minder_flutterapp/base/widgets/group_card.dart';
import 'package:item_minder_flutterapp/base/widgets/join_popup_widget.dart';
import 'package:item_minder_flutterapp/device_id.dart';

class GroupsWidget extends StatefulWidget {
  const GroupsWidget({super.key});

  @override
  State<GroupsWidget> createState() => _GroupsWidgetState();
}

class _GroupsWidgetState extends State<GroupsWidget> {
  String currentDeviceId = DeviceId().getDeviceId();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 380,
          height: 500,
          margin: const EdgeInsetsDirectional.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(89, 116, 114, 114),
                offset: Offset(5, 5),
                blurRadius: 1,
              ),
            ],
          ),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: const BorderSide(color: Colors.black, width: 3),
            ),
            elevation: 0,
            color: Colors.white,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text("Groups",
                    style: AppStyles().catTitleStyle.copyWith(fontSize: 24)),
                const SizedBox(height: 20),
                // ✅ FIXED: Use ValueListenableBuilder for real-time Hive updates
                Expanded(
                  child: ValueListenableBuilder<Box<AppGroup>>(
                    valueListenable: BoxManager().groupBox.listenable(),
                    builder: (context, box, _) {
                      final groups = GroupManager().getHiveGroups();

                      if (groups.isEmpty) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.group_off,
                                size: 80, color: AppStyles().getPrimaryColor()),
                            const SizedBox(height: 10),
                            Text(
                              "No Groups Available",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: AppStyles().getPrimaryColor()),
                            ),
                          ],
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 24, vertical: 14),
                        itemCount: groups.length,
                        itemBuilder: (context, index) {
                          final group = groups[index];

                          return Slidable(
                            key: ValueKey(group.groupID),
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                // Edit action (only for creators)
                                if (group.createdByDeviceId == currentDeviceId)
                                  SlidableAction(
                                    onPressed: (context) {
                                      EditGroupPopup.show(context, group);
                                    },
                                    foregroundColor: Colors.black,
                                    icon:
                                        FluentSystemIcons.ic_fluent_edit_filled,
                                    label: "Edit",
                                  ),

                                // Delete action (only for creators)
                                if (group.createdByDeviceId == currentDeviceId)
                                  SlidableAction(
                                    onPressed: (context) {
                                      _showDeleteConfirmation(
                                          context, group.groupID);
                                    },
                                    foregroundColor: Colors.red,
                                    icon: FluentSystemIcons
                                        .ic_fluent_delete_forever_filled,
                                    label: 'Delete',
                                  ),

                                // Leave action (only for non-creators)
                                if (group.createdByDeviceId != currentDeviceId)
                                  SlidableAction(
                                    onPressed: (context) {
                                      _showLeaveConfirmation(
                                          context, group.groupID);
                                    },
                                    foregroundColor: Colors.red,
                                    icon: FluentSystemIcons
                                        .ic_fluent_person_leave_filled,
                                    label: 'Leave',
                                  ),
                              ],
                            ),
                            child: GroupCard(
                              groupId: group.groupID,
                              groupName: group.groupName,
                              groupIconUrl: group.groupIconUrl,
                              members: group.members,
                              status: group
                                  .isOnline, // ✅ This will now update in real-time
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                rowButtons(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        )
      ],
    );
  }

  // ✅ Extracted confirmation dialogs for cleaner code
  void _showDeleteConfirmation(BuildContext context, String groupID) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this group?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                GroupManager().deleteGroup(groupID);
                Navigator.of(context).pop();
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _showLeaveConfirmation(BuildContext context, String groupID) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Leave"),
          content: const Text("Are you sure you want to leave this group?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                GroupManager().leaveGroup(groupID);
                Navigator.of(context).pop();
              },
              child: const Text("Leave"),
            ),
          ],
        );
      },
    );
  }

  Row rowButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            CreateGroupPopup.show(context: context);
            debugPrint("Creating Group");
          },
          style: AppStyles().raisedButtonStyle,
          child: const Column(
            children: [
              Icon(Icons.add, color: Colors.white, size: 40),
              Text('Create',
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Text(
          'OR',
          style: TextStyle(fontSize: 16, color: AppStyles().getPrimaryColor()),
        ),
        const SizedBox(width: 14),
        ElevatedButton(
          onPressed: () {
            JoinCustomPopup.show(context: context);
          },
          style: AppStyles().raisedButtonStyle,
          child: const Column(
            children: [
              Icon(Icons.person_add_alt_outlined,
                  color: Colors.white, size: 40),
              Text('Join', style: TextStyle(fontSize: 16, color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }
}
