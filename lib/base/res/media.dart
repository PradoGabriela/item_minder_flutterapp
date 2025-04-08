import 'package:flutter/foundation.dart';

class AppMedia {
  static const String _basePath = 'assets/images';
  static const String _iconsBasePath = 'assets/icons';
  static const String _logo = '$_basePath/logo.png';
  static const String _logoTop = '$_basePath/logoTopPage.png';
  static const String _logoText = '$_basePath/logoText.png';

  //Icons for items
  static const String _otherIcon = '$_iconsBasePath/logo.png';
  static const String _addImgIcon = '$_iconsBasePath/logo.png';

  //Images for Items
  static const String bed = '$_basePath/bed.png';

  String get logo => _logo;
  String get logoText => _logoText;
  String get logoTop => _logoTop;
  String get otherIcon => _otherIcon;
  String get addImgIcon => _addImgIcon;

  String getItemIcon(String itemType) {
    debugPrint('$_basePath/$itemType.png');
    return '$_basePath/$itemType.png';
  }
}
