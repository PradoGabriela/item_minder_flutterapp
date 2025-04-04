import 'package:flutter/material.dart';

class AppStyles {
  //UI Palette variables
  static const Color _primaryColor = Color(0xFFFF914D);
  static const Color _secondaryColor =
      Color.from(alpha: 0.5, red: 1, green: 0.569, blue: 0);
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
}
