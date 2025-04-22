import 'package:flutter/material.dart';

class AppStyles {
  //UI Palette variables
  static const Color _primaryColor = Color(0xFFFF914D);
  static final Color _secondaryColor = Color.fromRGBO(255, 145, 77, 0.5);
  static const TextStyle _titleStyle = TextStyle(
    fontWeight: FontWeight.bold, // Example font weight
    fontSize: 12.0,
    color: _primaryColor,
  );
  static const TextStyle _catTitleStyle = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.bold, // Example font weight
    color: _primaryColor,
  );
  //Text Styles
  static const TextStyle _dropTextStyle = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.bold, // Example font weight
    color: Colors.white,
  );

  static const TextStyle _formTextStyle = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.bold, // Example font weight
    color: _primaryColor,
  );

  static const TextStyle _formFillTextStyle = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.bold, // Example font weight
    color: Colors.black,
  );
  //Text Styles
  static const TextStyle _appBartTextStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold, // Example font weight
    color: Colors.black,
  );

  final ButtonStyle _buttonStyle = ElevatedButton.styleFrom(
    backgroundColor: _primaryColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(32),
      side: const BorderSide(color: _primaryColor, width: 3),
    ),
  );

  TextStyle buttonTexStyle = const TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold, // Example font weight
    color: Colors.white,
  );

  //Singleton instance
  static final AppStyles _instance = AppStyles._internal();

  //Private constructor
  AppStyles._internal();

  //Factory constructor to return the same instance
  factory AppStyles() {
    return _instance;
  }

//Getters
  Color getPrimaryColor() {
    return _primaryColor;
  }

  TextStyle get titleStyle {
    return _titleStyle;
  }

  TextStyle get catTitleStyle {
    return _catTitleStyle;
  }

  TextStyle get dropTextStyle {
    return _dropTextStyle;
  }

  TextStyle get formTextStyle {
    return _formTextStyle;
  }

  TextStyle get formFieldStyle {
    return _formFillTextStyle;
  }

  TextStyle get appBarTextStyle {
    return _appBartTextStyle;
  }

  Color getSecondaryColor() {
    return _secondaryColor;
  }

  ButtonStyle get buttonStyle {
    return _buttonStyle;
  }

  TextStyle get buttonTextStyle {
    return buttonTexStyle;
  }
}
