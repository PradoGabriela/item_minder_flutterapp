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
      "hand wash",
      "toilet cleaner",
      "toilet paper",
      "toothbrush",
      "razor",
      "lotion",
      "conditioner",
      "body wash",
      "deodorant",
      "wipes",
      "cotton swabs",
      "cotton pads",
      "toilet cleaner disks",
      "air freshener",
    ],
    Categories.livingRoom: [
      "deodorizer",
      "air freshener",
      "tv",
      "bulbs",
      "lamp",
      "bookshelf",
      "rug",
      "curtains",
      "decorative items"
    ],
    Categories.bedroom: ["tissue", "pillow", "blanket", "bed sheet"],
    Categories.kitchen: [
      "vinager",
      "kitchen tissue",
      "dish soap",
      "sponges,"
          "dishwasher detergent",
      "oven cleaner",
      "kitchen cleaner",
      "baking soda",
      "aluminum foil",
      "plastic wrap",
      "food storage bags",
      "freezer bags",
      "kitchen towels",
      "oven mitts",
      "bleach",
      "bin bags",
      "big bin bags"
    ],
    Categories.laundryRoom: [
      "detergent",
      "dryer sheets",
      "ironing board",
      "iron",
      "stain remover",
      "laundry basket",
      "fabric softener",
      "clothes hangers",
      "laundry bags",
      "bleach",
      "lint roller",
      "clothesline"
    ],
    Categories.pets: [
      "dog food",
      "cat food",
      "pet toys",
      "pet grooming supplies",
      "pet bed",
      "pet carrier",
      "pet leash",
      "pet collar",
      "pet treats",
      "pet shampoo",
      "pet litter",
      "pet waste bags",
      "pet first aid kit",
      "pet training pads"
    ],
    Categories.office: [
      "laptop",
      "notebook",
      "pen",
      "stapler",
      "printer",
      "paper",
      "folders",
      "sticky notes",
      "whiteboard",
      "desk organizer",
      "calculator",
      "highlighters",
      "tape",
      "scissors",
      "envelopes",
      "post-it notes",
      "file folders"
    ],
    Categories.outdoor: [
      "tent",
      "camping gear",
      "outdoor furniture",
      "insect repellent",
      "outdoor games",
      "grill",
      "cooler",
      "outdoor lights",
      "bin bags",
      "charcoal"
    ],
    Categories.storage: ["storage box", "shelf", "organizer", "label maker"],
    Categories.carMaintenance: [
      "oil",
      "car cleaner",
      "brake fluid",
      "windshield washer fluid",
      "tire cleaner",
      "car wax",
      "air freshener",
      "battery charger",
      "jumper cables",
      "tire inflator",
      "car vacuum",
      "engine oil",
      "coolant",
      "brake pads",
      "wiper blades"
    ],
    Categories.garage: [
      "tools",
      "workbench",
      "storage rack",
      "toolbox",
      "safety gear",
      "extension cord",
      "ladder",
      "car maintenance tools",
      "work gloves",
      "screwdriver set",
      "wrench set",
      "drill",
      "saw",
      "measuring tape"
    ],
    Categories.garden: [
      "plants",
      "seeds",
      "fertilizer",
      "garden tools",
      "watering can",
      "garden hose",
      "pruning shears",
      "gloves",
      "mulch",
      "soil",
      "planters",
      "garden decor",
      "outdoor furniture"
    ],
    Categories.diningRoom: [
      "table",
      "chairs",
      "tableware",
      "cutlery",
      "tablecloth",
      "napkins",
      "placemats",
      "centerpiece",
      "candles",
      "dinnerware",
      "glassware",
      "serving dishes"
    ],
    Categories.nursery: [
      "crib",
      "toys",
      "baby monitor",
      "diapers",
      "baby clothes",
      "baby wipes",
      "baby lotion",
      "pacifiers",
      "bottles",
      "baby food",
      "baby carrier",
      "baby bath tub",
      "baby stroller"
    ],
    Categories.playroom: [
      "toys",
      "games",
      "play mat",
      "art supplies",
      "puzzles",
      "books",
      "craft materials",
      "play kitchen",
      "building blocks",
      "stuffed animals",
      "outdoor toys",
      "sports equipment"
    ],
    Categories.gym: [
      "dumbbells",
      "yoga mat",
      "exercise bike",
      "treadmill",
      "resistance bands",
      "weights",
      "jump rope",
      "foam roller",
      "exercise ball",
      "fitness tracker",
      "water bottle",
      "gym bag"
    ],
    Categories.studyRoom: [
      "desk",
      "chair",
      "bookshelf",
      "lamp",
      "stationery",
      "whiteboard",
      "corkboard",
      "file organizer",
      "printer",
      "scanner",
      "computer",
      "headphones"
    ],
    Categories.pantry: [
      "canned food",
      "spices",
      "snacks",
      "dry goods",
      "baking supplies",
      "condiments",
      "grains",
      "pasta",
      "cereal",
      "sauces",
      "oils",
      "vinegars"
    ],
    Categories.workshop: [
      "tools",
      "workbench",
      "safety gear",
      "toolbox",
      "screws",
      "nails",
      "wood",
      "paint",
      "sandpaper",
      "sawhorses",
      "clamps",
      "measuring tape"
    ],
    Categories.kidsSchool: [
      "backpack",
      "lunchbox",
      "stationery",
      "textbooks",
      "notebooks",
      "art supplies",
      "sports equipment",
      "school uniform",
      "calculator",
      "pencil case",
      "water bottle",
      "school shoes"
    ],
    Categories.other: [
      "miscellaneous items",
      "random items",
      "unclassified items",
      "odds and ends",
      "various items",
      "assorted items",
      "leftovers",
      "extra items",
      "spare items",
      "junk",
      "clutter"
    ],
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
  bool isAutoAdd = false; // Default isAutoAdd is false
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
      this.isAutoAdd); // Custom constructor for AppItem class
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
      this.isAutoAdd); // Custom constructor for AppItem class with date
}
