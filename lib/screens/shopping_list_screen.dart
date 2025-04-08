import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';
import 'package:item_minder_flutterapp/base/widgets/home_app_bar.dart';
import 'package:item_minder_flutterapp/base/widgets/logo_title.dart';
import 'package:item_minder_flutterapp/base/widgets/shopping_widget.dart';
import 'package:item_minder_flutterapp/base/widgets/title_text.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: HomeAppBar(),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Column(
            children: [
              AppLogoTitle(), // Logo widget
              AppTitleText(), // Logo widget text
            ],
          ),

          // Add an Expanded widget to the ShoppingWidget so it gets its space properly
          Expanded(
            child:
                ShoppingWidget(), // This will handle scrolling for your ShoppingWidget
          ),
        ],
      ),
    );
  }
}
