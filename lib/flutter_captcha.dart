import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart';

class FlutterCaptcha {
  static const MethodChannel _channel = const MethodChannel('flutter_captcha');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String?> validate(
      {required String key, required String domain}) async {
    final String? token =
        await _channel.invokeMethod('validate', {"key": key, "domain": domain});
    debugPrint(
        '--------------FlutterCaptcha validate result: $token-----------------');
    return token;
  }
}
