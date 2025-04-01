import 'package:flutter/material.dart';

class AppStyles {
  //UI Palette variables
  static final Color _primaryColor = Colors.amber.shade800;
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
}
