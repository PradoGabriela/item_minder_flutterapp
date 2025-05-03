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
  List<int> pendingSyncsID;

  @HiveField(7)
  List<int> shoppingListID;

  @HiveField(8)
  List<String> categoriesNames;

  @HiveField(9)
  String lastUpdatedBy;

  @HiveField(10)
  String lastUpdatedDateString;

  @HiveField(11)
  String createdByDeviceId;

  AppGroup({
    required this.groupID,
    required this.groupName,
    required this.members,
    required this.createdBy,
    required this.groupIconUrl,
    required this.itemsID,
    required this.pendingSyncsID,
    required this.shoppingListID,
    required this.categoriesNames,
    required this.lastUpdatedBy,
    required this.lastUpdatedDateString,
    required this.createdByDeviceId,
  });
}
