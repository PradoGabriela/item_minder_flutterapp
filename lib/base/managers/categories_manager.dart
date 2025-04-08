import 'package:item_minder_flutterapp/base/box_manager.dart';
import 'package:item_minder_flutterapp/base/categories.dart';
import 'package:item_minder_flutterapp/base/item.dart';

class AppCategories {
  final List<Categories> _categoriesDB = Categories.values.toList();
  String textToTrim = "Categories.";

  List<String> get categoriesDB {
    List<String> myCategories = [];
    for (var i = 0; i < _categoriesDB.length; i++) {
      String tempCategory =
          _categoriesDB[i].toString().replaceAll(textToTrim, "");
      myCategories.add(tempCategory);
    }
    return myCategories;
  }

  List<Categories> get categoriesDBRaw {
    return Categories.values;
  }

  Future<List<dynamic>> getItemsByCategory(String category) async {
    // Retrieve and filter the items based on the category
    var filteredItems = BoxManager().itemBox.values.where((item) {
      return item.category == category;
    }).toList();

    return filteredItems;
  }
}
