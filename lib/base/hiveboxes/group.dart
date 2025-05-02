// This file defines the AppGroup class, which represents a group in the application.
import 'package:hive/hive.dart';

part 'group.g.dart'; // This part directive allows for the code generation

@HiveType(typeId: 5)
class AppGroup extends HiveObject {
  @HiveField(0)
  String groupID;

  @HiveField(1)
  String groupName;

  @HiveField(2)
  List<String> members;

  @HiveField(3)
  String createdBy;

  @HiveField(4)
  String groupIconUrl;

//Adding all the boxes to the group
  @HiveField(5)
  List<int> itemsID;

  @HiveField(6)
  List<int> notificationsID;

  @HiveField(7)
  List<int> pendingSyncsID;

  @HiveField(8)
  List<int> shoppingListID;

  @HiveField(9)
  List<String> categoriesNames;

  @HiveField(10)
  String lastUpdatedBy;

  @HiveField(11)
  String lastUpdatedDateString;

  @HiveField(12)
  String createdByDeviceId;

  AppGroup({
    required this.groupID,
    required this.groupName,
    required this.members,
    required this.createdBy,
    required this.groupIconUrl,
    required this.itemsID,
    required this.notificationsID,
    required this.pendingSyncsID,
    required this.shoppingListID,
    required this.categoriesNames,
    required this.lastUpdatedBy,
    required this.lastUpdatedDateString,
    required this.createdByDeviceId,
  });
}
