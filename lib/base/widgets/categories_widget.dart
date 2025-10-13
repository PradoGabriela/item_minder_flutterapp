import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:item_minder_flutterapp/base/managers/box_manager.dart';
import 'package:item_minder_flutterapp/base/managers/categories_manager.dart';
import 'package:item_minder_flutterapp/base/managers/group_manager.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';
import 'package:item_minder_flutterapp/base/widgets/item_card.dart';
import 'package:item_minder_flutterapp/screens/add_item_screen.dart';

/// **Category-based inventory display with swipe navigation and filtering.**
///
/// [CategoriesWidget] provides the **primary inventory browsing interface**
/// for the Item Minder app, organizing items by category with intuitive
/// navigation and real-time data synchronization. It serves as the main
/// content area of the [HomeScreen].
///
/// **Core Features:**
/// * **Category Filtering**: Display items filtered by selected category
/// * **Swipe Navigation**: Horizontal gestures to switch between categories
/// * **Dropdown Selection**: Alternative category switching via dropdown menu
/// * **Real-time Updates**: Automatic refresh when inventory changes
/// * **Add Item Integration**: Quick access to add new items in current category
/// * **Responsive Grid**: Adaptive layout that adjusts to available space
///
/// **Navigation Patterns:**
/// * **Swipe Right**: Move to next category (with boundary protection)
/// * **Swipe Left**: Move to previous category (with boundary protection)
/// * **Dropdown Selection**: Direct category jumping
/// * **Grid Display**: Organized item presentation with consistent spacing
///
/// **Data Integration:**
/// * **Group Context**: Shows only items from the specified group
/// * **Category Manager**: Uses [AppCategories] for filtering and organization
/// * **Hive Listeners**: Automatic UI updates when local storage changes
/// * **Box Manager**: Direct integration with persistent storage
///
/// **User Experience:**
/// * **Visual Feedback**: Loading states and empty category handling
/// * **Consistent Styling**: Uses [AppStyles] for brand consistency
/// * **Intuitive Controls**: Clear visual indicators for navigation options
/// * **Performance Optimized**: Efficient filtering and rendering
///
/// **Important Notes:**
/// * Must receive a valid group ID for proper data filtering
/// * Automatically disposes Hive listeners to prevent memory leaks
/// * Handles edge cases like empty categories gracefully
///
/// {@tool snippet}
/// ```dart
/// // Display categorized inventory for a specific group
/// CategoriesWidget(
///   currentGroupId: selectedGroup.groupID,
/// )
///
/// // Typically used within HomeScreen
/// class HomeScreen extends StatelessWidget {
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: CategoriesWidget(
///         currentGroupId: widget.groupId,
///       ),
///     );
///   }
/// }
/// ```
/// {@end-tool}
class CategoriesWidget extends StatefulWidget {
  /// **Group identifier** for filtering inventory items.
  ///
  /// Ensures that only items belonging to the specified group are displayed,
  /// maintaining proper data isolation in multi-group environments.
  final String currentGroupId;

  /// Creates a [CategoriesWidget] for the specified group.
  ///
  /// **Parameters:**
  /// * [currentGroupId] - The group ID to filter inventory items by
  const CategoriesWidget({super.key, required this.currentGroupId});

  @override
  State<CategoriesWidget> createState() => _CategoriesWidgetState();
}

class _CategoriesWidgetState extends State<CategoriesWidget> {
  Future<List> getFilteredItems(String groupID, String category) async {
    var filteredItems =
        await AppCategories().getItemsByCategory(groupID, category);
    if (kDebugMode) {
      debugPrint(GroupManager().isGroupOnline(groupID).toString());
      for (var item in filteredItems) {
        debugPrint(item.type.toString());
      }
    }
    return filteredItems;
  }

  int _selectedIndex = 0;
  late int _maxIndex;

  //List of categories to be displayed in the dropdown menu
  List<String>? dropValueList;
  String dropdownValue = "";
  int _dropSelectedIndex = 0;

  void _onCategorySwipped(int index) {
    setState(() {
      _selectedIndex = index;
      dropdownValue = dropValueList![index];
      if (kDebugMode) {
        print('Selected index $_selectedIndex');
        print('DropVAlue $dropdownValue');
      }
    });
  }

  _onItemsChanged() {
    if (!mounted) return;
    setState(() {
      // This will trigger a rebuild when the items in the box change
      _onCategorySwipped(_selectedIndex);
      if (kDebugMode) {
        print('Items changed, rebuilding widget...');
      }
    });
  }

  @override
  @override
  void initState() {
    super.initState();
    dropValueList =
        AppCategories().currentGroupCategories(widget.currentGroupId);
    _maxIndex = dropValueList!.length - 1;
    dropdownValue = dropValueList!.isNotEmpty ? dropValueList!.first : "";
    BoxManager().itemBox.listenable().addListener(_onItemsChanged);
    if (kDebugMode) {
      print(
          'CategoriesWidget initialized with group ID: ${widget.currentGroupId}');
      print('Available categories: $dropValueList');
      print('Initial selected index $_selectedIndex');
      print('Initial dropdown value $dropdownValue');
    }
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
                value: dropValueList!.contains(dropdownValue)
                    ? dropdownValue
                    : dropValueList?.first, // Ensure value is valid
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
                  return (dropValueList ?? []).map<Widget>((String item) {
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
                        _dropSelectedIndex = dropValueList!.indexOf(value);

                    _selectedIndex = _dropSelectedIndex;

                    if (kDebugMode) {
                      print('Selected index $_dropSelectedIndex');
                      print('DropVAlue $dropdownValue');
                    }
                  });
                },
                items: dropValueList
                    ?.map<DropdownMenuItem<String>>((String value) {
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
                future: getFilteredItems(widget.currentGroupId,
                    dropdownValue), // Provide your asynchronous method here
                builder: (BuildContext context,
                    AsyncSnapshot<List<dynamic>> snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                                        .categoryFromString(dropdownValue)!,
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
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    // Display the first item's string representation
                    return GridView.builder(
                      scrollDirection: Axis.vertical,
                      padding: EdgeInsets.only(bottom: 80),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.67,
                              crossAxisCount: 3),
                      itemCount: snapshot.data!.length + 1,
                      itemBuilder: (context, index) {
                        // Check if the data is empty

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
                                            .categoryFromString(dropdownValue)!,
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
