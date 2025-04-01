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

int _selectedIndex = 0;
int _maxIndex = AppCategories().categoriesDB.length - 1;

class _CategoriesWidgetState extends State<CategoriesWidget> {
  void _onCategorySwipped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    //Swipe rigth and left widget
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        int currentIndex = _selectedIndex;
        if (details.primaryVelocity! > 0) {
          currentIndex++;
          if (currentIndex >= _maxIndex) {
            _onCategorySwipped(_maxIndex);
          } else {
            _onCategorySwipped(currentIndex);
          }

          if (kDebugMode) {
            print('Swiped right $_selectedIndex');
          }
          //checking max number of categories
        } else if (details.primaryVelocity! < 0) {
          currentIndex--;
          //checking if is less than zero
          if (currentIndex <= 0) {
            _onCategorySwipped(0);
          } else {
            _onCategorySwipped(currentIndex);
          }

          if (kDebugMode) {
            print('Swiped left $_selectedIndex');
          }
        }
      },
      child: Column(
        children: [
          Container(
            height: 30,
            color: Colors.yellow,
            child: Text(AppCategories().categoriesDB[_selectedIndex]),
          ),
          Container(
            width: 200,
            height: 500,
            color: Colors.orange,
            //Scrollable list of items on vertical

            child: FutureBuilder<List<dynamic>>(
              future: getFilteredItems(AppCategories().categoriesDB[
                  _selectedIndex]), // Provide your asynchronous method here
              builder: (BuildContext context,
                  AsyncSnapshot<List<dynamic>> snapshot) {
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
      ),
    );
  }
}
