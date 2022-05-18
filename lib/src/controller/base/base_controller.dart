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
      throw ControllerNotInitialized();
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
    _isInitialized = await invokeMethod<bool>('$runtimeType/initialize', {
          'deviceId': deviceId,
        }) ??
        false;

    return _isInitialized;
  }

  Future<bool> dispose() async {
    _isInitialized = false;
    final result = await invokeMethod<bool>(
      '$runtimeType/dispose',
    );

    return result ?? false;
  }
}
