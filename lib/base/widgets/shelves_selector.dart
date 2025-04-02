import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/categories.dart';
import 'package:item_minder_flutterapp/base/item.dart';
import 'package:item_minder_flutterapp/base/managers/categories_manager.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';
import 'package:item_minder_flutterapp/base/widgets/type_selector.dart';

class ShelvesSelector extends StatefulWidget {
  final dynamic currentCategory;

  const ShelvesSelector({super.key, required this.currentCategory});
  @override
  State<ShelvesSelector> createState() => _ShelvesSelectorState();
}

class _ShelvesSelectorState extends State<ShelvesSelector> {
  List<String> dropValueList = AppCategories().categoriesDB;
  String dropdownValue = "";
  int _selectedIndex = 0;

  void _updateList() {
    setState(() {
      dropdownValue = dropValueList[_selectedIndex];
    });
  }

  @override
  void initState() {
    super.initState();
    // Update the list when the screen is initialized
    _updateList();
    if (kDebugMode) {
      print("Updating  Shelves list");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(89, 116, 114, 114), // Shadow color adjustment
            offset: Offset(5, 5), // Position the shadow to the right and bottom
            blurRadius: 1, // Control the blur effect
          ),
        ],
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Shelves",
            style: AppStyles().catTitleStyle,
          ),
          SizedBox(height: 10),
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
              dropdownColor: AppStyles().getPrimaryColor(),

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

                  if (kDebugMode) {
                    print('Selected index $_selectedIndex');
                    print('DropVAlue $dropdownValue');
                  }
                });
              },
              items:
                  dropValueList.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
