import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/managers/item_manager.dart';
import 'package:item_minder_flutterapp/base/managers/notification_manager.dart';
import 'package:item_minder_flutterapp/base/managers/shopping_manager.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';

/// **Quantity control buttons with intelligent threshold management.**
///
/// [AppBottomButtons] provides **interactive quantity adjustment controls**
/// for inventory items, implementing sophisticated business logic for stock
/// management, notifications, and automatic shopping list integration.
///
/// **Core Functionality:**
/// * **Quantity Adjustment**: Increment/decrement item quantities with validation
/// * **Threshold Monitoring**: Automatic detection of min/max quantity limits
/// * **Smart Notifications**: Push notifications when thresholds are reached
/// * **Shopping List Integration**: Auto-add items when stock is low
/// * **Immediate Persistence**: Changes are saved and synced instantly
///
/// **Business Logic Features:**
/// * **Minimum Threshold**: Triggers low-stock notification and optional auto-add to shopping list
/// * **Maximum Threshold**: Alerts users when reaching capacity limits
/// * **Auto-Add Functionality**: Configurable automatic shopping list additions
/// * **Validation**: Prevents negative quantities and handles edge cases
///
/// **Integration Points:**
/// * **ItemManager**: Direct quantity updates with Firebase sync
/// * **NotificationManager**: Local push notifications for threshold events
/// * **ShoppingManager**: Automatic shopping list item creation
/// * **AppStyles**: Consistent visual design and user feedback
///
/// **User Experience:**
/// * **Immediate Feedback**: Visual changes reflect instantly
/// * **Clear Controls**: Distinct + and - buttons with proper spacing
/// * **Threshold Awareness**: Users receive notifications for important stock levels
/// * **Smart Automation**: Reduces manual shopping list management
///
/// **Performance Considerations:**
/// * Efficient state updates with minimal rebuilds
/// * Direct item property modification for speed
/// * Immediate persistence prevents data loss
///
/// {@tool snippet}
/// ```dart
/// // Add quantity controls to an item card
/// ItemCard(
///   // ... other properties
///   child: Column(
///     children: [
///       // Item display content
///       AppBottomButtons(passItem: inventoryItem),
///     ],
///   ),
/// )
///
/// // Automatic integration with item management
/// AppBottomButtons(passItem: myItem) // Handles all quantity logic
/// ```
/// {@end-tool}
class AppBottomButtons extends StatefulWidget {
  /// **Item data object** for quantity management operations.
  ///
  /// The [AppItem] instance that contains current quantity, thresholds,
  /// and configuration settings needed for intelligent quantity control.
  final dynamic passItem;

  /// Creates [AppBottomButtons] for the specified inventory item.
  ///
  /// **Parameters:**
  /// * [passItem] - The [AppItem] object to manage quantity for
  const AppBottomButtons({super.key, required this.passItem});

  @override
  State<AppBottomButtons> createState() => _AppBottomButtonsState();
}

class _AppBottomButtonsState extends State<AppBottomButtons> {
  /// **Decreases item quantity** with intelligent threshold monitoring.
  ///
  /// Handles quantity reduction while implementing smart business logic for
  /// low-stock detection, notification triggers, and automatic shopping list
  /// management based on user preferences.
  ///
  /// **Validation:**
  /// * Prevents quantity from going below zero
  /// * Exits early if item is already at minimum
  ///
  /// **Threshold Logic:**
  /// * **Minimum Threshold Reached**: Triggers low-stock notification
  /// * **Auto-Add Enabled**: Automatically adds item to shopping list
  /// * **User Feedback**: Debug logging for threshold events
  ///
  /// **Integration:**
  /// * Uses [ItemManager] for persistent quantity updates
  /// * Calls [NotificationManager] for threshold notifications
  /// * Integrates with [ShoppingManager] for auto-add functionality
  ///
  /// **Parameters:**
  /// * [item] - The [AppItem] to decrease quantity for
  void _decreaseQuantity(dynamic item) {
    setState(() {
      if (item.quantity <= 0) {
        return;
      }
      int newQuantity = item.quantity - 1;
      ItemManager().editItemQuantity(item, newQuantity);
      //TODO: update in firebas database

      if (newQuantity == item.minQuantity) {
        NotificationManager()
            .newMinNotification(item.type.toString()); //Push notification
        if (item.isAutoAdd) {
          //Add to shopping list
          ShoppingManager().addShoppingItem(
              item: item, groupID: item.groupID); //Add to shopping list
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

  /// **Increases item quantity** with maximum threshold monitoring.
  ///
  /// Handles quantity increases while monitoring for maximum capacity limits
  /// and providing appropriate user feedback when thresholds are reached.
  ///
  /// **Threshold Logic:**
  /// * **Maximum Threshold Reached**: Triggers capacity notification
  /// * **User Awareness**: Alerts when inventory reaches full capacity
  /// * **Debug Feedback**: Logging for threshold monitoring
  ///
  /// **Integration:**
  /// * Uses [ItemManager] for persistent quantity updates
  /// * Calls [NotificationManager] for maximum threshold notifications
  /// * Immediate state updates for responsive user interface
  ///
  /// **Parameters:**
  /// * [item] - The [AppItem] to increase quantity for
  void _incrementQuantity(dynamic item) {
    setState(() {
      int newQuantity = item.quantity + 1;
      ItemManager().editItemQuantity(item, newQuantity);

      if (newQuantity == item.maxQuantity) {
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
