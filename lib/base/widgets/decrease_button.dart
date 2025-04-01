import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';

class AppDecreaseButton extends StatefulWidget {
  final dynamic passItem;
  const AppDecreaseButton({super.key, required this.passItem});

  @override
  State<AppDecreaseButton> createState() => _AppDecreaseButtonState();
}

class _AppDecreaseButtonState extends State<AppDecreaseButton> {
  void _decreaseQuantity(dynamic item) {
    setState(() {
      item.quantity--;
      if (kDebugMode) {
        print(item.quantity);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.remove_circle, color: AppStyles().getPrimaryColor()),
      iconSize: 28,
      padding: EdgeInsets.zero,
      onPressed: () => _decreaseQuantity(widget.passItem),
    );
  }
}
