import 'package:hive/hive.dart';
part 'notification.g.dart';

@HiveType(typeId: 1) // Define a unique typeId for this class
class AppNotification extends HiveObject {
  @HiveField(0)
  DateTime time = DateTime.now();

  @HiveField(1)
  String information = "test Notification";

  AppNotification();
  AppNotification.custom(this.information);
}
