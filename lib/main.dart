import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/pending_syncs.dart';
import 'package:item_minder_flutterapp/base/managers/notification_manager.dart';
import 'package:item_minder_flutterapp/base/managers/shopping_manager.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/notification.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/shopping.dart';
import 'package:item_minder_flutterapp/base/managers/sync_manager.dart';
import 'package:item_minder_flutterapp/base/widgets/bottom_nav_bar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:item_minder_flutterapp/base/managers/box_manager.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/item.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:item_minder_flutterapp/device_id.dart';
import 'package:item_minder_flutterapp/listeners/firebase_listeners.dart';
import 'package:item_minder_flutterapp/services/connectivity_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DeviceId().initId();
  await Hive.initFlutter();
  Hive.registerAdapter(AppItemAdapter());
  Hive.registerAdapter(AppNotificationAdapter());
  Hive.registerAdapter(AppShoppingAdapter());
  Hive.registerAdapter(PendingSyncsAdapter());

  NotificationManager().initializeNotifications();
  NotificationManager().checkNotificationPermission();

  await BoxManager().openBoxes();
  ShoppingManager().initShoppingList(); // Initialize the shopping list
  // Check if Firebase is already initialized

  // Safe initialization
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
      debugPrint('🔥 Firebase initialized successfully');
    }
  } catch (e) {
    debugPrint('❌ Firebase initialization error: $e');
  }

  ConnectivityService().setupConnectivityListener();
  SyncManager().initSync(); // Initialize sync manager
  FirebaseListeners().setupFirebaseListeners(); // Setup Firebase listeners

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

  void dispose() {
    BoxManager().closeAllBox(); // Close all boxes when the app is disposed
    dispose();
  }
}
