import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/res/media.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';
import 'package:item_minder_flutterapp/base/widgets/add_item_selector.dart';

/// **Full-screen item creation interface with category context.**
///
/// [AddWidget] provides a **dedicated interface for adding new inventory items**
/// to the user's collection. It presents a clean, focused environment that
/// minimizes distractions while collecting item information and configuration.
///
/// **Core Features:**
/// * **Category-aware creation**: Pre-fills category based on current selection
/// * **Group context preservation**: Ensures items are added to correct group
/// * **Branded interface**: Displays app logo for visual consistency
/// * **Form-based input**: Comprehensive item configuration through embedded selector
/// * **Full-screen focus**: Dedicated screen space for detailed item setup
///
/// **Design Elements:**
/// * **Consistent styling**: Uses [AppStyles] secondary color for background
/// * **Card-based layout**: Central card with shadow for visual emphasis
/// * **Responsive design**: Adapts to different screen sizes with fixed dimensions
/// * **Visual hierarchy**: Logo header followed by input form
///
/// **User Workflow:**
/// 1. User navigates from category view or add button
/// 2. Interface opens with category pre-selected
/// 3. User fills out item details via [AddItemSelector]
/// 4. Item is saved and user returns to previous screen
///
/// **Integration Points:**
/// * **Category Context**: Receives current category for smart defaults
/// * **Group Context**: Ensures item belongs to active group
/// * **Media Assets**: Displays app logo from [AppMedia]
/// * **Form Logic**: Delegates input handling to [AddItemSelector]
///
/// {@tool snippet}
/// ```dart
/// // Navigate to add item interface
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => AddItemScreen(
///       currentCategory: "kitchen",
///       currentGroupId: selectedGroup.groupID,
///     ),
///   ),
/// );
///
/// // Widget usage in navigation
/// AddWidget(
///   currentCategory: widget.selectedCategory,
///   currentGroupId: widget.currentGroupId,
/// )
/// ```
/// {@end-tool}
class AddWidget extends StatefulWidget {
  /// **Current category context** for smart item creation defaults.
  ///
  /// The category that was active when the user initiated item creation.
  /// This provides intelligent defaults for category selection in the form.
  final dynamic currentCategory;

  /// **Active group identifier** for item ownership assignment.
  ///
  /// Ensures the new item is associated with the correct user group,
  /// maintaining proper data isolation in multi-group environments.
  final String? currentGroupId;

  /// Creates an [AddWidget] with the specified context information.
  ///
  /// **Parameters:**
  /// * [currentCategory] - The category context for smart defaults
  /// * [currentGroupId] - The target group for the new item
  const AddWidget(
      {super.key, required this.currentCategory, required this.currentGroupId});

  @override
  State<AddWidget> createState() => _AddWidgetState();
}

/// **State management for the add item interface.**
///
/// Handles the lifecycle and user interactions for the item creation
/// interface, managing state changes and form submission workflow.
class _AddWidgetState extends State<AddWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles().getSecondaryColor(),
      body: ListView(
        children: [
          Container(
            width: 380,
            height: 760,
            margin: const EdgeInsetsDirectional.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(
                      89, 116, 114, 114), // Shadow color adjustment
                  offset: Offset(
                      5, 5), // Position the shadow to the right and bottom
                  blurRadius: 1, // Control the blur effect
                ),
              ],
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: Colors.black, width: 3),
              ),
              elevation: 0, // Set elevation to 0 to avoid default shadow
              color: Colors.white,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(AppMedia().logo),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      //First Menu
                      AddItemSelector(
                          currentCategory: widget.currentCategory,
                          currentGroupId: widget.currentGroupId),
                    ],
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
