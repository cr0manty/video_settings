import 'package:flutter/services.dart';

class VideoSettingsMethodChannel {
  final _methodChannel = const MethodChannel('video_settings');

  Future<T?> invokeMethod<T>(
    String method, [
    Map<String, dynamic>? arguments,
  ]) =>
      _methodChannel.invokeMethod<T>(
        method,
        arguments,
      );
}
