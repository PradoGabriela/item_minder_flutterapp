import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/res/media.dart';

class AppLogoTitle extends StatelessWidget {
  const AppLogoTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return //Logo place Size 140x140 pixels, remember to fix pubspec.yaml to allow images
        Container(
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppMedia().logoTop),
        ),
      ),
    );
  }
}
