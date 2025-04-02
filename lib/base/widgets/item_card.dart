import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';
import 'package:item_minder_flutterapp/base/widgets/bottom_buttons.dart';

class ItemCard extends StatefulWidget {
  final String itemType;
  final int itemQuantity;
  final String itemImgURL;
  final dynamic myItem;

  ItemCard({
    required this.itemType,
    required this.itemQuantity,
    required this.itemImgURL,
    required this.myItem,
  });

  @override
  _ItemCardState createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  bool _isHolding = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(89, 116, 114, 114), // Shadow color adjustment
            offset: Offset(5, 5), // Position the shadow to the right and bottom
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
          onDoubleTap: () {
            setState(() {
              _isHolding = true;
            });
            if (kDebugMode) {
              print('double tapping');
            }
          },
          onTapCancel: () {
            setState(() {
              _isHolding = false;
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
                        Text(widget.itemType,
                            style: AppStyles().titleStyle,
                            textAlign: TextAlign.center),
                        Container(
                          height: constraints.maxHeight *
                              0.5, // 50% of the parent's height
                          decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: AppStyles().getPrimaryColor(),
                                    width: 3)),
                            image: DecorationImage(
                              image: AssetImage(widget.itemImgURL),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 28,
                          child: AppBottomButtons(passItem: widget.myItem),
                        )
                      ],
                    );
                  },
                ),
              ),
              if (_isHolding)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppStyles()
                          .getSecondaryColor(), // Tint color with opacity
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
