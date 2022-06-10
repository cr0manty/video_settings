import 'package:flutter/services.dart';
import 'package:video_settings/src/controller/camera_controller.dart';

class VideoSettingsMethodChannel {
  final _methodChannel = const MethodChannel('video_settings');

  Future<T?> invokeMethod<T>(
    String method, [
    Map<String, dynamic>? arguments,
  ]) {
    if (runtimeType is CameraController) {
      print(
        'If you change your active camera device, '
            'you need to call [updateDeviceId] method',
      );
    }

    return _methodChannel.invokeMethod<T>(
        method,
        arguments,
      );
  }
}
