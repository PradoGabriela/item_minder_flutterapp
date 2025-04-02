import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:item_minder_flutterapp/base/box_manager.dart';
import 'package:item_minder_flutterapp/base/notification.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();

//Channel settings
  final String _channelID = "itemID_channel";
  final String _channelName = "item_channel";
  final String _channelDescription = "Items status notifications";

  final String _minNotification = "You have reached the min quantity of ";
  final String _maxNotification = "You have too many of";
  final String _addedShopping =
      "You have added the following item to the shopping list";
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  factory NotificationManager() {
    return _instance;
  }
  NotificationManager._internal();

  void testNotification() {
    AppNotification();
  }

  void newMinNotification(String message) {
    AppNotification notification =
        AppNotification.custom("$_minNotification $message");
    addNotificationToDatabase(notification);
    _showNotification("Low Inventory", "$_minNotification $message");
  }

  void newMAxNotification(String message) {
    AppNotification notification =
        AppNotification.custom("$_maxNotification $message");
    addNotificationToDatabase(notification);
    _showNotification("Stop", "$_minNotification $message");
  }

  void addNotificationToDatabase(AppNotification notification) {
    BoxManager().notificationBox.add(notification);
    if (kDebugMode) {
      print(
          "Notification added: ${notification.toString()}"); // Print the added item
    }
  }

  void initializeNotifications() {
    if (kDebugMode) {
      print("Initializing notifications...");
    }

    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('stack'); // Provide your app icon asset

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    _flutterLocalNotificationsPlugin
        .initialize(initializationSettings)
        .then((_) {
      if (kDebugMode) {
        print("Notification initialization complete.");
      }
    });
  }

  Future<void> checkNotificationPermission() async {
    if (kDebugMode) {
      print("Checking notification permission...");
    }

    if (await Permission.notification.isDenied) {
      if (kDebugMode) {
        print("Notification permission is denied. Requesting permission...");
      }
      await Permission.notification.request();
    } else {
      if (kDebugMode) {
        print("Notification permission is already granted.");
      }
    }
  }

  Future<void> _showNotification(String tittle, String message) async {
    try {
      if (kDebugMode) {
        print("Preparing notification...");
      }

      AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        _channelID, // Notification channel ID
        _channelName, // Channel name
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
      );

      NotificationDetails notificationDetails =
          NotificationDetails(android: androidNotificationDetails);

      await _flutterLocalNotificationsPlugin.show(
        0, // Notification ID
        tittle, // Title
        message, // Message
        notificationDetails,
        payload: 'Hello Notification Payload', // Optional payload
      );

      if (kDebugMode) {
        print("Notification sent successfully.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error sending notification: $e");
      }
    }
  }
}
