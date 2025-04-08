import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/managers/notification_manager.dart';
import 'package:item_minder_flutterapp/base/managers/shopping_manager.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';

class AppBottomButtons extends StatefulWidget {
  final dynamic passItem;
  const AppBottomButtons({super.key, required this.passItem});

  @override
  State<AppBottomButtons> createState() => _AppBottomButtonsState();
}

class _AppBottomButtonsState extends State<AppBottomButtons> {
  void _decreaseQuantity(dynamic item) {
    setState(() {
      if (item.quantity <= 0) {
        return;
      }
      item.quantity--;

      if (item.quantity == item.minQuantity) {
        NotificationManager()
            .newMinNotification(item.type.toString()); //Push notification
        if (item.isAutoAdd) {
          //Add to shopping list
          ShoppingManager().addShoppingItem(item: item); //Add to shopping list
        }
        //If is autoadd add to shopping list
        if (kDebugMode) {
          print('Min quantity( ${item.minQuantity} ) reached ');
        }
      }
      item.save();
    });
    if (kDebugMode) {
      print('current ${item.quantity}');
    }
  }

  void _incrementQuantity(dynamic item) {
    setState(() {
      item.quantity++;
      if (item.quantity == item.maxQuantity) {
        NotificationManager().newMAxNotification(
            item.type.toString()); //Push notification max quantity reached

        if (kDebugMode) {
          print('Max quantity( ${item.maxQuantity} ) reached ');
        }
      }
      item.save();
    });
    if (kDebugMode) {
      print(item.quantity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.remove_circle, color: AppStyles().getPrimaryColor()),
          iconSize: 28,
          padding: EdgeInsets.zero,
          onPressed: () => _decreaseQuantity(widget.passItem),
        ),
        Container(
            width: 22,
            decoration: BoxDecoration(
              color: Colors.white,
              border:
                  Border.all(color: AppStyles().getPrimaryColor(), width: 1),
            ),
            child: Text(
              widget.passItem.quantity.toString(),
              style:
                  TextStyle(fontSize: 12, color: AppStyles().getPrimaryColor()),
              textAlign: TextAlign.center,
            )),
        IconButton(
          icon: Icon(Icons.add_circle, color: AppStyles().getPrimaryColor()),
          iconSize: 28,
          padding: EdgeInsets.zero,
          onPressed: () => _incrementQuantity(widget.passItem),
        ),
      ],
    );
  }
}
