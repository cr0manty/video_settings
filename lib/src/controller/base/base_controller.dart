import 'package:video_settings/src/controller/camera_controller.dart';
import 'package:video_settings/src/error/camera_control_errors.dart';
import 'package:video_settings/src/video_settings_method_channel.dart';

abstract class BaseVideoSettingsController {
  final _methodChannel = VideoSettingsMethodChannel();
  bool _isInitialized = false;

  Future<T?> invokeMethod<T>(
    String method, [
    Map<String, dynamic>? arguments,
  ]) {
    if (!_isInitialized) {
      throw ControllerNotInitialized(method);
    }

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

  Future<bool> updateDeviceId(String id) => init(id);

  Future<bool> init(String deviceId) async {
    print('[controller_init] $runtimeType/init called');

    _isInitialized = await _methodChannel.invokeMethod<bool>(
          '$runtimeType/init',
          {
            'deviceId': deviceId,
          },
        ) ??
        false;
    print('[controller_init] $runtimeType/init done');

    return _isInitialized;
  }

  Future<void> dispose() async {
    _isInitialized = false;

    await _methodChannel.invokeMethod<bool>(
      '$runtimeType/dispose',
    );
  }
}
