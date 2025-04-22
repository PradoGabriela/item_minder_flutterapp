import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/widgets/categories_widget.dart';
import 'package:item_minder_flutterapp/base/widgets/home_app_bar.dart';
import 'package:item_minder_flutterapp/base/widgets/logo_title.dart';
import 'package:item_minder_flutterapp/base/widgets/search_bar.dart';
import 'package:item_minder_flutterapp/base/widgets/side_menu.dart';
import 'package:item_minder_flutterapp/base/widgets/title_text.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const HomeAppBar(),
      drawer: const SideMenu(),
      //Change this listview for static content
      body: ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          Column(
            children: [
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
