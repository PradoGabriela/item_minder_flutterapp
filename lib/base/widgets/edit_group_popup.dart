import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/group.dart';
import 'package:item_minder_flutterapp/base/managers/group_manager.dart';
import 'package:item_minder_flutterapp/base/res/media.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';
import 'package:item_minder_flutterapp/base/widgets/invite_members_dialog.dart';

class EditGroupPopup {
  static Future<bool> show(BuildContext context, AppGroup group) async {
    // Show the edit group dialog
    final _groupNameController = TextEditingController(text: group.groupName);
    int _selectedIcon = AppMedia().iconsGroupList.indexOf(group.groupIconUrl);
    if (_selectedIcon == -1)
      _selectedIcon = 0; // Default to first icon if not found
    bool newStatus = group.isOnline;
    bool success = false;
    List<String> membersToDelete = [];

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool isLoading = false;

            return MediaQuery.removeViewInsets(
              removeBottom: true,
              context: context,
              child: Dialog(
                backgroundColor: AppStyles().getDialogBackgroundColor(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Edit Group",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Select Icon:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      ExpandableCarousel(
                        options: ExpandableCarouselOptions(
                          autoPlay: false,
                          onPageChanged: (index, reason) =>
                              setState(() => _selectedIcon = index),
                        ),
                        items: AppMedia().iconsGroupList.map((i) {
                          return Builder(
                            builder: (BuildContext context) {
                              return Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                                  decoration: BoxDecoration(
                                      color: AppStyles().getPrimaryColor(),
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Image.asset(i,
                                      fit: BoxFit.contain,
                                      width: 100,
                                      height: 100));
                            },
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 20),
                      //Edit Group Name
                      TextField(
                        controller: _groupNameController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            labelText: "Edit Group Name"),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9]')),
                          FilteringTextInputFormatter.deny(RegExp(r'\s')),
                        ],
                        maxLength: 12,
                      ),
                      SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Members:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      //Show currents members in the group as chips
                      Wrap(
                        spacing: 8.0,
                        children: [
                          // Existing member chips
                          ...group.members.map((member) {
                            final isSelected = membersToDelete.contains(member);

                            return FilterChip(
                              label: Text(member == group.createdBy
                                  ? '$member 👑'
                                  //change for delete emoji
                                  : '$member ❌'),
                              selected: isSelected,
                              backgroundColor: Colors.grey[200],
                              selectedColor: Colors.red[200],
                              showCheckmark: false,
                              onSelected: member == group.createdBy
                                  ? null
                                  : (selected) {
                                      setState(() {
                                        if (selected) {
                                          membersToDelete.add(member);
                                          //Change the label text adding trash emoji
                                          member = '$member 🗑️';
                                        } else {
                                          membersToDelete.remove(member);
                                        }
                                      });
                                    },
                            );
                          }),
                        ],
                      ),

                      SizedBox(height: 20),
                      //change group status with switch button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Group Status:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                newStatus ? 'Online' : 'Offline',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: newStatus ? Colors.green : Colors.red,
                                ),
                              ),
                              SizedBox(width: 8),
                              Switch(
                                value: newStatus,
                                onChanged: (value) {
                                  setState(() {
                                    newStatus = value;
                                    if (newStatus) {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text('Confirm'),
                                            content: Text(
                                              '⚠️ Are you sure you want to set the group status to online? 🟢\n\n'
                                              'This means you won\'t be able to use offline mode anymore.',
                                            ),
                                            backgroundColor: AppStyles()
                                                .getDialogBackgroundColor(),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  setState(() {
                                                    value = false;
                                                    newStatus = false;
                                                  });
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  setState(() {
                                                    value = true;
                                                    newStatus = true;
                                                  });
                                                },
                                                child: Text('OK'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                    //if  the new status is false show a dialog for confirmation
                                    if (!newStatus) {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text('Confirm'),
                                            content: Text(
                                              '⚠️ Are you sure you want to set the group status to offline? 📴\n\n'
                                              'This will remove all members 👥 from the group and delete it 🗑️ from the database.',
                                            ),
                                            backgroundColor: AppStyles()
                                                .getDialogBackgroundColor(),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  setState(() {
                                                    value = true;
                                                    newStatus = true;
                                                  });
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  setState(() {
                                                    newStatus = false;
                                                  });
                                                },
                                                child: Text('OK'),
                                              ),
                                            ],
                                          );
                                          //if newStatus is true show a dialog that says the group is going to become an online and the user wont be able to use offline anymore
                                        },
                                      );
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton(
                            style: AppStyles().raisedButtonStyle.copyWith(
                                  minimumSize:
                                      WidgetStateProperty.all(Size(80, 60)),
                                ),
                            child: Icon(
                              FontAwesomeIcons.xmark,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: isLoading
                                ? null
                                : () {
                                    Navigator.pop(context);
                                  },
                          ),
                          ElevatedButton(
                            style: AppStyles().raisedButtonStyle.copyWith(
                                  minimumSize:
                                      WidgetStateProperty.all(Size(80, 60)),
                                ),
                            onPressed: isLoading
                                ? null
                                : () async {
                                    final groupName =
                                        _groupNameController.text.trim();

                                    if (groupName.isEmpty) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Please fill all fields')));
                                      }
                                      return;
                                    }
                                    final bool _oldStatus = group.isOnline;
                                    bool _wasChangedToOnline = false;
                                    setState(() => isLoading = true);
                                    try {
                                      await GroupManager().editGroupBaseInfo(
                                          group.groupID,
                                          groupName,
                                          AppMedia()
                                              .iconsGroupList[_selectedIcon],
                                          membersToDelete,
                                          newStatus);
                                      success = true;
                                      // Store the status change for after dialog closes
                                      _wasChangedToOnline =
                                          newStatus && !_oldStatus;
                                      if (context.mounted) {
                                        setState(() => isLoading = false);
                                        Navigator.pop(context, success);
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        setState(() => isLoading = false);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Error updating group: $e')),
                                        );
                                      }
                                    } finally {
                                      // Show invite prompt AFTER the edit dialog closes
                                      if (_wasChangedToOnline &&
                                          context.mounted) {
                                        await showDialog<bool>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ),
                                              title: Row(
                                                children: [
                                                  Icon(
                                                    FontAwesomeIcons.userPlus,
                                                    color: AppStyles()
                                                        .getPrimaryColor(),
                                                    size: 20,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text('Group is Online! 🟢'),
                                                ],
                                              ),
                                              content: Text(
                                                'Your group is now online and ready for collaboration!\n\n'
                                                'Would you like to invite members to join your group?',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              backgroundColor: AppStyles()
                                                  .getDialogBackgroundColor(),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                  child: Text(
                                                    'Not Now',
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: AppStyles()
                                                        .getPrimaryColor(),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    Navigator.of(context)
                                                        .pop(); // Close edit dialog first
                                                    await InviteMembersDialog
                                                        .show(context, group);
                                                  },
                                                  child: Text(
                                                    'Invite Members ➕',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    }
                                  },
                            child: isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(
                                    FontAwesomeIcons.check,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    return success;
  }
}
