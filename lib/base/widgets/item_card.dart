import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';
import 'package:item_minder_flutterapp/base/widgets/bottom_buttons.dart';
import 'package:item_minder_flutterapp/screens/edit_item_screen.dart';

/// **Interactive inventory item display card with quantity management.**
///
/// [ItemCard] represents a **single inventory item** in the app's grid-based
/// interface, providing both visual information and interactive functionality.
/// It serves as the primary way users interact with their inventory items
/// throughout the application.
///
/// **Core Features:**
/// * **Visual Item Display**: Shows item icon, name, brand, and current quantity
/// * **Interactive Quantity Controls**: Embedded increment/decrement buttons
/// * **Long-press Editing**: Direct navigation to item editing interface
/// * **Responsive Design**: Adapts to container constraints with LayoutBuilder
/// * **Visual Feedback**: Custom splash effects and shadow styling
///
/// **User Interactions:**
/// * **Tap +/- buttons**: Adjust item quantity with immediate persistence
/// * **Long press card**: Navigate to full editing interface
/// * **Visual feedback**: Custom splash colors using app theme
///
/// **Design System Integration:**
/// * Uses [AppStyles] for consistent theming and colors
/// * Implements standard card shadow and border styling
/// * Maintains brand consistency with primary color accents
///
/// **Data Requirements:**
/// * Must receive a valid [AppItem] object with all required fields
/// * Icon URL must point to a valid asset image
/// * Item type and quantity must be properly initialized
///
/// This widget is **stateful** to handle quantity updates and navigation
/// state changes, ensuring the UI reflects the current item state.
///
/// {@tool snippet}
/// ```dart
/// // Display an inventory item in a grid
/// ItemCard(
///   itemType: item.type,
///   itemQuantity: item.quantity,
///   itemIconUrl: item.iconUrl,
///   myItem: item,
/// )
///
/// // Used within GridView for inventory display
/// GridView.builder(
///   itemBuilder: (context, index) => ItemCard(
///     itemType: items[index].type,
///     itemQuantity: items[index].quantity,
///     itemIconUrl: items[index].iconUrl,
///     myItem: items[index],
///   ),
/// )
/// ```
/// {@end-tool}
class ItemCard extends StatefulWidget {
  /// **Item type name** for display purposes.
  ///
  /// The specific type of inventory item (e.g., "shampoo", "toilet paper").
  /// This is displayed as the primary item identifier in the card header.
  final String itemType;

  /// **Current quantity** of the item in inventory.
  ///
  /// Displayed and managed through the card's quantity control buttons.
  /// This value is automatically updated when users interact with +/- buttons.
  final int itemQuantity;

  /// **Asset path** to the item's category icon.
  ///
  /// Points to an image asset that visually represents the item category.
  /// Must be a valid asset path defined in pubspec.yaml.
  final String itemIconUrl;

  /// **Complete item data object** for full item management.
  ///
  /// The [AppItem] instance containing all item details including metadata,
  /// pricing, thresholds, and configuration. Used for editing operations
  /// and detailed item management.
  final dynamic myItem;

  /// Creates an [ItemCard] with the specified item information.
  ///
  /// **Parameters:**
  /// * [itemType] - Display name for the item type
  /// * [itemQuantity] - Current inventory quantity
  /// * [itemIconUrl] - Asset path for the item icon
  /// * [myItem] - Complete [AppItem] data object
  ItemCard({
    required this.itemType,
    required this.itemQuantity,
    required this.itemIconUrl,
    required this.myItem,
  });

  @override
  _ItemCardState createState() => _ItemCardState();
}

/// **State management for interactive item card functionality.**
///
/// Handles user interactions, navigation state changes, and UI updates
/// for the [ItemCard] widget. Manages the card's response to user input
/// and ensures proper state management during navigation operations.
class _ItemCardState extends State<ItemCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(89, 116, 114, 114), // Shadow color adjustment
            offset: Offset(3, 3), // Position the shadow to the right and bottom
            blurRadius: 1, // Control the blur effect
          ),
        ],
      ),
      child: Material(
        clipBehavior: Clip.hardEdge,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              24), // Use the same border radius as the Card
        ),
        //Tapping Functions
        child: InkResponse(
          onLongPress: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditItemScreen(
                  passItem: widget.myItem,
                ),
              ),
            ).then((_) {
              setState(() {});
            });
          },
          splashColor:
              AppStyles().getSecondaryColor(), // Customize splash color
          highlightColor:
              AppStyles().getSecondaryColor(), // Customize highlight color
          focusColor: AppStyles().getSecondaryColor(), // Customize focus color

          child: Stack(
            children: [
              //Items cards
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                      color: AppStyles().getPrimaryColor(), width: 3),
                ),
                elevation: 0, // Set elevation to 0 to avoid default shadow
                color: Colors.white,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          height: constraints.maxHeight *
                              0.05, // 5% of the parent's height
                        ),
                        Text(
                            widget.itemType[0].toUpperCase() +
                                widget.itemType.substring(1),
                            style: AppStyles().titleStyle,
                            textAlign: TextAlign.center),
                        Text(
                          (widget.myItem.brandName != null &&
                                  widget.myItem.brandName !=
                                      "No Brand Provided")
                              ? widget.myItem.brandName
                              : "",
                          style: AppStyles().titleStyle.copyWith(
                              fontWeight: FontWeight.normal, fontSize: 12),
                        ),
                        Container(
                          height: constraints.maxHeight *
                              0.5, // 50% of the parent's height
                          decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: AppStyles().getPrimaryColor(),
                                    width: 3)),
                            image: DecorationImage(
                              image: AssetImage(widget.itemIconUrl),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: constraints.maxHeight *
                              0.2, // 5% of the parent's height
                          child: AppBottomButtons(passItem: widget.myItem),
                        )
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
