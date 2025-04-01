class AppMedia {
  static const String _basePath = 'assets/images';
  static const String _logo = '$_basePath/logo.png';
  static const String _logoTop = '$_basePath/logoTopPage.png';
  static const String _logoText = '$_basePath/logoText.png';

  //Icons for items
  static const String _otherIcon = '$_basePath/icons/other_icon.png';
  static const String _addImgIcon = '$_basePath/icons/add_img_icon.png';

  String get logo => _logo;
  String get logoText => _logoText;
  String get logoTop => _logoTop;
  String get otherIcon => _otherIcon;
  String get addImgIcon => _addImgIcon;
}
