import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/managers/notification_manager.dart';
import 'package:item_minder_flutterapp/base/managers/shopping_manager.dart';
import 'package:item_minder_flutterapp/base/notification.dart';
import 'package:item_minder_flutterapp/base/shopping.dart';
import 'package:item_minder_flutterapp/base/widgets/bottom_nav_bar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:item_minder_flutterapp/base/box_manager.dart';
import 'package:item_minder_flutterapp/base/item.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(AppItemAdapter());
  Hive.registerAdapter(AppNotificationAdapter());
  Hive.registerAdapter(AppShoppingAdapter());

  NotificationManager().initializeNotifications();
  NotificationManager().checkNotificationPermission();

  await BoxManager().openBoxes();
  ShoppingManager().initShoppingList(); // Initialize the shopping list
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Retrieve all AppItems from the box
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) {
          return const Scaffold(
            body: BottomNavBar(),
          );
        },
      ),
    );
  }
}
