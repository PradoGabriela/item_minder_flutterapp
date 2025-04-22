import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceId {
  static final DeviceId _instance = DeviceId._internal();

  factory DeviceId() {
    return _instance;
  }

  DeviceId._internal();

  String currentDeviceId = ''; // Placeholder for the device ID

  void initId() async {
    currentDeviceId = await deviceId;
  }

  Future<String> get deviceId async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id; // Or use another stable identifier
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor!;
    }
    return 'unknown';
  }

  String getDeviceId() {
    return currentDeviceId;
  }
}
