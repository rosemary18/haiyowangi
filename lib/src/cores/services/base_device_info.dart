import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_device_type/flutter_device_type.dart';

final deviceInfoPlugin = DeviceInfoPlugin();
BaseDeviceInfo? baseDeviceInfo;
AndroidDeviceInfo? androidDeviceInfo;
IosDeviceInfo? iosDeviceInfo;
bool isTablet = false;

getBaseDeviceInfo() async {
  baseDeviceInfo = await deviceInfoPlugin.deviceInfo;
  if (Platform.isAndroid) androidDeviceInfo = await deviceInfoPlugin.androidInfo;
  if (Platform.isIOS) iosDeviceInfo = await deviceInfoPlugin.iosInfo;
  isTablet = Device.get().isTablet;
}