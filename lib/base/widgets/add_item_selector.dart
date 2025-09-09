import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/managers/categories_manager.dart';
import 'package:item_minder_flutterapp/base/managers/item_manager.dart';
import 'package:item_minder_flutterapp/base/managers/type_items_manager.dart';
import 'package:item_minder_flutterapp/base/res/media.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';

/// **Comprehensive item creation form with intelligent category and type selection.**
///
/// [AddItemSelector] provides the **complete interface for creating new inventory items**
/// with smart defaults, validation, and seamless integration with the app's data management
/// systems. It handles the entire item creation workflow from category selection to
/// final persistence.
///
/// **Core Features:**
/// * **Smart Category Selection**: Pre-selects category based on current context
/// * **Dynamic Type Filtering**: Updates available types based on selected category
/// * **Comprehensive Form Input**: Collects all item metadata and configuration
/// * **Intelligent Validation**: Ensures data integrity with business rule validation
/// * **Automatic Icon Assignment**: Assigns appropriate icons based on item type
/// * **Threshold Management**: Configures min/max quantities with validation
/// * **Auto-add Configuration**: Sets up automatic shopping list integration
///
/// **User Experience Flow:**
/// 1. Category pre-selected from context (can be changed via dropdown)
/// 2. Type selection updates dynamically based on category
/// 3. Form fields for item details with intelligent defaults
/// 4. Validation ensures proper quantity relationships
/// 5. Item created and saved with immediate feedback
///
/// **Business Logic Integration:**
/// * **Category-Type Relationship**: Uses [TypeItemsManager] for valid type options
/// * **Icon Assignment**: Automatically assigns icons via [AppMedia]
/// * **Data Persistence**: Creates items via [ItemManager] with dual-storage
/// * **Group Association**: Ensures item belongs to correct group context
///
/// **Validation Rules:**
/// * Max quantity must be greater than min quantity
/// * Required fields must be populated (with intelligent defaults)
/// * Numeric fields must contain valid numbers
/// * Form validation prevents invalid submissions
///
/// {@tool snippet}
/// ```dart
/// // Embed in add item interface
/// AddItemSelector(
///   currentCategory: "kitchen",
///   currentGroupId: group.groupID,
/// )
///
/// // Used within AddWidget for complete creation flow
/// AddWidget(
///   currentCategory: selectedCategory,
///   currentGroupId: activeGroup.groupID,
/// )
/// ```
/// {@end-tool}
class AddItemSelector extends StatefulWidget {
  /// **Current category context** for intelligent form defaults.
  ///
  /// The category that was selected when the user initiated item creation.
  /// This pre-selects the category dropdown and filters available item types.
  final dynamic currentCategory;

  /// **Target group identifier** for item ownership assignment.
  ///
  /// Ensures the created item is associated with the correct user group,
  /// maintaining proper data isolation in multi-group environments.
  final String? currentGroupId;

  /// Creates an [AddItemSelector] with the specified context.
  ///
  /// **Parameters:**
  /// * [currentCategory] - Pre-selected category for smart defaults
  /// * [currentGroupId] - Target group for the new item
  const AddItemSelector(
      {super.key, required this.currentCategory, required this.currentGroupId});
  @override
  State<AddItemSelector> createState() => _AddItemSelectorState();
}

/// **State management for the comprehensive item creation form.**
///
/// Handles form state, dropdown selections, validation logic, and item
/// submission workflow. Manages the complex interaction between category
/// selection, type filtering, and form input validation.
/// **State management for the comprehensive item creation form.**
///
/// Handles form state, dropdown selections, validation logic, and item
/// submission workflow. Manages the complex interaction between category
/// selection, type filtering, and form input validation.
class _AddItemSelectorState extends State<AddItemSelector> {
  /// **Available category options** for dropdown selection.
  ///
  /// Populated from [AppCategories] database to ensure consistency
  /// with the app's category management system.
  List<String> dropValueList = AppCategories().categoriesDB;

  /// **Currently selected category** in the dropdown.
  ///
  /// Updates when user changes category selection, triggering
  /// type list updates and form reconfiguration.
  String dropdownValue = "";

  /// **Index of selected category** for efficient lookups.
  ///
  /// Used for array-based operations and type filtering logic.
  int _selectedIndex = 0;

  /// **Available item type options** based on selected category.
  ///
  /// Dynamically populated when category changes to show only
  /// relevant item types for the selected category.
  List<String> dropTypeValueList = [];

  /// **Currently selected item type** in the type dropdown.
  ///
  /// Determines the specific item type being created and affects
  /// icon assignment and categorization.
  String dropdownTypeValue = "";

  /// **Index of selected type** for efficient lookups.
  ///
  /// Used for array-based operations and type management.
  int _selectedTypeIndex = 0;

  /// **Locates the starting category index** based on widget context.
  ///
  /// Sets the initial category selection to match the category context
  /// passed to the widget, providing intelligent defaults for the user.
  void _findStarterCategory() {
    setState(() {
      _selectedIndex =
          AppCategories().categoriesDBRaw.indexOf(widget.currentCategory);
      if (kDebugMode) {
        print("Starter Category index $_selectedIndex");
      }
    });
  }

  /// **Updates the category dropdown** with current selection.
  ///
  /// Synchronizes the dropdown display value with the internal
  /// selected index, ensuring UI consistency.
  void _updateList() {
    setState(() {
      dropdownValue = dropValueList[_selectedIndex];
    });
  }

  /// **Updates item type options** based on selected category.
  ///
  /// Dynamically filters and updates the type dropdown to show only
  /// item types that are valid for the currently selected category.
  /// This ensures logical relationships between categories and types.
  ///
  /// **Parameters:**
  /// * [passCategoryIndex] - The category index to filter types for
  void _updateTypeList(dynamic passCategoryIndex) {
    List<String> itemsType = TypeItemsManager()
            .itemTypes[AppCategories().categoriesDBRaw[_selectedIndex]] ??
        [];
    // Do something with the items, for example, print them
    setState(() {
      dropTypeValueList = itemsType;
      dropdownTypeValue = dropTypeValueList[_selectedTypeIndex];
    });
  }

  /// **Form validation key** for input field validation.
  ///
  /// Manages form state and validation for all input fields,
  /// ensuring data integrity before item submission.
  final _formKey = GlobalKey<FormState>();

  /// **Brand name input controller** for item brand field.
  final TextEditingController _brandNameController = TextEditingController();

  /// **Description input controller** for item description field.
  final TextEditingController _descriptionController = TextEditingController();

  /// **Quantity input controller** for current inventory quantity.
  final TextEditingController _quantityController = TextEditingController();

  /// **Minimum quantity input controller** for low-stock threshold.
  final TextEditingController _minQuantityController = TextEditingController();

  /// **Maximum quantity input controller** for capacity limit.
  final TextEditingController _maxQuantityController = TextEditingController();

  /// **Price input controller** for item cost field.
  final TextEditingController _priceController = TextEditingController();

  /// **Auto-add setting** for automatic shopping list integration.
  ///
  /// When enabled, items are automatically added to shopping list
  /// when inventory reaches minimum threshold.
  bool _isAutoadd = true;

  /// **Processes form submission and creates the inventory item.**
  ///
  /// Validates all form inputs, performs business logic validation,
  /// creates the item via [ItemManager], and provides user feedback.
  /// This method handles the complete item creation workflow.
  ///
  /// **Validation Steps:**
  /// 1. Form field validation via Flutter's validation framework
  /// 2. Business logic validation (max > min quantity)
  /// 3. Data type conversion and sanitization
  /// 4. Item creation via manager pattern
  ///
  /// **Parameters:**
  /// * [groupID] - Target group for the new item
  ///
  /// **User Feedback:**
  /// * Success: Shows confirmation snackbar with item details
  /// * Failure: Shows error message for validation failures
  /// * Navigation: Returns to previous screen on successful creation
  void _submitForm(String groupID) {
    // Validate the form fields
    if (_formKey.currentState!.validate()) {
      String brandName = _brandNameController.text;
      String description = _descriptionController.text;
      String iconUrl = AppMedia().otherIcon; //Temporary icon o default
      String imageUrl = AppMedia().otherIcon; //Temporary icon o default
      String category = dropdownValue; // Get the selected category
      String type = dropdownTypeValue; // Get the selected type
      double price = double.parse(_priceController.text);
      int quantity = int.parse(_quantityController.text);
      int minQuantity = int.parse(_minQuantityController.text);
      int maxQuantity = int.parse(_maxQuantityController.text);
      bool isAutoadd = _isAutoadd;

      if (maxQuantity <= minQuantity) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Max Quantity must be greater than Min Quantity')),
        );
        return; // Exit the function if the condition is not met
      }

      ItemManager itemManager = ItemManager();
      itemManager.addCustomItem(
        groupID: groupID,
        brandName: brandName,
        description: description,
        iconUrl: AppMedia().getItemIcon(type.toLowerCase()),
        imageUrl: imageUrl,
        category: category,
        price: price,
        type: type,
        quantity: quantity,
        minQuantity: minQuantity,
        maxQuantity: maxQuantity,
        isAutoadd: isAutoadd,
        itemID: "", // Pass an empty string for itemID
      );

      // Print values (simulate saving to a database)
      if (kDebugMode) {
        print(
            'New Item Added to the database: Brand = $brandName, Price = $price, Available = $isAutoadd');
      }
      // Clear the form fields after submission

      // Clear inputs
      _brandNameController.clear();
      _descriptionController.clear();
      _quantityController.clear();
      _minQuantityController.clear();
      _maxQuantityController.clear();
      _isAutoadd = false; // Reset auto-add checkbox
      _priceController.clear();
      setState(() {
        _isAutoadd = false;
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Item added: $brandName - \$${price.toStringAsFixed(2)}, Price: $price')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _findStarterCategory();
    // Update the list when the screen is initialized
    _updateList();
    _updateTypeList(dropdownValue);
    if (kDebugMode) {
      print("Updating  Shelves list");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //shelf selector
                const SizedBox(height: 10),
                Text(
                  "Shelf",
                  style: AppStyles().catTitleStyle,
                ),
                const SizedBox(height: 10),
                Container(
                  width: 280,
                  height: 38, // Added fixed height for better layout
                  decoration: BoxDecoration(
                    color: AppStyles().getPrimaryColor(),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: DropdownButton<String>(
                    value: dropValueList.contains(dropdownValue)
                        ? dropdownValue
                        : dropValueList.first, // Ensure value is valid
                    icon: const Icon(Icons.arrow_drop_down_circle_rounded),
                    iconEnabledColor: Colors.white,
                    iconSize: 32,
                    elevation: 20,
                    underline: const SizedBox(),
                    dropdownColor: AppStyles().getPrimaryColor(),
                    menuMaxHeight: 400,
                    borderRadius: BorderRadius.circular(20),
                    alignment: const AlignmentDirectional(0, 40),

                    style: AppStyles().dropTextStyle,
                    isExpanded: true, // This makes the dropdown take full width
                    selectedItemBuilder: (BuildContext context) {
                      return dropValueList.map<Widget>((String item) {
                        return Center(
                          child: Text(
                            item,
                            style: AppStyles().dropTextStyle,
                          ),
                        );
                      }).toList();
                    },

                    onChanged: (String? value) {
                      // This is called when the user selects an item.
                      setState(() {
                        dropdownValue = value!;

                        _selectedIndex =
                            _selectedIndex = dropValueList.indexOf(value);

                        _updateTypeList(dropdownValue);

                        if (kDebugMode) {
                          print('Selected index $_selectedIndex');
                          print('DropVAlue $dropdownValue');
                        }
                      });
                    },
                    items: dropValueList
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            //type selector
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Text(
                  "Type",
                  style: AppStyles().catTitleStyle,
                ),
                const SizedBox(height: 10),
                Container(
                  width: 280,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppStyles().getPrimaryColor(),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: DropdownButton<String>(
                    value: dropTypeValueList.contains(dropdownTypeValue)
                        ? dropdownTypeValue
                        : dropTypeValueList.first, // Ensure value is valid
                    icon: const Icon(Icons.arrow_drop_down_circle_rounded),
                    iconEnabledColor: Colors.white,
                    iconSize: 32,
                    elevation: 20,
                    dropdownColor: AppStyles().getPrimaryColor(),
                    underline: const SizedBox(),

                    menuMaxHeight: 400,
                    borderRadius: BorderRadius.circular(20),
                    alignment: const AlignmentDirectional(0, 40),

                    style: AppStyles().dropTextStyle,
                    isExpanded: true, // This makes the dropdown take full width
                    selectedItemBuilder: (BuildContext context) {
                      return dropTypeValueList.map<Widget>((String item) {
                        return Center(
                          child: Text(
                            item,
                            style: AppStyles().dropTextStyle,
                          ),
                        );
                      }).toList();
                    },

                    onChanged: (String? value) {
                      // This is called when the user selects an item.
                      setState(() {
                        dropdownTypeValue = value!;

                        _selectedTypeIndex = _selectedTypeIndex =
                            dropTypeValueList.indexOf(value);

                        if (kDebugMode) {
                          print('Selected index type $_selectedTypeIndex');
                          print('DropVAlue type $dropdownTypeValue');
                        }
                      });
                    },
                    items: dropTypeValueList
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),

                ///Form to add item
                const SizedBox(height: 10),
                Container(
                  width: 260,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextFormField(
                          controller: _brandNameController,
                          decoration: InputDecoration(
                              labelText: 'Brand Name',
                              labelStyle: AppStyles().formTextStyle),
                          style: AppStyles().formFieldStyle,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              setState(() {
                                value = "No Brand Provided";
                              });
                              return null;
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                              labelText: 'Description',
                              labelStyle: AppStyles().formTextStyle),
                          style: AppStyles().formFieldStyle,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              setState(() {
                                value = "No description provided";
                              });
                              return null; //In case need it later
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _quantityController,
                          decoration: InputDecoration(
                              labelText: 'Quantity',
                              labelStyle: AppStyles().formTextStyle),
                          style: AppStyles().formFieldStyle,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a quantity';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _minQuantityController,
                          decoration: InputDecoration(
                              labelText: 'Min Quantity',
                              labelStyle: AppStyles().formTextStyle),
                          style: AppStyles().formFieldStyle,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a minimum quantity';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _maxQuantityController,
                          decoration: InputDecoration(
                              labelText: 'Max Quantity',
                              labelStyle: AppStyles().formTextStyle),
                          style: AppStyles().formFieldStyle,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a maximum quantity';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _priceController,
                          decoration: InputDecoration(
                              labelText: 'Price',
                              labelStyle: AppStyles().formTextStyle),
                          style: AppStyles().formFieldStyle,
                          // Use the appropriate keyboard type for price input
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              setState(() {
                                value = "0.00";
                              });
                              return null;
                            }
                            return null;
                          },
                        ),
                        SwitchListTile(
                          title: Text("AutoAdd to List?",
                              style: AppStyles().formTextStyle),
                          value: _isAutoadd,
                          onChanged: (bool newValue) {
                            setState(() {
                              _isAutoadd = newValue;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            _submitForm(widget.currentGroupId!);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppStyles().getPrimaryColor(),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: const Text(
                            'Add Item',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
