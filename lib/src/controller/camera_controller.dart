import 'package:video_settings/src/enum/ios_enums.dart';
import 'package:video_settings/src/error/camera_control_errors.dart';
import 'package:video_settings/src/model/camera_device.dart';
import 'package:video_settings/src/video_settings_method_channel.dart';

class CameraController {
  final _methodChannel = VideoSettingsMethodChannel();

  Future<CameraDevice> defaultDevice() async {
    final data = await _methodChannel.invokeMethod<Map<String, dynamic>>(
      'CameraController/defaultDevice',
    );

    if (data == null) {
      throw NotFoundCameraDevice();
    }

    final device = CameraDevice.fromJson(data);

    return device;
  }

  Future<CameraDevice> deviceWithPosition(
    CameraDevicePosition position,
    CameraDeviceType type,
  ) async {
    final data = await _methodChannel.invokeMethod<Map<String, dynamic>>(
      'CameraController/deviceWithPosition',
      {
        'position': position.index,
        'type': type.nativeName,
      },
    );

    if (data == null) {
      throw NotFoundCameraDevice();
    }

    final device = CameraDevice.fromJson(data);

    return device;
  }

  Future<List<CameraDevice>> enumerateDevices() async {
    final data = await _methodChannel.invokeMethod<List<Map<String, dynamic>>>(
      'CameraController/deviceWithPosition',
    );

    if (data == null) {
      throw NotFoundCameraDevice();
    }

    final devices = <CameraDevice>[];
    for (final deviceData in data) {
      final device = CameraDevice.fromJson(deviceData);
      devices.add(device);
    }

    return devices;
  }

  Future<CameraDevice> deviceWithUniqueId(String id) async {
    final data = await _methodChannel.invokeMethod<Map<String, dynamic>>(
      'CameraController/defaultDevice',
      {
        'id': id,
      },
    );

    if (data == null) {
      throw NotFoundCameraDevice(name: id);
    }

    final device = CameraDevice.fromJson(data);

    return device;
  }

  Future<CameraDevice> getCameraByType(CameraDeviceType type) async {
    final data = await _methodChannel.invokeMethod<Map<String, dynamic>>(
      'CameraController/setCameraByName',
      {
        'nativeName': type.nativeName,
      },
    );

    if (data == null) {
      throw NotFoundCameraDevice(name: type.nativeName);
    }

    final camera = CameraDevice.fromJson(data);

    return camera;
  }

  Future<int> lensAmount() async {
    final result = await _methodChannel.invokeMethod<int>(
      'CameraController/getCameraLensAmount',
    );
    return result ?? 0;
  }

  Future<List<CameraDeviceType>> getSupportedCameraLens() async {
    final result = await _methodChannel.invokeMethod<List>(
      'CameraController/getSupportedCameraLens',
    );

    final supportedLens = <CameraDeviceType>[];

    for (final name in result ?? []) {
      supportedLens.add(CameraDeviceTypeEX.typeByName(name));
    }

    return supportedLens;
  }
}
