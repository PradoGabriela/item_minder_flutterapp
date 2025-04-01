import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';

class AppIncrementButton extends StatefulWidget {
  final dynamic passItem;
  const AppIncrementButton({super.key, required this.passItem});

  @override
  State<AppIncrementButton> createState() => _AppIncrementButtonState();
}

class _AppIncrementButtonState extends State<AppIncrementButton> {
  void _incrementQuantity(dynamic item) {
    setState(() {
      item.quantity++;
      if (kDebugMode) {
        print(item.quantity);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.add_circle, color: AppStyles().getPrimaryColor()),
      iconSize: 28,
      padding: EdgeInsets.zero,
      onPressed: () => _incrementQuantity(widget.passItem),
    );
  }
}
