import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/res/media.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';
import 'package:item_minder_flutterapp/base/widgets/add_item_selector.dart';

class AddWidget extends StatefulWidget {
  final dynamic currentCategory;
  final String? currentGroupId;

  const AddWidget(
      {super.key, required this.currentCategory, required this.currentGroupId});

  @override
  State<AddWidget> createState() => _AddWidgetState();
}

class _AddWidgetState extends State<AddWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles().getSecondaryColor(),
      body: ListView(
        children: [
          Container(
            width: 380,
            height: 760,
            margin: const EdgeInsetsDirectional.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(
                      89, 116, 114, 114), // Shadow color adjustment
                  offset: Offset(
                      5, 5), // Position the shadow to the right and bottom
                  blurRadius: 1, // Control the blur effect
                ),
              ],
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: Colors.black, width: 3),
              ),
              elevation: 0, // Set elevation to 0 to avoid default shadow
              color: Colors.white,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(AppMedia().logo),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      //First Menu
                      AddItemSelector(
                          currentCategory: widget.currentCategory,
                          currentGroupId: widget.currentGroupId),
                    ],
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
