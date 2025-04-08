import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:item_minder_flutterapp/base/box_manager.dart';
import 'package:item_minder_flutterapp/base/managers/notification_manager.dart';
import 'package:item_minder_flutterapp/base/notification.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';

class NotificationWidget extends StatefulWidget {
  const NotificationWidget({super.key});

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  List<dynamic> notifications = [];
  void _fetchNotifications() async {
    List<dynamic> tempNotifications =
        NotificationManager().getNotifications().reversed.toList();
    setState(() {
      notifications = tempNotifications;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  String _formatTimeSince(DateTime notificationTime) {
    final Duration difference = DateTime.now().difference(notificationTime);
    if (difference.inDays >= 1) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: notifications.isEmpty
          ? const Center(
              child: Text(
              'No notifications available',
              style: TextStyle(fontSize: 22),
            ))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Column(
                  children: [
                    const SizedBox(height: 10),
                    _buildNotificationTile(notification),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
      backgroundColor: AppStyles().getSecondaryColor(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await NotificationManager().deleteAllNotifications();
          setState(() {
            _fetchNotifications();
          });
        },
        backgroundColor: Colors.white,
        child: Icon(FluentSystemIcons.ic_fluent_delete_filled,
            color: AppStyles().getPrimaryColor()),
      ),
    );
  }

  Widget _buildNotificationTile(dynamic notification) {
    // Customize the notification tile according to your notification data structure
    return Container(
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.grey.shade300 : Colors.white,
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        tileColor: notification.isRead ? Colors.grey.shade300 : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(
            color: Colors.black,
            width: 3,
          ),
        ),
        contentPadding: const EdgeInsets.all(10),
        visualDensity: const VisualDensity(vertical: 4),
        minVerticalPadding: 10,
        minLeadingWidth: 10,
        horizontalTitleGap: 10,
        leading: Icon(
          notification.information.contains("too many")
              ? FontAwesomeIcons.circleExclamation
              : Icons
                  .shopping_cart_checkout, // Use a different icon based on the notification type
          color: AppStyles().getPrimaryColor(),
          size: 38,
        ),
        title: Text(_formatTimeSince(notification.time)),
        subtitle: Text(notification.information ?? 'No message'),
        trailing: IconButton(
            onPressed: () {
              setState(() {
                NotificationManager().deleteNotification(notification);
                _fetchNotifications();
              });
            },
            icon: Icon(FontAwesomeIcons.trashCan,
                color: AppStyles().getPrimaryColor())),
        onTap: () {
          // Handle notification tap
          // For example, navigate to a detailed view or mark as read
          setState(() {
            notification.isRead = !notification.isRead;
            debugPrint("Notification marked as read: ${notification.isRead}");
          });
        },
      ),
    );
  }
}
