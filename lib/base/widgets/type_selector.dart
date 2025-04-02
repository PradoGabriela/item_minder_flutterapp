import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/item.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';

class TypeSelector extends StatefulWidget {
  final dynamic currentCategory;
  const TypeSelector({super.key, required this.currentCategory});

  @override
  State<TypeSelector> createState() => _TypeSelectorState();
}

class _TypeSelectorState extends State<TypeSelector> {
  List<String> dropValueList = [];
  String dropdownValue = "";
  int _selectedIndex = 0;

  void updateList(dynamic passCategory) {
    List<String> itemsType = AppItem().itemType[passCategory] ?? [];
    // Do something with the items, for example, print them
    setState(() {
      dropValueList = itemsType;
      dropdownValue = dropValueList[_selectedIndex];
    });
  }

  void initState() {
    super.initState();
    // Update the list when the screen is initialized
    updateList(widget.currentCategory);
    if (kDebugMode) {
      print("Updating  list");
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
            "Type",
            style: AppStyles().catTitleStyle,
          ),
          SizedBox(height: 10),
          Container(
            width: 280,
            height: 38,
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
