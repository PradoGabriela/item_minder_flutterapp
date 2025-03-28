import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/res/media.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';
import 'package:item_minder_flutterapp/base/widgets/logo_title.dart';
import 'package:item_minder_flutterapp/base/widgets/search_bar.dart';
import 'package:item_minder_flutterapp/base/widgets/title_text.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Change this listview for static content
      body: ListView(
        children: [
          const Column(
            children: [
              AppLogoTitle(), //Logo widget place Size 140x140 pixels, remember to fix pubspec.yaml to allow images
              AppTitleText(), //Logo widget text place Size 40x340 pixels, remember to fix pubspec.yaml to allow images
            ],
          ),
          const SizedBox(height: 12),
          const AppSearchBar(), //Search bar configuration
          Column(
            children: [
              Container(
                height: 30,
                color: Colors.yellow,
                child: const Text("Categories"),
              ),
              Container(
                width: 200,
                height: 500,
                color: Colors.orange,
                //Scrollable list of items on vertical
                child: const Text("Scroll view of categories"),
              ),
            ],
            //Scrollable categories on horizontal
          ),
        ],
      ),
    );
  }
}
