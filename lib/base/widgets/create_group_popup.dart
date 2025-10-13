import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:item_minder_flutterapp/base/managers/categories_manager.dart';
import 'package:item_minder_flutterapp/base/managers/group_manager.dart';
import 'package:item_minder_flutterapp/base/res/media.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';

class CreateGroupPopup {
  static Future<bool> show({
    required BuildContext context,
    String title = "Create Group",
  }) async {
    final _userNameController = TextEditingController();
    final _groupNameController = TextEditingController();
    int _selectedIcon = 0;

    bool success = false;
    List<String> categories = AppCategories().categoriesDB;
    List<String> selectedCategories = [];
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool isLoading = false;

            return MediaQuery.removeViewInsets(
              removeBottom: true,
              context: context,
              child: Dialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Select Icon:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      ExpandableCarousel(
                        options: ExpandableCarouselOptions(
                          autoPlay: false,
                          onPageChanged: (index, reason) =>
                              setState(() => _selectedIcon = index),
                        ),
                        items: AppMedia().iconsGroupList.map((i) {
                          return Builder(
                            builder: (BuildContext context) {
                              return Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                                  decoration: BoxDecoration(
                                      color: AppStyles().getPrimaryColor(),
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Image.asset(i,
                                      fit: BoxFit.contain,
                                      width: 100,
                                      height: 100));
                            },
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 20), //Group Name
                      TextField(
                        controller: _groupNameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          labelText: 'Insert Group Name',
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9]')),
                          FilteringTextInputFormatter.deny(RegExp(r'\s')),
                        ],
                        maxLength: 12,
                      ),
                      SizedBox(height: 20),
                      //User Name field
                      TextField(
                        controller: _userNameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          labelText: 'Insert Your User Name',
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9]')),
                          FilteringTextInputFormatter.deny(RegExp(r'\s')),
                        ],
                        maxLength: 12,
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Select Categories:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                              onPressed: () => showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return Container(
                                        color: Colors.white,
                                        padding: EdgeInsets.all(20),
                                        child: Column(
                                          children: [
                                            // question icon
                                            Icon(Icons.question_mark_rounded,
                                                size: 50,
                                                color: AppStyles()
                                                    .getPrimaryColor()),
                                            SizedBox(height: 12),
                                            Text(
                                              "Choose a category to generate template items for quick access.\nYou can customize these items and categories later.\nThis feature allows you to create and reuse templates efficiently.Example:",
                                              style: TextStyle(
                                                height:
                                                    1.5, // Adjust this value (1.0 is default, 1.5 adds 50% more spacing)
                                              ),
                                            ),
                                            SizedBox(height: 12),
                                            Container(
                                              height: 260,
                                              width: 320,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black26,
                                                    blurRadius: 10,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
                                                image: DecorationImage(
                                                  image: AssetImage(AppMedia()
                                                      .tutorialGroupImg),
                                                  fit: BoxFit.cover,
                                                ),
                                                border: Border.all(width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                              icon: Icon(
                                Icons.info_outline,
                                color: AppStyles().getPrimaryColor(),
                                size: 32,
                              )),
                        ],
                      ),
                      SizedBox(height: 6),
                      //Grid of selectable categories
                      Flexible(
                        child: GridView.builder(
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 2,
                          ),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final isSelected =
                                selectedCategories.contains(category);
                            final emoji = AppCategories().categoryEmojis[
                                    AppCategories()
                                        .categoryFromString(category)] ??
                                '';

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    selectedCategories.remove(category);
                                  } else {
                                    selectedCategories.add(category);
                                  }
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.all(4),
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.black, width: 2),
                                  color: isSelected
                                      ? AppStyles().getPrimaryColor()
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    "$emoji $category".replaceFirst(
                                        category[0], category[0].toUpperCase()),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          //text showing the selected categories and an a button to select all or unselect all
                          Text("Selected ${selectedCategories.length}"),
                          TextButton(
                            onPressed: () => setState(() {
                              if (selectedCategories.length ==
                                  categories.length) {
                                // All selected → unselect all
                                selectedCategories.clear();
                              } else {
                                // Not all selected → select all
                                selectedCategories = List.from(categories);
                              }
                            }),
                            child: Text(
                              selectedCategories.length == categories.length
                                  ? "Unselect All"
                                  : "Select All",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton(
                            style: AppStyles().raisedButtonStyle.copyWith(
                                  minimumSize:
                                      WidgetStateProperty.all(Size(80, 60)),
                                ),
                            child: Icon(
                              FontAwesomeIcons.xmark,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: isLoading
                                ? null
                                : () {
                                    Navigator.pop(context);
                                  },
                          ),
                          ElevatedButton(
                            style: AppStyles().raisedButtonStyle.copyWith(
                                  minimumSize:
                                      WidgetStateProperty.all(Size(80, 60)),
                                ),
                            onPressed: isLoading
                                ? null
                                : () async {
                                    final userName =
                                        _userNameController.text.trim();
                                    final groupName =
                                        _groupNameController.text.trim();

                                    if (userName.isEmpty || groupName.isEmpty) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Please fill all fields')));
                                      }
                                      return;
                                    }

                                    setState(() => isLoading = true);
                                    try {
                                      success = await GroupManager()
                                          .createGroup(
                                              groupName,
                                              userName,
                                              AppMedia().iconsGroupList[
                                                  _selectedIcon],
                                              selectedCategories,
                                              userName);
                                    } finally {
                                      if (context.mounted) {
                                        setState(() => isLoading = false);
                                        Navigator.pop(context, success);
                                      }
                                    }
                                  },
                            child: isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(
                                    FontAwesomeIcons.check,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).then((value) {
      // Check if the dialog was closed with a value
      return value ?? false;
    });

    return success;
  }
}
