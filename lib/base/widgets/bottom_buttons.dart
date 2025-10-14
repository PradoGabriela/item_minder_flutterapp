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
  /// Helper method to calculate responsive icon size based on available space
  double _getResponsiveIconSize(double availableWidth, double availableHeight) {
    // Increased minimum icon size for bigger buttons
    final widthBasedSize =
        (availableWidth / 3.2).clamp(20.0, 36.0); // Changed from 16.0, 32.0
    final heightBasedSize =
        (availableHeight * 0.65).clamp(20.0, 36.0); // Changed from 16.0, 32.0
    return [widthBasedSize, heightBasedSize].reduce((a, b) => a < b ? a : b);
  }

  /// Helper method to calculate responsive text container dimensions
  double _getTextContainerWidth(double availableWidth) {
    // Increased minimum text container width for better visibility
    return (availableWidth / 3.8).clamp(28.0, 50.0); // Changed from 24.0, 44.0
  }

  /// Helper method to calculate responsive font size
  double _getResponsiveFontSize(double availableWidth, double availableHeight) {
    // Increased minimum font size for better readability
    final widthBasedFont =
        (availableWidth / 7.5).clamp(12.0, 18.0); // Changed from 10.0, 16.0
    final heightBasedFont =
        (availableHeight * 0.35).clamp(12.0, 18.0); // Changed from 10.0, 16.0
    return [widthBasedFont, heightBasedFont].reduce((a, b) => a < b ? a : b);
  }

  /// Helper method to calculate responsive border width
  double _getResponsiveBorderWidth(double availableWidth) {
    // Increased minimum border width for better definition
    return (availableWidth / 70).clamp(1.2, 2.5); // Changed from 1.0, 2.0
  }

  /// Helper method to get safe button constraints
  BoxConstraints _getSafeButtonConstraints(double iconSize, double iconPadding,
      double availableWidth, double availableHeight) {
    final minButtonSize = iconSize + (iconPadding * 2);
    final maxButtonWidth = availableWidth * 0.42; // Slightly increased

    // Ensure maxHeight is never smaller than minHeight
    final safeMaxHeight = availableHeight > minButtonSize
        ? availableHeight
        : minButtonSize + 6; // Increased buffer

    return BoxConstraints(
      minWidth: minButtonSize,
      minHeight: minButtonSize,
      maxWidth: maxButtonWidth,
      maxHeight: safeMaxHeight,
    );
  }

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

      if (newQuantity == item.minQuantity) {
        NotificationManager().newMinNotification(item.type.toString());
        if (item.isAutoAdd) {
          ShoppingManager().addShoppingItem(item: item, groupID: item.groupID);
        }
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
        NotificationManager().newMAxNotification(item.type.toString());
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
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Get available space from parent with minimum constraints
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 130.0; // Increased fallback
        final availableHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 45.0; // Increased fallback

        // Increased minimum viable dimensions for bigger buttons
        final safeWidth =
            availableWidth.clamp(90.0, double.infinity); // Changed from 80.0
        final safeHeight =
            availableHeight.clamp(45.0, double.infinity); // Changed from 40.0

        // Calculate responsive dimensions
        final iconSize = _getResponsiveIconSize(safeWidth, safeHeight);
        final textWidth = _getTextContainerWidth(safeWidth);
        final fontSize = _getResponsiveFontSize(safeWidth, safeHeight);
        final borderWidth = _getResponsiveBorderWidth(safeWidth);

        // Increased responsive padding for bigger touch targets
        final iconPadding =
            (safeWidth * 0.025).clamp(3.0, 10.0); // Changed from 2.0, 8.0

        // Get safe constraints for buttons
        final buttonConstraints = _getSafeButtonConstraints(
            iconSize, iconPadding, safeWidth, safeHeight);

        return SizedBox(
          width: safeWidth,
          height: safeHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Decrease button with safe constraints
              Flexible(
                flex: 2,
                child: IconButton(
                  icon: Icon(
                    Icons.remove_circle,
                    color: AppStyles().getPrimaryColor(),
                  ),
                  iconSize: iconSize,
                  padding: EdgeInsets.all(iconPadding),
                  constraints: buttonConstraints,
                  onPressed: () => _decreaseQuantity(widget.passItem),
                ),
              ),

              // Quantity display container with increased sizing
              Flexible(
                flex: 1,
                child: Container(
                  width: textWidth,
                  height: (iconSize * 1.0).clamp(
                      22.0, safeHeight * 0.85), // Increased minimum from 16.0
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: AppStyles().getPrimaryColor(),
                      width: borderWidth,
                    ),
                    borderRadius:
                        BorderRadius.circular(4), // Slightly increased from 3
                  ),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        widget.passItem.quantity.toString(),
                        style: TextStyle(
                          fontSize: fontSize,
                          color: AppStyles().getPrimaryColor(),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),

              // Increase button with safe constraints
              Flexible(
                flex: 2,
                child: IconButton(
                  icon: Icon(
                    Icons.add_circle,
                    color: AppStyles().getPrimaryColor(),
                  ),
                  iconSize: iconSize,
                  padding: EdgeInsets.all(iconPadding),
                  constraints: buttonConstraints,
                  onPressed: () => _incrementQuantity(widget.passItem),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
