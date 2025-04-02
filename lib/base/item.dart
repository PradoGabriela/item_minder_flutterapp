import 'package:hive/hive.dart';
import 'package:item_minder_flutterapp/base/categories.dart';
import 'package:item_minder_flutterapp/base/res/media.dart';

part 'item.g.dart'; // This part directive allows for the code generation

@HiveType(typeId: 0) // Define a unique typeId for this class
class AppItem extends HiveObject {
  // The AppItem class is a HiveObject, which means it can be stored in a Hive database.
  // This class represents an item in the app with its properties.
  // It includes the brand name, description, image URL, category, and price of the item.
  // The class also includes a static map that associates each category with a list of item types.
  Map<Categories, List<String>> itemType = {
    Categories.bathroom: [
      "shampoo",
      "soap",
      "toothpaste",
      "towel",
      "toilet paper",
      "toothbrush",
      "razor",
      "lotion",
      "conditioner",
      "body wash"
    ],
    Categories.livingRoom: [
      "sofa",
      "tv",
      "coffee table",
      "lamp",
      "bookshelf",
      "rug",
      "curtains",
      "decorative items"
    ],
    Categories.bedroom: ["bed", "pillow", "blanket"],
    Categories.kitchen: ["plate", "cup", "spoon"],
    Categories.office: ["laptop", "notebook", "pen", "stapler"],
    Categories.outdoor: ["tent", "camping gear", "outdoor furniture"],
    Categories.storage: ["storage box", "shelf", "organizer"],
    Categories.carMaintenance: ["oil", "tire", "brake fluid"],
    Categories.garage: ["tools", "workbench", "storage rack"],
    Categories.garden: ["plants", "seeds", "fertilizer"],
    Categories.diningRoom: ["table", "chairs", "tableware"],
    Categories.nursery: ["crib", "toys", "baby monitor"],
    Categories.playroom: ["toys", "games", "play mat"],
    Categories.gym: ["dumbbells", "yoga mat", "exercise bike"],
    Categories.studyRoom: ["desk", "chair", "bookshelf"],
    Categories.pantry: ["canned food", "spices", "snacks"],
    Categories.laundryRoom: ["detergent", "dryer sheets", "ironing board"],
    Categories.workshop: ["tools", "workbench", "safety gear"],
    Categories.kidsSchool: ["backpack", "lunchbox", "stationery"],
    Categories.other: ["miscellaneous items"]
  };
  @HiveField(0)
  String brandName = ""; // Default brand name is an empty string
  @HiveField(1)
  String description = ""; // Default description is an empty string
  @HiveField(2)
  String iconUrl = AppMedia().otherIcon; // Default icon URL is an generic icon
  @HiveField(3)
  String imageUrl = AppMedia().addImgIcon; //Default add image description
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
  bool _isAutoAdd = false; // Default isAutoAdd is false
  DateTime addedDate = DateTime.now(); // Default added date is now
  @HiveField(11)
  String addedDateString =
      DateTime.now().toString(); // Default added date string is now

  /*  String get itemTypeName => itemType[category]!
      .firstWhere((type) => type == description, orElse: () => "Unknown");
 */

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
      this._isAutoAdd); // Custom constructor for AppItem class
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
      this._isAutoAdd); // Custom constructor for AppItem class with date
}
