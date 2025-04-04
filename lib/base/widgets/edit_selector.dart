import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/item.dart';
import 'package:item_minder_flutterapp/base/managers/categories_manager.dart';
import 'package:item_minder_flutterapp/base/managers/item_manager.dart';
import 'package:item_minder_flutterapp/base/res/media.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';

class EditSelector extends StatefulWidget {
  final dynamic passItem;
  const EditSelector({super.key, required this.passItem});

  @override
  State<EditSelector> createState() => _EditSelectorState();
}

class _EditSelectorState extends State<EditSelector> {
  bool _isEnabled = false; //to enable or disable the edition

//Dropdown Setup
  List<String> dropValueList = AppCategories().categoriesDB;
  String dropdownValue = "";
  int _selectedIndex = 0;

//Dropdown Type Setup
  List<String> dropTypeValueList = [];
  String dropdownTypeValue = "";
  int _selectedTypeIndex = 0;

  void _findStarterCategory() {
    setState(() {
      _selectedIndex = AppCategories().categoriesDB.indexOf(widget
          .passItem.category); //Find the index of the category in the list
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

  void _updateTypeList() {
    List<String> itemsType =
        AppItem().itemType[AppCategories().categoriesDBRaw[_selectedIndex]] ??
            [];
    // Do something with the items, for example, print them
    setState(() {
      dropTypeValueList = itemsType;
      dropdownTypeValue = widget.passItem.type;
    });
  }

//FIELDS setup
  final _formEditKey = GlobalKey<FormState>();
  final TextEditingController _brandNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _minQuantityController = TextEditingController();
  final TextEditingController _maxQuantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  bool _isAutoadd = false;

  void _submitForm() {
    if (_formEditKey.currentState!.validate()) {
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

      // Print values (simulate saving to a database)
      if (kDebugMode) {
        print(
            'New Item Added to the database: Brand = $dropdownTypeValue, Price = $price, Available = $isAutoadd');
      }
      ItemManager itemManager = ItemManager();
      itemManager.editItem(
          widget.passItem,
          brandName,
          description,
          iconUrl,
          imageUrl,
          category,
          price,
          type,
          quantity,
          minQuantity,
          maxQuantity,
          isAutoadd);
      //Disable the form fields after submission
      _isEnabled = false;
      setState(() {
        _isAutoadd = false;
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Item edited successfully: $brandName, Price = $price')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _findStarterCategory();
    // Initialize controllers with initial values directly
    _brandNameController.text = widget.passItem.brandName;
    _descriptionController.text = widget.passItem.description;
    _priceController.text = widget.passItem.price.toString();
    // Update the list when the screen is initialized
    _updateList();
    _updateTypeList();
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
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isEnabled = !_isEnabled; // Toggle the enabled state
                    });
                  },
                  child: Text(_isEnabled ? "Disable Form" : "Enable Form"),
                ),
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

                        _updateTypeList(); // Update the type list based on the selected category

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
                    key: _formEditKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextFormField(
                          enabled: _isEnabled,
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
                          enabled: _isEnabled,
                          controller: _descriptionController,
                          maxLines: 3,
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
                          enabled: _isEnabled,
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
                          enabled: _isEnabled,
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
                          enabled: _isEnabled,
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
                          enabled: _isEnabled,
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
                                value = widget.passItem.price;
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
                            _submitForm();
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
