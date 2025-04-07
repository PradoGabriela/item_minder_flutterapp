import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';
import 'package:item_minder_flutterapp/base/widgets/edit_widget.dart';

class EditItemScreen extends StatelessWidget {
  final dynamic passItem;
  const EditItemScreen({super.key, required this.passItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View/Edit Item'),
        backgroundColor: Colors.white,
        titleTextStyle: AppStyles().appBarTextStyle,
        centerTitle: true,
      ),
      body: EditWidget(passItem: passItem),
    );
  }
}
