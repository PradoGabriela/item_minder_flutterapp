import 'package:flutter/foundation.dart';

class AppMedia {
  static const String _basePath = 'assets/images';
  static const String _iconsBasePath = 'assets/icons';
  static const String _tutorialPath = 'assets/tutorial';
  static const String _logo = '$_basePath/logo.png';
  static const String _logoTop = '$_basePath/logoTopPage.png';
  static const String _logoText = '$_basePath/logoText.png';

  //Icons for Groups
  static const String _otherIcon = '$_iconsBasePath/logo.png';
  static const String _addImgIcon = '$_iconsBasePath/logo.png';
  static const String _familyIcon = '$_iconsBasePath/family.png';
  static const String _home = '$_iconsBasePath/home.png';
  static const String _canteen = '$_iconsBasePath/canteen.png';
  static const String _parent = '$_iconsBasePath/parent.png';
  static const String _patient = '$_iconsBasePath/patient.png';
  static const String _shelter = '$_iconsBasePath/shelter.png';
  static const String _work = '$_iconsBasePath/work.png';

  //Img for Tutorials
  static const String _tutorialGroup = '$_tutorialPath/tutorialGroup.png';

  List<String> get iconsGroupList =>
      [_familyIcon, _home, _canteen, _parent, _patient, _shelter, _work];

  //Images for Items
  static const String bed = '$_basePath/bed.png';

  String get logo => _logo;
  String get logoText => _logoText;
  String get logoTop => _logoTop;
  String get otherIcon => _otherIcon;
  String get addImgIcon => _addImgIcon;
  String get familyIcon => _familyIcon;

  String getItemIcon(String itemType) {
    debugPrint('$_basePath/$itemType.png');
    return '$_basePath/$itemType.png';
  }

  //getter images for tutorial

  String get tutorialGroupImg => _tutorialGroup;
}
