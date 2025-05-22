import 'package:hive/hive.dart';
import 'package:item_minder_flutterapp/base/categories.dart';
import 'package:item_minder_flutterapp/base/managers/type_items_manager.dart';
import 'package:item_minder_flutterapp/base/res/media.dart';
import 'package:item_minder_flutterapp/device_id.dart';

part 'item.g.dart'; // This part directive allows for the code generation

@HiveType(typeId: 0) // Define a unique typeId for this class
class AppItem extends HiveObject {
  // The AppItem class is a HiveObject, which means it can be stored in a Hive database.
  // This class represents an item in the app with its properties.
  // It includes the brand name, description, image URL, category, and price of the item.
  // The class also includes a static map that associates each category with a list of item types.

  @HiveField(0)
  String brandName =
      "No Brand Provided"; // Default brand name is an empty string
  @HiveField(1)
  String description =
      "No Description Provided"; // Default description is an empty string
  @HiveField(2)
  String iconUrl = AppMedia().otherIcon; // Default icon URL is an generic icon
  @HiveField(3)
  String imageUrl = ""; //Default add image description
  @HiveField(4)
  String category = (Categories.bathroom.toString())
      .replaceAll("Categories.", ""); // Default category is "other"
  @HiveField(5)
  double price = 0.0; // Default price is 0.0
  @HiveField(6)
  String type = "miscellaneous item"; // Default type is an empty string
  @HiveField(7)
  int quantity = 3; // Default quantity is 0
  @HiveField(8)
  int minQuantity = 1; // Default minimum quantity is 3
  @HiveField(9)
  int maxQuantity = 4; // Default maximum quantity is 4
  @HiveField(10)
  bool isAutoAdd = false; // Default isAutoAdd is false
  DateTime addedDate = DateTime.now(); // Default added date is now
  @HiveField(11)
  String addedDateString =
      DateTime.now().toString(); // Default added date string is now
  @HiveField(12)
  DateTime lastUpdated = DateTime.now(); // Default last updated date is now
  @HiveField(13)
  String lastUpdatedBy = ""; // Default last updated by is the device ID

  @HiveField(14)
  String groupID = ""; // Default group ID is an empty string

  @HiveField(15)
  String itemID = ""; // Default item ID is an empty string

  AppItem(); // Constructor for AppItem class
  AppItem.custom(
    this.brandName,
    this.description,
    this.iconUrl,
    this.imageUrl,
    this.category,
    this.price,
    this.type,
    this.quantity,
    this.minQuantity,
    this.maxQuantity,
    this.isAutoAdd,
    this.lastUpdated,
    this.lastUpdatedBy,
    this.groupID,
    this.itemID,
  ); // Custom constructor for AppItem class
  AppItem.customWithDate(
      this.brandName,
      this.description,
      this.iconUrl,
      this.imageUrl,
      this.category,
      this.price,
      this.type,
      this.quantity,
      this.minQuantity,
      this.maxQuantity,
      this.lastUpdatedBy,
      this.isAutoAdd,
      this.groupID,
      this.itemID);

  static fromJson(jsonData) {
    // Convert JSON data to AppItem object
    return AppItem.custom(
      jsonData['brandName'] ?? "No Brand Provided",
      jsonData['description'] ?? "No Description Provided",
      jsonData['iconUrl'] ?? AppMedia().otherIcon,
      jsonData['imageUrl'] ?? "",
      jsonData['category'] ?? Categories.bathroom.toString(),
      (jsonData['price'] ?? 0.0).toDouble(),
      jsonData['type'] ?? "miscellaneous item",
      (jsonData['quantity'] ?? 3).toInt(),
      (jsonData['minQuantity'] ?? 1).toInt(),
      (jsonData['maxQuantity'] ?? 4).toInt(),
      (jsonData['isAutoAdd'] ?? false) as bool,
      DateTime.parse(jsonData['lastUpdated'] ?? DateTime.now().toString()),
      jsonData['lastUpdatedBy'] ?? DeviceId().getDeviceId(),
      jsonData['groupID'] ?? "no id provided",
      jsonData['itemID'] ?? "",
    );
  }

  // Custom constructor for AppItem class with date
}
