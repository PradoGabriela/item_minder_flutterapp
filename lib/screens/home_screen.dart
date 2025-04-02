import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';
import 'package:item_minder_flutterapp/base/widgets/categories_widget.dart';
import 'package:item_minder_flutterapp/base/widgets/logo_title.dart';
import 'package:item_minder_flutterapp/base/widgets/search_bar.dart';
import 'package:item_minder_flutterapp/base/widgets/title_text.dart';
import 'package:item_minder_flutterapp/screens/notifications_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //Change this listview for static content
      body: ListView(
        physics: NeverScrollableScrollPhysics(),
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NotificationScreen()),
                      );
                    },
                    icon: const Icon(Icons.notifications_on),
                    color: AppStyles().getPrimaryColor(),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.menu),
                    color: AppStyles().getPrimaryColor(),
                  )
                ],
              ),
              AppLogoTitle(), //Logo widget place Size 140x140 pixels, remember to fix pubspec.yaml to allow images
              AppTitleText(), //Logo widget text place Size 40x340 pixels, remember to fix pubspec.yaml to allow images
            ],
          ),
          SizedBox(height: 12),
          AppSearchBar(), //Search bar configuration
          SizedBox(height: 12),
          CategoriesWidget()
        ],
      ),
    );
  }
}
