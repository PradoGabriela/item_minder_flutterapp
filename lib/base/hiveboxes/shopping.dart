import 'package:hive/hive.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/item.dart';
part 'shopping.g.dart';

@HiveType(typeId: 2) // Define a unique typeId for this class
class AppShopping extends HiveObject {
  @HiveField(0)
  List<AppItem> items; // List to store items

  @HiveField(1)
  String groupID = ''; // Group ID for the shopping list

  AppShopping({required this.groupID}) : items = [];
  AppShopping.custom({List<AppItem>? items}) : items = items ?? [];
}
