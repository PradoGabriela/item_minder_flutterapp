import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/categories.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/item.dart';
import 'package:item_minder_flutterapp/base/managers/shopping_manager.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';
import 'package:item_minder_flutterapp/base/widgets/bottom_buttons.dart';
import 'package:item_minder_flutterapp/screens/add_item_screen.dart';

/// **Shopping list display widget with item management capabilities.**
///
/// [ShoppingWidget] provides a **dedicated interface for managing shopping lists**
/// within the Item Minder app, showing items that need to be purchased based on
/// inventory thresholds and user-initiated additions. It serves as the main
/// content area for the shopping list screen.
///
/// **Core Features:**
/// * **Shopping List Display**: Shows items that need to be purchased
/// * **Category Filtering**: Optional filtering by item category
/// * **Quantity Management**: Direct quantity adjustment for shopping items
/// * **Visual Item Cards**: Rich display with icons, categories, and controls
/// * **Add Item Integration**: Quick access to add additional shopping items
/// * **Group Context**: Displays shopping list for specific user group
///
/// **Shopping List Logic:**
/// * Items are automatically added when inventory falls below minimum threshold
/// * Users can manually add items via the interface
/// * Items can be removed or have quantities adjusted
/// * Shopping list is group-specific for multi-user collaboration
///
/// **Data Integration:**
/// * **ShoppingManager**: Retrieves and manages shopping list items
/// * **Group Context**: Filters items by current group membership
/// * **Real-time Updates**: Reflects changes to shopping list immediately
/// * **Category Support**: Optionally filters by item categories
///
/// **User Experience:**
/// * **Visual Cards**: Rich item display with icons and categories
/// * **Direct Controls**: Quantity adjustment without leaving the list
/// * **Add Prompt**: Clear call-to-action when list is empty
/// * **Responsive Layout**: Adapts to different screen sizes
///
/// {@tool snippet}
/// ```dart
/// // Display shopping list for specific group
/// ShoppingWidget(
///   currentGroupID: selectedGroup.groupID,
/// )
///
/// // Used within shopping list screen
/// class ShoppingListScreen extends StatelessWidget {
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: ShoppingWidget(
///         currentGroupID: widget.currentGroupID,
///       ),
///     );
///   }
/// }
/// ```
/// {@end-tool}
class ShoppingWidget extends StatefulWidget {
  /// **Group identifier** for shopping list filtering.
  ///
  /// Ensures that only shopping items belonging to the specified group
  /// are displayed, maintaining proper data isolation in multi-group environments.
  final String currentGroupID;

  /// Creates a [ShoppingWidget] for the specified group.
  ///
  /// **Parameters:**
  /// * [currentGroupID] - The group ID to filter shopping items by
  const ShoppingWidget({super.key, required this.currentGroupID});

  @override
  State<ShoppingWidget> createState() => _ShoppingWidgetState();
}

/// **State management for shopping list display and interactions.**
///
/// Handles shopping list data retrieval, item display, user interactions,
/// and state updates for the shopping interface.
class _ShoppingWidgetState extends State<ShoppingWidget> {
  /// **Current shopping items** cached for display.
  ///
  /// Maintains a list of items currently on the shopping list for
  /// efficient access and potential state management operations.
  List<AppItem> shoppingItems = [];

  /// **Retrieves shopping items filtered by category.**
  ///
  /// Fetches shopping list items for the current group, with optional
  /// category filtering to show only items from specific categories.
  ///
  /// **Parameters:**
  /// * [category] - Category filter ("All" or empty for all items)
  ///
  /// **Returns:**
  /// * Future<List<AppItem>> - Filtered shopping list items
  ///
  /// **Filtering Logic:**
  /// * "All" or empty category returns all shopping items
  /// * Specific category returns only items matching that category
  Future<List<AppItem>> getShoppingItemsByCategory(String category) async {
    if (category == "All" || category.isEmpty) {
      return ShoppingManager().getShoppingList(
          widget.currentGroupID); // Fetch all items for the group
    } else {
      List<AppItem> allItems =
          await ShoppingManager().getShoppingList(widget.currentGroupID);

      return allItems.where((item) => item.category == category).toList();
    }
  }

  /// **Builds a shopping list item card** with integrated controls.
  ///
  /// Creates a rich visual representation of a shopping item including
  /// item icon, type, category badge, and quantity adjustment controls.
  /// Provides immediate access to item management without navigation.
  ///
  /// **Parameters:**
  /// * [item] - The [AppItem] to display in card format
  ///
  /// **Returns:**
  /// * Widget - Configured card widget with item details and controls
  ///
  /// **Card Features:**
  /// * Item icon with branded border styling
  /// * Item type as primary identifier
  /// * Category badge with color coding
  /// * Embedded quantity adjustment buttons
  /// * Consistent spacing and visual hierarchy
  Widget _buildItemCard({required AppItem item}) {
    // Print the image URL for debugging
    debugPrint('Image URL: ${item.iconUrl}');

    return Container(
      child: Stack(children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppStyles().getPrimaryColor(), width: 3),
          ),
          elevation: 6, // Set elevation to 0 to avoid default shadow
          color: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 29, vertical: 16),
            child: Row(
              children: [
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: AppStyles().getPrimaryColor(), width: 2),
                          image: DecorationImage(
                            image: AssetImage(item.iconUrl),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            item.type,
                            style: AppStyles().catTitleStyle,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppStyles().getPrimaryColor(),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              item.category,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 28,
                            child: AppBottomButtons(passItem: item),
                          ),
                          SizedBox(height: 10)
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  /// **Navigates to add item screen** for shopping list additions.
  ///
  /// Provides navigation to the item creation interface, allowing users
  /// to add new items directly to their shopping list or inventory.
  /// Currently commented out pending implementation details.
  void _navigateToAddItemScreen() {
/*     Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const AddItemScreen(
                currentCategory: Categories.bathroom,
              )),
    ).then((value) {
      setState(() {}); // Refresh the screen after returning from AddItemScreen
    }); */
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Shopping List",
            style: AppStyles().catTitleStyle.copyWith(fontSize: 24)),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            width: double.infinity,
            height: 520,
            color: Colors.white,
            child: FutureBuilder<List<AppItem>>(
              // Use the getShoppingItemsByCategory method to fetch items
              future: getShoppingItemsByCategory('All'),
              builder: (BuildContext context,
                  AsyncSnapshot<List<AppItem>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildAddItemPrompt();
                } else {
                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: snapshot.data!.length + 1,
                    itemBuilder: (context, index) {
                      if (index == snapshot.data!.length) {
                        return _buildAddItemPrompt();
                      } else {
                        return _buildItemCard(item: snapshot.data![index]);
                      }
                    },
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  /// **Builds add item prompt** for empty shopping lists.
  ///
  /// Creates a user-friendly call-to-action when the shopping list is empty,
  /// encouraging users to add their first shopping item. Provides clear
  /// visual guidance and immediate access to item creation.
  ///
  /// **Returns:**
  /// * Widget - Styled prompt with add button and descriptive text
  ///
  /// **Design Features:**
  /// * Large, prominent add icon using primary brand color
  /// * Clear "Add Item" text with consistent styling
  /// * Centered layout for visual emphasis
  /// * Immediate action trigger for item creation
  Widget _buildAddItemPrompt() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            Icons.add_circle,
            color: AppStyles().getPrimaryColor(),
          ),
          iconSize: 60,
          onPressed: _navigateToAddItemScreen, //temp adding screen
        ),
        Text(
          'Add Item',
          style: TextStyle(
            fontSize: 14,
            color: AppStyles().getPrimaryColor(),
          ),
        ),
      ],
    );
  }
}
