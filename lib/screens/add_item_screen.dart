import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/categories.dart';
import 'package:item_minder_flutterapp/base/widgets/add_widget.dart';

class AddItemScreen extends StatelessWidget {
  final Categories currentCategory;
  const AddItemScreen({super.key, required this.currentCategory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Item')),
      body: AddWidget(currentCategory: currentCategory),
    );
  }
}
