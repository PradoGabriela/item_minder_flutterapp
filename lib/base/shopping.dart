import 'package:hive/hive.dart';
import 'package:item_minder_flutterapp/base/item.dart';
part 'shopping.g.dart';

@HiveType(typeId: 2) // Define a unique typeId for this class
class AppShopping extends HiveObject {
  @HiveField(0)
  List<AppItem> items; // List to store items

  AppShopping() : items = [];
  AppShopping.custom({List<AppItem>? items}) : items = items ?? [];
}
