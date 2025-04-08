import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/categories.dart';
import 'package:item_minder_flutterapp/base/item.dart';
import 'package:item_minder_flutterapp/base/managers/categories_manager.dart';
import 'package:item_minder_flutterapp/base/managers/shopping_manager.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';
import 'package:item_minder_flutterapp/base/widgets/bottom_buttons.dart';
import 'package:item_minder_flutterapp/screens/add_item_screen.dart';

class ShoppingWidget extends StatefulWidget {
  const ShoppingWidget({super.key});

  @override
  State<ShoppingWidget> createState() => _ShoppingWidgetState();
}

class _ShoppingWidgetState extends State<ShoppingWidget> {
  List<AppItem> shoppingItems = [];
  Future<List<AppItem>> getShoppingItemsByCategory(String category) async {
    if (category == "All" || category.isEmpty) {
      return ShoppingManager().getShoppingList();
    } else {
      List<AppItem> allItems = await ShoppingManager().getShoppingList();

      return allItems.where((item) => item.category == category).toList();
    }
  }

  Widget _buildItemCard({required AppItem item}) {
    // Print the image URL for debugging
    debugPrint('Image URL: ${item.iconUrl}');

    return Container(
      child: Stack(children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppStyles().getPrimaryColor(), width: 3),
          ),
          elevation: 6, // Set elevation to 0 to avoid default shadow
          color: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 29, vertical: 16),
            child: Row(
              children: [
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: AppStyles().getPrimaryColor(), width: 2),
                          image: DecorationImage(
                            image: AssetImage(item.iconUrl),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            item.type,
                            style: AppStyles().catTitleStyle,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppStyles().getPrimaryColor(),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              item.category,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 28,
                            child: AppBottomButtons(passItem: item),
                          ),
                          SizedBox(height: 10)
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  void _navigateToAddItemScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const AddItemScreen(
                currentCategory: Categories.bathroom,
              )),
    ).then((value) {
      setState(() {}); // Refresh the screen after returning from AddItemScreen
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Shopping List",
            style: AppStyles().catTitleStyle.copyWith(fontSize: 24)),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            width: double.infinity,
            height: 520,
            color: Colors.white,
            child: FutureBuilder<List<AppItem>>(
              // Use the getShoppingItemsByCategory method to fetch items
              future: getShoppingItemsByCategory('All'),
              builder: (BuildContext context,
                  AsyncSnapshot<List<AppItem>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildAddItemPrompt();
                } else {
                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: snapshot.data!.length + 1,
                    itemBuilder: (context, index) {
                      if (index == snapshot.data!.length) {
                        return _buildAddItemPrompt();
                      } else {
                        return _buildItemCard(item: snapshot.data![index]);
                      }
                    },
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddItemPrompt() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            Icons.add_circle,
            color: AppStyles().getPrimaryColor(),
          ),
          iconSize: 60,
          onPressed: _navigateToAddItemScreen, //temp adding screen
        ),
        Text(
          'Add Item',
          style: TextStyle(
            fontSize: 14,
            color: AppStyles().getPrimaryColor(),
          ),
        ),
      ],
    );
  }
}
