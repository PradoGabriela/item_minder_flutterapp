import 'package:flutter/material.dart';

class AppStyles {
  //UI Palette variables
  static final Color _primaryColor = Color(0xFFFF914D);
  static final Color _secondaryColor =
      const Color.from(alpha: 0.5, red: 1, green: 0.569, blue: 0);
  static final TextStyle _titleStyle = TextStyle(
    fontSize: 12.0,
    color: _primaryColor,
  );
  static final TextStyle _catTitleStyle = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold, // Example font weight
    color: _primaryColor,
  );
  //Text Styles
  static final TextStyle _dropTextStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold, // Example font weight
    color: Colors.white,
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

  Color getSecondaryColor() {
    return _secondaryColor;
  }
}
