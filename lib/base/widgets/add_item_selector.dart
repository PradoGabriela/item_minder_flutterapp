import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/item.dart';
import 'package:item_minder_flutterapp/base/managers/categories_manager.dart';
import 'package:item_minder_flutterapp/base/managers/item_manager.dart';
import 'package:item_minder_flutterapp/base/res/media.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';

class AddItemSelector extends StatefulWidget {
  final dynamic currentCategory;
  final String? currentGroupId;

  const AddItemSelector(
      {super.key, required this.currentCategory, required this.currentGroupId});
  @override
  State<AddItemSelector> createState() => _AddItemSelectorState();
}

class _AddItemSelectorState extends State<AddItemSelector> {
//Dropdown Setup
  List<String> dropValueList = AppCategories().categoriesDB;
  String dropdownValue = "";
  int _selectedIndex = 0;

  List<String> dropTypeValueList = [];
  String dropdownTypeValue = "";
  int _selectedTypeIndex = 0;

  void _findStarterCategory() {
    setState(() {
      _selectedIndex =
          AppCategories().categoriesDBRaw.indexOf(widget.currentCategory);
      if (kDebugMode) {
        print("Starter Category index $_selectedIndex");
      }
    });
  }

  void _updateList() {
    setState(() {
      dropdownValue = dropValueList[_selectedIndex];
    });
  }

  void _updateTypeList(dynamic passCategoryIndex) {
    List<String> itemsType =
        AppItem().itemType[AppCategories().categoriesDBRaw[_selectedIndex]] ??
            [];
    // Do something with the items, for example, print them
    setState(() {
      dropTypeValueList = itemsType;
      dropdownTypeValue = dropTypeValueList[_selectedTypeIndex];
    });
  }

  //FIELDS setup
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _brandNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _minQuantityController = TextEditingController();
  final TextEditingController _maxQuantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  bool _isAutoadd = false;

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
