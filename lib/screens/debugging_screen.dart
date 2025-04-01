import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/box_manager.dart';
import 'package:item_minder_flutterapp/base/item_manager.dart';

class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  BoxManager().clearAllBox();
                },
                child: const Text("Clear database")),
            ElevatedButton(
                onPressed: () {
                  ItemManager().addMiscItem();
                },
                child: const Text("Add misc item ")),
          ],
        ),
      ),
    );
  }
}
