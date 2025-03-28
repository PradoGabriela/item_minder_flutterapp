import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';

class AppSearchBar extends StatelessWidget {
  const AppSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      margin: const EdgeInsetsDirectional.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppStyles().getPrimaryColor(),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, //Separate the elements horizontally
        children: [
          const Text("Search", style: TextStyle(color: Colors.white)),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(50)),
            ),
            child: Icon(
              FluentSystemIcons.ic_fluent_search_filled,
              color: AppStyles().getPrimaryColor(),
            ),
          ),
        ],
      ),
    );
  }
}
