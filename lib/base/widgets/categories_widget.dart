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
  // Helper method to get responsive dimensions
  double _getResponsiveDimension(BuildContext context, double baseValue) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final scaleFactor =
        (screenWidth / 375.0).clamp(0.8, 1.5); // Base on iPhone X width
    return baseValue * scaleFactor;
  }

  // Helper method to determine grid columns based on screen width
  int _getGridColumns(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 400) return 2; // Small phones
    if (screenWidth < 600) return 3; // Normal phones
    if (screenWidth < 900) return 4; // Large phones/small tablets
    return 5; // Tablets
  }

  // Helper method to get responsive grid height
  double _getGridHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final availableHeight = screenHeight -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom -
        120; // Account for dropdown
    return (availableHeight * 0.75).clamp(300, 600);
  }

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
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;
    final responsiveIconSize = _getResponsiveDimension(context, 32);
    final responsiveFontSize = _getResponsiveDimension(context, 24);
    final gridColumns = _getGridColumns(context);

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
        } else if (details.primaryVelocity! < 0) {
          if (currentIndex <= 0) {
            return;
          }
          currentIndex--;
          _onCategorySwipped(currentIndex);

          if (kDebugMode) {
            print('Swiped left $_selectedIndex');
          }
        }
      },
      child: SizedBox(
        height: screenSize.height * 0.75, // Define explicit height
        child: Column(
          children: [
            // Dropdown container with fixed height
            Container(
              height: _getResponsiveDimension(context, 60),
              padding: EdgeInsets.symmetric(
                horizontal: _getResponsiveDimension(context, 16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: DropdownButton<String>(
                      value: dropValueList!.contains(dropdownValue)
                          ? dropdownValue
                          : dropValueList?.first,
                      icon: const Icon(Icons.arrow_drop_down_circle_rounded),
                      iconEnabledColor: AppStyles().getPrimaryColor(),
                      iconSize: responsiveIconSize,
                      elevation: 20,
                      underline: const SizedBox(),
                      dropdownColor: AppStyles().getPrimaryColor(),
                      menuMaxHeight: screenSize.height * 0.4,
                      borderRadius: BorderRadius.circular(20),
                      alignment: const AlignmentDirectional(0, 40),
                      style: AppStyles()
                          .catTitleStyle
                          .copyWith(color: Colors.white),
                      selectedItemBuilder: (BuildContext context) {
                        return (dropValueList ?? []).map<Widget>((String item) {
                          return Center(
                            child: Text(
                              item.replaceFirst(item[0], item[0].toUpperCase()),
                              style: AppStyles().catTitleStyle.copyWith(
                                    fontSize: responsiveFontSize,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList();
                      },
                      onChanged: (String? value) {
                        setState(() {
                          dropdownValue = value!;
                          _dropSelectedIndex = dropValueList!.indexOf(value);
                          _selectedIndex = _dropSelectedIndex;

                          if (kDebugMode) {
                            print('Selected index $_dropSelectedIndex');
                            print('DropValue $dropdownValue');
                          }
                        });
                      },
                      items: dropValueList
                          ?.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value.replaceFirst(
                                value[0], value[0].toUpperCase()),
                            style: TextStyle(
                              fontSize: _getResponsiveDimension(context, 16),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Grid container with remaining space
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: _getResponsiveDimension(context, 16),
                ),
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  child: FutureBuilder<List<dynamic>>(
                    future:
                        getFilteredItems(widget.currentGroupId, dropdownValue),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<dynamic>> snapshot) {
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return _buildEmptyState(context);
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return GridView.builder(
                          scrollDirection: Axis.vertical,
                          padding: EdgeInsets.only(
                            bottom: _getResponsiveDimension(context, 80),
                            top: _getResponsiveDimension(context, 16),
                          ),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisSpacing:
                                _getResponsiveDimension(context, 8),
                            mainAxisSpacing:
                                _getResponsiveDimension(context, 10),
                            childAspectRatio: isSmallScreen ? 0.75 : 0.67,
                            crossAxisCount: gridColumns,
                          ),
                          itemCount: snapshot.data!.length + 1,
                          itemBuilder: (context, index) {
                            if (index == snapshot.data!.length) {
                              return _buildAddItemButton(context);
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
            ),
          ],
        ),
      ),
    );
  }

  // Extract empty state to separate method for better readability
  Widget _buildEmptyState(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildAddItemButton(context),
      ],
    );
  }

  // Extract add item button to separate method
  Widget _buildAddItemButton(BuildContext context) {
    final responsiveIconSize = _getResponsiveDimension(context, 60);
    final responsiveFontSize = _getResponsiveDimension(context, 14);

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
          iconSize: responsiveIconSize,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddItemScreen(
                  currentCategory:
                      AppCategories().categoryFromString(dropdownValue)!,
                  currentGroupId: widget.currentGroupId,
                ),
              ),
            ).then((_) {
              setState(() {});
            });
          },
        ),
        Text(
          'Add Item',
          style: TextStyle(
            fontSize: responsiveFontSize,
            color: AppStyles().getPrimaryColor(),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    BoxManager().itemBox.listenable().removeListener(_onItemsChanged);
    super.dispose();
  }
}
