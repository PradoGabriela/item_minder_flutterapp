import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';
import 'package:item_minder_flutterapp/base/widgets/decrease_button.dart';
import 'package:item_minder_flutterapp/base/widgets/increment_button.dart';

class ItemCard extends StatelessWidget {
  final String itemType;
  final int itemQuantity;
  final String itemImgURL;
  final dynamic myItem;

  ItemCard(
      {required this.itemType,
      required this.itemQuantity,
      required this.itemImgURL,
      required this.myItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color.from(
                alpha: 0.345,
                red: 0.455,
                green: 0.447,
                blue: 0.447), // Shadow color
            offset: Offset(5, 5), // Position the shadow to the right and bottom
            blurRadius: 1, // Control the blur effect
          ),
        ],
      ),
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: AppStyles().getPrimaryColor(), width: 3)),
        elevation: 0, // Set elevation to 0 to avoid default shadow
        color: Colors.white,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(itemType,
                    style: AppStyles().titleStyle, textAlign: TextAlign.center),
                Container(
                  height:
                      constraints.maxHeight * 0.5, // 50% of the parent's height
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: AppStyles().getPrimaryColor(), width: 3)),
                    image: DecorationImage(
                      image: AssetImage(itemImgURL),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(
                  height: 28,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AppDecreaseButton(passItem: myItem),
                      Container(
                          width: 22,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                                color: AppStyles().getPrimaryColor(), width: 1),
                          ),
                          child: Text(
                            itemQuantity.toString(),
                            style: TextStyle(
                                fontSize: 12,
                                color: AppStyles().getPrimaryColor()),
                            textAlign: TextAlign.center,
                          )),
                      AppIncrementButton(passItem: myItem),
                    ],
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
