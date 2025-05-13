import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/res/media.dart';

class AppTitleText extends StatelessWidget {
  const AppTitleText({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 300,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppMedia().logoText),
        ),
      ),
    );
  }
}
