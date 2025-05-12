import 'package:item_minder_flutterapp/base/hiveboxes/item.dart';
import 'package:item_minder_flutterapp/base/managers/item_manager.dart';
import 'package:item_minder_flutterapp/base/managers/type_items_manager.dart';
import 'package:item_minder_flutterapp/base/res/media.dart';

class TemplatesManager {
  static final TemplatesManager _instance = TemplatesManager._internal();

  factory TemplatesManager() {
    return _instance;
  }

  TemplatesManager._internal();

  final int defaultQuantity = 0;
  final int defaultMinQuantity = 1;
  final int defaultMaxQuantity = 4;
  final double defaultPrice = 0.0;

  void addTemplateItemsToGroup(
      {required String groupID, required List<String> categoriesNames}) {
    for (String category in categoriesNames) {
      List<String> itemsTypes =
          TypeItemsManager().getItemTypesByCategory(category);
      for (String itemType in itemsTypes) {
        // Create a new item with default values
        ItemManager().addCustomItem(
          brandName: "No Brand Provided",
          description: "No Description Provided",
          iconUrl: AppMedia().getItemIcon(itemType.toLowerCase()),
          imageUrl: "",
          category: category.toLowerCase(),
          price: defaultPrice,
          type: itemType,
          quantity: defaultQuantity,
          minQuantity: defaultMinQuantity,
          maxQuantity: defaultMaxQuantity,
          isAutoadd: true,
          groupID: groupID,
        );
      }
    }
  }
}
