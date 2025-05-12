import 'package:item_minder_flutterapp/base/categories.dart';

class TypeItemsManager {
  static final TypeItemsManager _instance = TypeItemsManager._internal();

  factory TypeItemsManager() {
    return _instance;
  }
  TypeItemsManager._internal();
  Map<Categories, List<String>> itemTypes = {
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
    Categories.livingRoom: ["deodorizer", "bulbs", "decorative items"],
    Categories.bedroom: ["tissue", "pillow", "blanket", "bed sheet"],
    Categories.kitchen: [
      "vinegar",
      "kitchen tissue",
      "dish soap",
      "sponges",
      "dishwasher detergent",
      "oven cleaner",
      "kitchen cleaner",
      "baking soda",
      "aluminium foil",
      "plastic wrap",
      "food storage bags",
      "freezer bags",
      "oven trays",
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

  List<String> getItemTypesByCategory(String category) {
    //get filtered list if itemstype for  category string
    List<String> filteredList = [];
    for (var entry in itemTypes.entries) {
      if (entry.key.toString().replaceAll("Categories.", "") ==
          category.toLowerCase()) {
        filteredList = entry.value;
        break;
      }
    }
    return filteredList;
  }
}
