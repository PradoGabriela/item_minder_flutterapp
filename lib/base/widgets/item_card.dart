import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';
import 'package:item_minder_flutterapp/base/widgets/bottom_buttons.dart';
import 'package:item_minder_flutterapp/screens/edit_item_screen.dart';

class ItemCard extends StatefulWidget {
  final String itemType;
  final int itemQuantity;
  final String itemIconUrl;
  final dynamic myItem;

  ItemCard({
    required this.itemType,
    required this.itemQuantity,
    required this.itemIconUrl,
    required this.myItem,
  });

  @override
  _ItemCardState createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(89, 116, 114, 114), // Shadow color adjustment
            offset: Offset(3, 3), // Position the shadow to the right and bottom
            blurRadius: 1, // Control the blur effect
          ),
        ],
      ),
      child: Material(
        clipBehavior: Clip.hardEdge,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              24), // Use the same border radius as the Card
        ),
        //Tapping Functions
        child: InkResponse(
          onLongPress: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditItemScreen(
                  passItem: widget.myItem,
                ),
              ),
            ).then((_) {
              setState(() {});
            });
          },
          splashColor:
              AppStyles().getSecondaryColor(), // Customize splash color
          highlightColor:
              AppStyles().getSecondaryColor(), // Customize highlight color
          focusColor: AppStyles().getSecondaryColor(), // Customize focus color

          child: Stack(
            children: [
              //Items cards
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                      color: AppStyles().getPrimaryColor(), width: 3),
                ),
                elevation: 0, // Set elevation to 0 to avoid default shadow
                color: Colors.white,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          height: constraints.maxHeight *
                              0.05, // 5% of the parent's height
                        ),
                        Text(
                            widget.itemType[0].toUpperCase() +
                                widget.itemType.substring(1),
                            style: AppStyles().titleStyle,
                            textAlign: TextAlign.center),
                        Text(
                          (widget.myItem.brandName != null &&
                                  widget.myItem.brandName !=
                                      "No Brand Provided")
                              ? widget.myItem.brandName
                              : "",
                          style: AppStyles().titleStyle.copyWith(
                              fontWeight: FontWeight.normal, fontSize: 12),
                        ),
                        Container(
                          height: constraints.maxHeight *
                              0.5, // 50% of the parent's height
                          decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: AppStyles().getPrimaryColor(),
                                    width: 3)),
                            image: DecorationImage(
                              image: AssetImage(widget.itemIconUrl),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: constraints.maxHeight *
                              0.2, // 5% of the parent's height
                          child: AppBottomButtons(passItem: widget.myItem),
                        )
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
