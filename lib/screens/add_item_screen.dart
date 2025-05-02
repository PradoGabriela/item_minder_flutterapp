import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/categories.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';
import 'package:item_minder_flutterapp/base/widgets/add_widget.dart';

class AddItemScreen extends StatelessWidget {
  final Categories currentCategory;
  final String? currentGroupId;
  const AddItemScreen(
      {super.key, required this.currentCategory, required this.currentGroupId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item'),
        backgroundColor: Colors.white,
        titleTextStyle: AppStyles().appBarTextStyle,
        centerTitle: true,
      ),
      body: AddWidget(
          currentCategory: currentCategory, currentGroupId: currentGroupId),
    );
  }
}
