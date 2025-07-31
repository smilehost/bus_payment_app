import 'package:flutter/services.dart';

class DeviceNameUtil {
  static Future<String> getDeviceName() async {
    const platform = MethodChannel('com.example.bus_payment_app/deviceinfo');
    try {
      final String deviceName = await platform.invokeMethod('getDeviceName');
      return deviceName;
    } on PlatformException catch (e) {
      return 'Unknown (${e.message})';
    }
  }
}
