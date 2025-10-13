import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/group.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';

class InviteMembersDialog {
  static Future<void> show(BuildContext context, AppGroup group) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: AppStyles().getDialogBackgroundColor(),
          title: Row(
            children: [
              Icon(
                FontAwesomeIcons.userPlus,
                color: AppStyles().getPrimaryColor(),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Invite Members',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Share this Group ID with others to invite them:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        group.groupID,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        FontAwesomeIcons.copy,
                        color: AppStyles().getPrimaryColor(),
                        size: 18,
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: group.groupID));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Group ID copied to clipboard! 📋'),
                            backgroundColor: AppStyles().getPrimaryColor(),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Text(
                '💡 Tip: Members can join using this ID in the "Join Group" option.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppStyles().getPrimaryColor(),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}
