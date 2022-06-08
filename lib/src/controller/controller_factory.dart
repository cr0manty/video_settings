import 'dart:async';

import 'package:video_settings/src/model/camera_device.dart';
import 'package:video_settings/video_settings.dart';

typedef ChandgeDevice = Future<bool> Function(String uniqueId);

class ControllerFactory {
  final _onDeviceUpdateController = <ChandgeDevice>[];

  TorchController? _torchController;
  WhiteBalanceController? _whiteBalanceController;
  FocusController? _focusController;
  ExposureController? _exposureController;
  ZoomController? _zoomController;
  CameraController? _cameraController;

  StreamSubscription<CameraDevice>? _cameraDeviceHasChandged;

  void setDeviceChanged(Stream<CameraDevice>? deviceChanged) {
    if (_cameraDeviceHasChandged != null) {
      _cameraDeviceHasChandged = deviceChanged?.listen(
        _cameraDeviceChandgedListener,
      );
    }
  }

  Future<void> _cameraDeviceChandgedListener(CameraDevice device) async {
    for (final updater in _onDeviceUpdateController) {
      await updater.call(device.uniqueID);
    }
  }

  Future<void> init(
    String deviceId, {
    bool useTorch = true,
    bool useZoom = true,
    bool useFocus = true,
    bool useWhiteBalance = true,
    bool useExposure = true,
  }) async {
    if (useExposure) {
      await exposureController.init(deviceId);
    }
    if (useZoom) {
      await zoomController.init(deviceId);
    }
    if (useFocus) {
      await focusController.init(deviceId);
    }
    if (useWhiteBalance) {
      await whiteBalanceController.init(deviceId);
    }
    if (useTorch) {
      await torchController.init(deviceId);
    }
  }

  CameraController get cameraController {
    _cameraController ??= CameraController();

    return _cameraController!;
  }

  TorchController get torchController {
    if (_torchController == null) {
      _torchController = TorchController();
      _onDeviceUpdateController.add(
        _torchController!.updateDeviceId,
      );
    }

    return _torchController!;
  }

  ZoomController get zoomController {
    if (_zoomController == null) {
      _zoomController = ZoomController();
      _onDeviceUpdateController.add(
        _zoomController!.updateDeviceId,
      );
    }

    return _zoomController!;
  }

  WhiteBalanceController get whiteBalanceController {
    if (_whiteBalanceController == null) {
      _whiteBalanceController = WhiteBalanceController();
      _onDeviceUpdateController.add(
        _whiteBalanceController!.updateDeviceId,
      );
    }

    return _whiteBalanceController!;
  }

  FocusController get focusController {
    if (_focusController == null) {
      _focusController = FocusController();
      _onDeviceUpdateController.add(
        _focusController!.updateDeviceId,
      );
    }

    return _focusController!;
  }

  ExposureController get exposureController {
    if (_exposureController == null) {
      _exposureController = ExposureController();
      _onDeviceUpdateController.add(
        _exposureController!.updateDeviceId,
      );
    }

    return _exposureController!;
  }

  Future<void> dispose() async {
    _cameraDeviceHasChandged?.cancel();
    await _torchController?.dispose();
    await _whiteBalanceController?.dispose();
    await _exposureController?.dispose();
    await _focusController?.dispose();
    await _zoomController?.dispose();
  }
}
