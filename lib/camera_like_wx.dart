import 'dart:async';

import 'package:flutter/services.dart';

class CameraLikeWx {
  static const MethodChannel _channel =
      const MethodChannel('camera_like_wx');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
