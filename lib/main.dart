import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/bottom_nav_bar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:item_minder_flutterapp/base/box_manager.dart';
import 'package:item_minder_flutterapp/base/item.dart';

Future<void> main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(AppItemAdapter());

  await BoxManager().openBox();
  // Retrieve all AppItems from the box
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false, home: BottomNavBar());
  }
}
