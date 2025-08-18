// This file defines the AppGroup class, which represents a group in the application.
import 'package:flutter/material.dart';
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
  List<int> shoppingListID;

  @HiveField(7)
  List<String> categoriesNames;

  @HiveField(8)
  String lastUpdatedBy;

  @HiveField(9)
  String lastUpdatedDateString;

  @HiveField(10)
  String createdByDeviceId;

  @HiveField(11)
  bool isOnline = false;

  @HiveField(12)
  String memberName;

  AppGroup({
    required this.groupID,
    required this.groupName,
    required this.members,
    required this.createdBy,
    required this.groupIconUrl,
    required this.itemsID,
    required this.shoppingListID,
    required this.categoriesNames,
    required this.lastUpdatedBy,
    required this.lastUpdatedDateString,
    required this.createdByDeviceId,
    required isOnline,
    required this.memberName,
  });

  static AppGroup fromJson(Map<String, dynamic> groupData) {
    return AppGroup(
      groupID: groupData['groupID'] ?? '',
      groupName: groupData['groupName'] ?? '',
      members: _extractListFromDynamic<String>(groupData['members']),
      createdBy: groupData['createdBy'] ?? '',
      groupIconUrl: groupData['groupIconUrl'] ?? '',
      itemsID: _extractListFromDynamic<String>(groupData['itemsID']),
      shoppingListID: _extractListFromDynamic<int>(groupData['shoppingListID']),
      categoriesNames:
          _extractListFromDynamic<String>(groupData['categoriesNames']),
      lastUpdatedBy: groupData['lastUpdatedBy'] ?? '',
      lastUpdatedDateString:
          groupData['lastUpdatedDateString'] ?? DateTime.now().toString(),
      createdByDeviceId:
          groupData['createdByDeviceId'] ?? DeviceId().getDeviceId(),
      isOnline: groupData['isOnline'] ?? false,
      memberName: groupData['memberName'] ?? '',
    );
  }

  /**
   * Helper method to safely extract List<T> from Firebase data
   * 
   * Firebase can return arrays as either List or Map depending on the structure.
   * This method handles both formats to prevent type casting errors.
   */
  static List<T> _extractListFromDynamic<T>(dynamic data) {
    try {
      if (data == null) {
        return <T>[];
      }

      // Handle List format (standard array)
      if (data is List) {
        if (T == String) {
          return data.map((item) => item.toString()).cast<T>().toList();
        } else if (T == int) {
          return data
              .map((item) => int.tryParse(item.toString()) ?? 0)
              .cast<T>()
              .toList();
        }
        return List<T>.from(data);
      }

      // Handle Map format (Firebase sometimes converts arrays to maps)
      if (data is Map) {
        if (T == String) {
          return data.values.map((item) => item.toString()).cast<T>().toList();
        } else if (T == int) {
          return data.values
              .map((item) => int.tryParse(item.toString()) ?? 0)
              .cast<T>()
              .toList();
        }
        return data.values.cast<T>().toList();
      }

      // Fallback for unexpected formats
      return <T>[];
    } catch (e) {
      debugPrint('❌ Error extracting list from dynamic data: $e');
      return <T>[];
    }
  }
}
