import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/group.dart';
import 'package:item_minder_flutterapp/base/managers/notification_manager.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/notification.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/shopping.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:item_minder_flutterapp/base/managers/box_manager.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/item.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:item_minder_flutterapp/device_id.dart';
import 'package:item_minder_flutterapp/listeners/firebase_listeners.dart';
import 'package:item_minder_flutterapp/screens/starter_screen.dart';
import 'package:item_minder_flutterapp/services/connectivity_service.dart';
import 'package:item_minder_flutterapp/firebase_options.dart';
import 'package:item_minder_flutterapp/base/managers/group_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DeviceId().initId();
  await Hive.initFlutter();
  Hive.registerAdapter(AppItemAdapter());
  Hive.registerAdapter(AppNotificationAdapter());
  Hive.registerAdapter(AppShoppingAdapter());
  Hive.registerAdapter(AppGroupAdapter());

  NotificationManager().initializeNotifications();
  NotificationManager().checkNotificationPermission();

  await BoxManager().openBoxes();

// In main.dart
  GroupManager().debugTrackAllGroupStatuses('APP_STARTUP');

  // ✅  DEBUG: Check group statuses BEFORE Firebase setup
  debugPrint('🔍 Group statuses BEFORE Firebase initialization:');
  final groups = BoxManager().groupBox.values.toList();
  for (final group in groups) {
    debugPrint('   Group ${group.groupName}: isOnline=${group.isOnline}');
  }

  // Check if Firebase is already initialized
  // Safe initialization
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('🔥 Firebase initialized successfully');
    }
  } catch (e) {
    debugPrint('❌ Firebase initialization error: $e');
  }

  // ✅ DELAY: Setup listeners AFTER ensuring local data is stable
  await Future.delayed(Duration(milliseconds: 500)); // Small delay

  debugPrint('🔍 Group statuses BEFORE setting up listeners:');
  for (final group in groups) {
    debugPrint('   Group ${group.groupName}: isOnline=${group.isOnline}');
  }

  ConnectivityService().setupConnectivityListener();
  FirebaseListeners().setupFirebaseListeners(); // Setup Firebase listeners

  runApp(const MyApp());
}

// ✅ FIXED: Convert to StatefulWidget for proper lifecycle management
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAppState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // ✅ Properly dispose BoxManager without recursion
    BoxManager().dispose();
    super.dispose();
  }

  /// Initialize app state and preserve group online statuses
  void _initializeAppState() {
    debugPrint('🚀 App starting - preserving group online statuses');

    // Log current group statuses for debugging
    final groups = GroupManager().getHiveGroups();
    for (final group in groups) {
      debugPrint(
          '📱 Group ${group.groupName} startup status: isOnline=${group.isOnline}');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint('📱 App resumed - checking group statuses');
        _checkGroupStatuses();
        break;
      case AppLifecycleState.paused:
        debugPrint('📱 App paused - checking if groups are being set offline');

        // ❌ CHECK: Look for code like this that might be setting groups offline
        final groups = GroupManager().getHiveGroups();
        for (final group in groups) {
          debugPrint(
              '   Group ${group.groupName} status during pause: ${group.isOnline}');
          // ❌ PROBLEMATIC: Don't do this
          // group.isOnline = false; // This would cause the issue
          // group.save();
        }
        break;
      case AppLifecycleState.detached:
        debugPrint('📱 App terminating - preserving group statuses');

        // ✅ ADD DEBUG: Track group statuses before app closes
        final groups = GroupManager().getHiveGroups();
        for (final group in groups) {
          debugPrint(
              '   Group ${group.groupName} final status: ${group.isOnline}');
        }

        BoxManager().dispose();
        break;
      default:
        break;
    }
  }

  /// Debug method to track group online statuses
  void _checkGroupStatuses() {
    final groups = GroupManager().getHiveGroups();
    for (final group in groups) {
      debugPrint(
          '📊 Group ${group.groupName} status: isOnline=${group.isOnline}');

      // ✅ Following manager pattern - no direct status changes here
      // Status should only change through GroupManager methods
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) {
          return StarterScreen();
        },
      ),
    );
  }
}
