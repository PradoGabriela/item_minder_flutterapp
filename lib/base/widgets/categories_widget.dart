import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/categories_manager.dart';
import 'package:item_minder_flutterapp/base/item.dart';

class CategoriesWidget extends StatefulWidget {
  const CategoriesWidget({super.key});

  @override
  State<CategoriesWidget> createState() => _CategoriesWidgetState();
}

Future<List> getFilteredItems(String category) async {
  var filteredItems = await AppCategories().getItemsByCategory(category);
  if (kDebugMode) {
    print(filteredItems);
  }
  return filteredItems;
}

int _initialIndex = 0;

class _CategoriesWidgetState extends State<CategoriesWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 30,
          color: Colors.yellow,
          child: Text(AppCategories().categoriesDB[0]),
        ),
        Container(
          width: 200,
          height: 500,
          color: Colors.orange,
          //Scrollable list of items on vertical

          child: FutureBuilder<List<dynamic>>(
            future: getFilteredItems(
                'bathroom'), // Provide your asynchronous method here
            builder:
                (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(); // Show a loading indicator while waiting
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('No items available');
              } else {
                // Display the first item's string representation
                return Text(snapshot.data![0].type.toString());
              }
            },
          ),
        ),
      ],
    );
  }
}
