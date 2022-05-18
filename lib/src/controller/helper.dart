import 'package:video_settings/src/video_settings_method_channel.dart';

class CameraHelper {
  final _methodChannel = VideoSettingsMethodChannel();

  Future<bool> switchTorch([bool? enable]) async {
    final enabled = await isTorchEnabled();
    final result = await _methodChannel.invokeMethod<bool>(
      'CameraHelper/switchTorch',
      {
        'enabled': enable ?? enabled,
      },
    );
    return result ?? false;
  }

  Future<bool> isTorchSupported() async {
    final result = await _methodChannel.invokeMethod<bool>(
      'CameraHelper/isTorchSupported',
    );
    return result ?? false;
  }

  Future<bool> isTorchEnabled() async {
    final result = await _methodChannel.invokeMethod<bool>(
      'CameraHelper/isTorchEnabled',
    );
    return result ?? false;
  }
}
