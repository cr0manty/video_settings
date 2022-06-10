import 'package:video_settings/src/controller/camera_controller.dart';
import 'package:video_settings/src/error/camera_control_errors.dart';
import 'package:video_settings/src/video_settings_method_channel.dart';

abstract class BaseVideoSettingsController {
  final _methodChannel = VideoSettingsMethodChannel();
  bool _isInitialized = false;

  String get methodType;

  Future<T?> invokeMethod<T>(
    String method, [
    Map<String, dynamic>? arguments,
  ]) {
    if (!_isInitialized) {
      throw ControllerNotInitialized(method);
    }

    return _methodChannel.invokeMethod<T>(
      method,
      arguments,
    );
  }

  Future<bool> updateDeviceId(String id) => init(id);

  Future<bool> init(String deviceId) async {
    final result = await _methodChannel.invokeMethod<bool>('$methodType/init', {
      'deviceId': deviceId,
    });

    _isInitialized = result ?? false;

    return _isInitialized;
  }

  Future<void> dispose() async {
    _isInitialized = false;

    await _methodChannel.invokeMethod<bool>(
      '$methodType/dispose',
    );
  }
}
