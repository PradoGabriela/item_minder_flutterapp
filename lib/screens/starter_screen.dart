import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';
import 'package:item_minder_flutterapp/base/widgets/groups_widget.dart';
import 'package:item_minder_flutterapp/base/widgets/home_app_bar.dart';
import 'package:item_minder_flutterapp/base/widgets/logo_title.dart';
import 'package:item_minder_flutterapp/base/widgets/side_menu.dart';
import 'package:item_minder_flutterapp/base/widgets/title_text.dart';

class StarterScreen extends StatefulWidget {
  const StarterScreen({super.key});

  @override
  State<StarterScreen> createState() => _StarterScreenState();
}

class _StarterScreenState extends State<StarterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const HomeAppBar(),
      drawer: const SideMenu(),
      bottomNavigationBar: BottomAppBar(
          color: AppStyles().getPrimaryColor(),
          child:
              Text("© Copyright 2025 - Gabriela Prado | All Rights Reserved ")),
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(
              bottom: 16.0), // extra padding for safety with bottom bar
          child: Column(
            children: [
              const Column(
                children: [
                  AppLogoTitle(),
                  AppTitleText(),
                ],
              ),
              const SizedBox(height: 14),
              GroupsWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
