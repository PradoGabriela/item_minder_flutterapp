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
import 'package:item_minder_flutterapp/base/widgets/invite_members_dialog.dart';
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
                      final groups = box.values.toList();

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

                                //For both creator and members if the group is online invite members
                                if (group.isOnline)
                                  SlidableAction(
                                    onPressed: (context) {
                                      InviteMembersDialog.show(context, group);
                                    },
                                    foregroundColor:
                                        AppStyles().getPrimaryColor(),
                                    icon: FluentSystemIcons
                                        .ic_fluent_person_add_filled,
                                    label: 'Invite',
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
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: AppStyles().getDialogBackgroundColor(),
          title: Row(
            children: [
              Icon(
                FluentSystemIcons.ic_fluent_delete_forever_filled,
                color: Colors.red[600],
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Delete Group ',
                style: AppStyles().dialogTextStyleTitle,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '⚠️ Are you sure you want to delete this group?',
                style: AppStyles().dialogTextStylePrimary,
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      FluentSystemIcons.ic_fluent_warning_filled,
                      size: 16,
                      color: Colors.red[600],
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This will permanently delete all items and data in this group.',
                        style: AppStyles().dialogTextStyleColorfull,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'This action cannot be undone.',
                style: AppStyles().tooltipTextStyle,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: AppStyles().dialogTextStyleCancel,
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles().getPrimaryColor(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                GroupManager().deleteGroup(groupID);
                Navigator.of(context).pop();
              },
              child: Text(
                'Delete 🗑️',
                style: AppStyles().dialogTextStyleAccept,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLeaveConfirmation(BuildContext context, String groupID) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: AppStyles().getDialogBackgroundColor(),
          title: Row(
            children: [
              Icon(
                FluentSystemIcons.ic_fluent_person_leave_filled,
                color: AppStyles().getPrimaryColor(),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Leave Group ',
                style: AppStyles().dialogTextStyleTitle,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('⚠️ Are you sure you want to leave this group?',
                  style: AppStyles().dialogTextStylePrimary),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      FluentSystemIcons.ic_fluent_info_filled,
                      size: 16,
                      color: Colors.orange[600],
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You will lose access to all items and data in this group.',
                        style: AppStyles()
                            .dialogTextStyleColorfull
                            .copyWith(color: Colors.orange[700]),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'You can rejoin if invited again.',
                style: AppStyles().tooltipTextStyle,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: AppStyles().dialogTextStyleCancel,
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles().getPrimaryColor(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                GroupManager().leaveGroup(groupID);
                Navigator.of(context).pop();
              },
              child: Text(
                'Leave 👋',
                style: AppStyles().dialogTextStyleAccept,
              ),
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
