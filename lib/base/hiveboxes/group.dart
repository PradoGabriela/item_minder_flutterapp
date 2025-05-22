// This file defines the AppGroup class, which represents a group in the application.
import 'package:hive/hive.dart';
import 'package:item_minder_flutterapp/device_id.dart';

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
  List<String> itemsID;

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

  static AppGroup fromJson(Map<String, dynamic> groupData) {
    return AppGroup(
      groupID: groupData['groupID'] ?? '',
      groupName: groupData['groupName'] ?? '',
      members: List<String>.from(groupData['members'] ?? []),
      createdBy: groupData['createdBy'] ?? '',
      groupIconUrl: groupData['groupIconUrl'] ?? '',
      itemsID: List<String>.from(groupData['itemsID'] ?? []),
      pendingSyncsID: List<int>.from(groupData['pendingSyncsID'] ?? []),
      shoppingListID: List<int>.from(groupData['shoppingListID'] ?? []),
      categoriesNames: List<String>.from(groupData['categoriesNames'] ?? []),
      lastUpdatedBy: groupData['lastUpdatedBy'] ?? '',
      lastUpdatedDateString:
          groupData['lastUpdatedDateString'] ?? DateTime.now().toString(),
      createdByDeviceId:
          groupData['createdByDeviceId'] ?? DeviceId().getDeviceId(),
    );
  }
}
