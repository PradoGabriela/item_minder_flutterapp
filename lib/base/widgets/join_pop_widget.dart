import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:item_minder_flutterapp/base/managers/group_manager.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';

class JoinCustomPopup {
  static Future<bool> show({
    required BuildContext context,
    String title = "Join a Group",
    String cancelText = "Cancel",
    String confirmText = "Join",
  }) async {
    final _userNameController = TextEditingController();
    final _groupCodeController = TextEditingController();
    bool success = false;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool isLoading = false;

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _userNameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        labelText: 'Insert Your User Name',
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9]')),
                        FilteringTextInputFormatter.deny(RegExp(r'\s')),
                      ],
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _groupCodeController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        labelText: 'Insert Group Code',
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9]')),
                        FilteringTextInputFormatter.deny(RegExp(r'\s')),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton(
                          style: AppStyles().raisedButtonStyle.copyWith(
                                minimumSize:
                                    WidgetStateProperty.all(Size(80, 60)),
                              ),
                          child: Icon(
                            FontAwesomeIcons.xmark,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: isLoading
                              ? null
                              : () {
                                  Navigator.pop(context);
                                },
                        ),
                        ElevatedButton(
                          style: AppStyles().raisedButtonStyle.copyWith(
                                minimumSize:
                                    WidgetStateProperty.all(Size(80, 60)),
                              ),
                          child: isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  FontAwesomeIcons.check,
                                  color: Colors.white,
                                  size: 30,
                                ),
                          onPressed: isLoading
                              ? null
                              : () async {
                                  final userName =
                                      _userNameController.text.trim();
                                  final groupCode =
                                      _groupCodeController.text.trim();

                                  if (userName.isEmpty || groupCode.isEmpty) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                                  'Please fill all fields')));
                                    }
                                    return;
                                  }

                                  setState(() => isLoading = true);
                                  try {
                                    success = await GroupManager().joinGroup(
                                        groupCode, userName, context);
                                  } finally {
                                    if (context.mounted) {
                                      setState(() => isLoading = false);
                                      Navigator.pop(context, success);
                                    }
                                  }
                                },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((value) {
      // Check if the dialog was closed with a value
      return value ?? false;
    });

    return success;
  }
}
