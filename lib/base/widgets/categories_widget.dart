import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:item_minder_flutterapp/base/managers/box_manager.dart';
import 'package:item_minder_flutterapp/base/managers/categories_manager.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';
import 'package:item_minder_flutterapp/base/widgets/item_card.dart';
import 'package:item_minder_flutterapp/screens/add_item_screen.dart';

class CategoriesWidget extends StatefulWidget {
  final String? currentGroupId;
  const CategoriesWidget({super.key, required this.currentGroupId});

  @override
  State<CategoriesWidget> createState() => _CategoriesWidgetState();
}

class _CategoriesWidgetState extends State<CategoriesWidget> {
  Future<List> getFilteredItems(String category) async {
    var filteredItems = await AppCategories().getItemsByCategory(category);
    if (kDebugMode) {
      filteredItems.forEach((item) {
        debugPrint(item.key.toString());
      });
    }
    return filteredItems;
  }

  int _selectedIndex = 0;
  int _maxIndex = AppCategories().categoriesDB.length - 1;

  //List of categories to be displayed in the dropdown menu
  List<String> dropValueList = AppCategories().categoriesDB;
  String dropdownValue = "";
  int _dropSelectedIndex = 0;

  void _onCategorySwipped(int index) {
    setState(() {
      _selectedIndex = index;
      dropdownValue = dropValueList[index];
      if (kDebugMode) {
        print('Selected index $_selectedIndex');
        print('DropVAlue $dropdownValue');
      }
    });
  }

  _onItemsChanged() {
    setState(() {
      // This will trigger a rebuild when the items in the box change
      _onCategorySwipped(_selectedIndex);
      if (kDebugMode) {
        print('Items changed, rebuilding widget...');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    BoxManager().itemBox.listenable().addListener(_onItemsChanged);
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
            _dropSelectedIndex = currentIndex;
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
          SizedBox(
            height: 60,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              DropdownButton<String>(
                value: dropValueList.contains(dropdownValue)
                    ? dropdownValue
                    : dropValueList.first, // Ensure value is valid
                icon: const Icon(Icons.arrow_drop_down_circle_rounded),
                iconEnabledColor: AppStyles().getPrimaryColor(),
                iconSize: 32,
                elevation: 20,
                underline: const SizedBox(),
                dropdownColor: AppStyles().getPrimaryColor(),
                menuMaxHeight: 400,
                borderRadius: BorderRadius.circular(20),
                alignment: const AlignmentDirectional(0, 40),

                style: AppStyles().catTitleStyle.copyWith(color: Colors.white),
                //isExpanded: true, // This makes the dropdown take full width
                selectedItemBuilder: (BuildContext context) {
                  return dropValueList.map<Widget>((String item) {
                    return Center(
                      child: Text(
                        item.replaceFirst(item[0], item[0].toUpperCase()),
                        style: AppStyles().catTitleStyle.copyWith(fontSize: 24),
                      ),
                    );
                  }).toList();
                },

                onChanged: (String? value) {
                  // This is called when the user selects an item.
                  setState(() {
                    dropdownValue = value!;

                    _dropSelectedIndex =
                        _dropSelectedIndex = dropValueList.indexOf(value);

                    _selectedIndex = _dropSelectedIndex;

                    if (kDebugMode) {
                      print('Selected index $_dropSelectedIndex');
                      print('DropVAlue $dropdownValue');
                    }
                  });
                },
                items:
                    dropValueList.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                        value.replaceFirst(value[0], value[0].toUpperCase())),
                    // This is the text that will be displayed in the dropdown menu
                  );
                }).toList(),
              ),
              const SizedBox(width: 10),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              width: double.infinity,
              height: 520,
              color: Colors.white,
              //Scrollable list of items on vertical

              child: FutureBuilder<List<dynamic>>(
                // Use the FutureBuilder to handle asynchronous data fetching
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
                                        .categoriesDBRaw[_selectedIndex],
                                    currentGroupId: widget.currentGroupId),
                              ),
                            ).then((_) {
                              setState(() {});
                            });
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
                      padding: EdgeInsets.only(bottom: 80),
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

                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddItemScreen(
                                        currentCategory: AppCategories()
                                            .categoriesDBRaw[_selectedIndex],
                                        currentGroupId: widget.currentGroupId,
                                      ),
                                    ),
                                  ).then((_) {
                                    setState(() {});
                                  });
                                }, // You can customize the icon's appearance
                              ),
                              Text(
                                'Add Item', // Your label text here
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppStyles()
                                      .getPrimaryColor(), // Customize the text color
                                ),
                              ),
                            ],
                          );
                        } else {
                          return ItemCard(
                            itemType: snapshot.data![index].type.toString(),
                            itemQuantity: snapshot.data![index].quantity,
                            itemIconUrl: snapshot.data![index].iconUrl,
                            myItem: snapshot.data![index],
                          );
                        }
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    BoxManager().itemBox.listenable().removeListener(_onItemsChanged);
    super.dispose();
  }
}
