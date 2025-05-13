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
    Categories.livingroom: ["deodorizer", "bulbs", "decorative items"],
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
    Categories.laundryroom: [
      "liquid detergent",
      "gel detergent",
      "laundry tablets",
      "powder detergent",
      "dryer sheets",
      "fabric spray",
      "stain remover",
      "fabric softener",
      "laundry bleach",
      "washing cleaner",
    ],
    Categories.pets: [
      "canned dog food",
      "dry dog food",
      "canned cat food",
      "dry cat food",
      "pet treats",
      "pet toys",
      "birds food",
      "fish food",
      "pet medicine",
      "pet grooming supplies",
      "pet shampoo",
      "pet litter",
      "pet waste bags",
      "pet training pads"
    ],
    Categories.office: [
      "printer paper",
      "ink cartridges",
      "pen",
      "folders",
      "sticky notes",
      "highlighters",
      "tape",
      "scissors",
      "envelopes",
    ],
    Categories.outdoor: [
      "insect repellent",
      "grill charcoal",
      "outdoor lights",
      "bin bags",
    ],
    Categories.storage: ["storage box", "shelf", "labels"],
    Categories.carmaintenance: [
      "car cleaner",
      "windshield fluid",
      "tire cleaner",
      "car wax",
      "car freshener",
      "engine oil"
    ],
    Categories.garage: [
      "tools",
      "storage rack",
      "safety gear",
      "extension cord",
      "ladder",
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
      "gardeting gloves",
      "mulch",
      "soil",
      "planters",
    ],
    Categories.diningroom: [
      "tablecloth",
      "napkins",
      "placemats",
      "candles",
    ],
    Categories.nursery: [
      "diapers",
      "baby wipes",
      "baby lotion",
      "baby shampoo",
      "baby powder",
      "infant formula",
      "baby food pouches",
    ],
    Categories.playroom: [
      "toys",
      "play mat",
      "art supplies",
      "puzzles",
      "books",
      "craft materials",
      "building blocks",
      "sports equipment"
    ],
    Categories.gym: [
      "dumbbells",
      "kettlebell",
      "yoga mat",
      "exercise bike",
      "treadmill",
      "resistance bands",
      "weights",
      "jump rope",
      "exercise ball"
    ],
    Categories.studyroom: [
      "desk",
      "chair",
      "bookshelf",
      "desk lamp",
      "stationery",
      "file organizer",
    ],
    Categories.pantry: [
      "canned food",
      "spices",
      "snacks",
      "baking supplies",
      "condiments",
      "rice",
      "oats",
      "flour",
      "pasta",
      "cereal",
      "sugar",
      "salt",
      "muesli",
      "sauces",
      "oil",
      "wine vinegar"
    ],
    Categories.kidsschool: [
      "backpack",
      "lunchbox",
      "school stationery",
      "textbooks",
      "art supplies",
      "sports equipment",
      "school uniform",
      "calculator",
      "pencil case",
      "water bottle",
      "school shoes"
    ],
    Categories.medicines: [
      "pain reliever",
      "cold medicine",
      "allergy medicine",
      "band-aids",
      "antiseptic cream",
      "thermometer",
      "pills",
      "first aid kit",
      "vitamins",
      "cough syrup",
      "stomach medicine"
    ],
    Categories.cleaningsupplies: [
      "all-purpose cleaner",
      "glass cleaner",
      "disinfectant wipes",
      "scrub brushes",
      "mop",
      "broom",
      "dustpan",
      "vacuum cleaner",
      "sponges"
    ],
    Categories.other: [
      "miscellaneous items",
      "seasonal items",
      "holiday decorations",
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
