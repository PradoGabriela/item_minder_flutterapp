import 'package:flutter/material.dart';

class SnackManager {
  static final SnackManager _instance = SnackManager._internal();

  factory SnackManager() {
    return _instance;
  }

  SnackManager._internal();

  void showSnackBar(BuildContext context, String message) {
    // Implement your snackbar logic heres
    // For example, using Flutter's ScaffoldMessenger:
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
