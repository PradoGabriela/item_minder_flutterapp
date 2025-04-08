import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:item_minder_flutterapp/base/managers/notification_manager.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';
import 'package:item_minder_flutterapp/screens/notifications_screen.dart';

class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _HomeAppBarState extends State<HomeAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon:
            Icon(FontAwesomeIcons.listUl, color: AppStyles().getPrimaryColor()),
        padding: const EdgeInsets.only(left: 20),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
      actions: [
        IconButton(
          icon: NotificationManager().getNotifications().isEmpty
              ? Icon(
                  FontAwesomeIcons.solidBellSlash,
                  color: AppStyles().getPrimaryColor(),
                )
              : Icon(
                  FontAwesomeIcons.solidBell,
                  color: AppStyles().getPrimaryColor(),
                ),
          padding: const EdgeInsets.only(right: 20),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationScreen()),
            ).then((_) {
              // Refresh widget when returning from NotificationScreen
              setState(() {});
            });
          },
        ),
      ],
    );
  }
}
