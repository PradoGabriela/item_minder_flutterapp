import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/managers/box_manager.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/item.dart';
import 'package:item_minder_flutterapp/base/managers/image_manager.dart';
import 'package:item_minder_flutterapp/base/managers/item_manager.dart';
import 'package:item_minder_flutterapp/base/managers/shopping_manager.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';
import 'package:item_minder_flutterapp/base/widgets/logo_title.dart';
import 'package:item_minder_flutterapp/base/widgets/title_text.dart';

class ProfileScreen extends StatefulWidget {
  final String groupId;
  const ProfileScreen({super.key, required this.groupId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            const AppLogoTitle(), // Logo widget
            const AppTitleText(), // Logo widget text
            const SizedBox(height: 20),
            Text(
              "Profile",
              style: AppStyles().catTitleStyle.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory,
                  color: AppStyles().getPrimaryColor(),
                  size: 40,
                ),
                const SizedBox(width: 10),
                Text(
                  "Total Items: ${ItemManager().getAllAppItems(BoxManager().itemBox).length}",
                  style:
                      AppStyles().catTitleStyle.copyWith(color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory,
                  color: AppStyles().getPrimaryColor(),
                  size: 40,
                ),
                const SizedBox(width: 10),
                FutureBuilder<List<AppItem>>(
                  future: ShoppingManager().getShoppingList(
                      widget.groupId), // Fetch shopping items for the group
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text(
                        "Loading...",
                        style: AppStyles()
                            .catTitleStyle
                            .copyWith(color: Colors.black),
                      );
                    } else if (snapshot.hasError) {
                      return Text(
                        "Error loading items",
                        style: AppStyles()
                            .catTitleStyle
                            .copyWith(color: Colors.black),
                      );
                    } else {
                      return Text(
                        "Total Items in Shopping List : ${snapshot.data?.length ?? 0}",
                        style: AppStyles()
                            .catTitleStyle
                            .copyWith(color: Colors.black),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),
            Text(
              "Settings",
              style: AppStyles().catTitleStyle.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
                style: AppStyles().buttonStyle,
                onPressed: () {
                  BoxManager().clearAllBox();
                },
                child:
                    Text("Clear database", style: AppStyles().buttonTextStyle)),
            const SizedBox(height: 8),
            ElevatedButton(
                style: AppStyles().buttonStyle,
                onPressed: () {
                  ImageManager.instance.clearAllImages(context);
                },
                child: Text("Clear all Pictures",
                    style: AppStyles().buttonTextStyle)),
          ],
        ),
      ),
    );
  }
}
