import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/managers/categories_manager.dart';
import 'package:item_minder_flutterapp/base/item.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';
import 'package:item_minder_flutterapp/base/widgets/item_card.dart';
import 'package:item_minder_flutterapp/screens/add_item_screen.dart';

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
          //checking if is less than zero
          if (currentIndex <= 0) {
            return;
          }
          currentIndex--;
          //checking if is less than zero

          _onCategorySwipped(currentIndex);

          if (kDebugMode) {
            print('Swiped left $_selectedIndex');
          }
        }
      },
      child: Column(
        children: [
          Container(
            height: 40,
            child: Text(
                AppCategories().categoriesDB[_selectedIndex].replaceFirst(
                      AppCategories().categoriesDB[_selectedIndex][0],
                      AppCategories()
                          .categoriesDB[_selectedIndex][0]
                          .toUpperCase(),
                    ),
                style: AppStyles().catTitleStyle),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              width: double.infinity,
              height: 520,
              color: Colors.white,
              //Scrollable list of items on vertical

              child: FutureBuilder<List<dynamic>>(
                future: getFilteredItems(AppCategories().categoriesDB[
                    _selectedIndex]), // Provide your asynchronous method here
                builder: (BuildContext context,
                    AsyncSnapshot<List<dynamic>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(); // Show a loading indicator while waiting
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.add_circle,
                            color: AppStyles().getPrimaryColor(),
                          ),
                          iconSize: 60,

                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddItemScreen(
                                      currentCategory: AppCategories()
                                          .categoriesDBRaw[_selectedIndex])),
                            );
                          }, // You can customize the icon's appearance
                        ),
                        Text(
                          'Add Item', // Your label text here
                          style: TextStyle(
                            fontSize: 14,
                            color: AppStyles()
                                .getPrimaryColor(), // Customize the text color
                          ),
                        )
                      ],
                    );
                  } else {
                    // Display the first item's string representation
                    return GridView.builder(
                      scrollDirection: Axis.vertical,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.7,
                              crossAxisCount: 3),
                      itemCount: snapshot.data!.length + 1,
                      itemBuilder: (context, index) {
                        // Return widget for each grid item
                        // Check if this is the last index
                        if (index == snapshot.data!.length) {
                          // Return the 'add' icon as the last item
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.add_circle,
                                  color: AppStyles().getPrimaryColor(),
                                ),
                                iconSize: 60,

                                onPressed:
                                    () {}, // You can customize the icon's appearance
                              ),
                              Text(
                                'Add Item', // Your label text here
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppStyles()
                                      .getPrimaryColor(), // Customize the text color
                                ),
                              )
                            ],
                          );
                        } else {
                          return ItemCard(
                            itemType: snapshot.data![index].type.toString(),
                            itemQuantity: snapshot.data![index].quantity,
                            itemImgURL: snapshot.data![index].imageUrl,
                            myItem: snapshot.data![index],
                          );
                        }
                      },
                    );

                    //Text(snapshot.data![0].type.toString());
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
