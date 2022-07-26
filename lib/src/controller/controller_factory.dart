import 'dart:async';

import 'package:video_settings/video_settings.dart';

typedef ChandgeDevice = Future<bool> Function(String uniqueId);

class VideoSettingsControllerFactory {
  final _streamController = StreamController<CameraDevice>.broadcast();
  final _onDeviceUpdateController = <ChandgeDevice>[];
  CameraDevice? _device;

  TorchController? _torchController;
  WhiteBalanceController? _whiteBalanceController;
  FocusController? _focusController;
  ExposureController? _exposureController;
  ZoomController? _zoomController;
  CameraController? _cameraController;

  Future<void> cameraDeviceChandgedListener(CameraDevice? device) async {
    if (device == null) return;

    for (final updater in _onDeviceUpdateController) {
      await updater.call(device.uniqueID);
    }

    _device = device;
    if (!_streamController.isClosed) {
      _streamController.add(device);
    }
  }

  CameraDevice? get device => _device;

  Stream<CameraDevice> get deviceChandged => _streamController.stream;

  VideoSettingsControllerFactory({
    bool useTorch = true,
    bool useZoom = true,
    bool useFocus = true,
    bool useWhiteBalance = true,
    bool useExposure = true,
  }) {
    if (useExposure) {
      _exposureController = ExposureController();
      _onDeviceUpdateController.add(
        _exposureController!.updateDeviceId,
      );
    }
    if (useZoom) {
      _zoomController = ZoomController();
      _onDeviceUpdateController.add(
        _zoomController!.updateDeviceId,
      );
    }
    if (useFocus) {
      _focusController = FocusController();
      _onDeviceUpdateController.add(
        _focusController!.updateDeviceId,
      );
    }
    if (useWhiteBalance) {
      _whiteBalanceController = WhiteBalanceController();
      _onDeviceUpdateController.add(
        _whiteBalanceController!.updateDeviceId,
      );
    }
    if (useTorch) {
      _torchController = TorchController();
      _onDeviceUpdateController.add(
        _torchController!.updateDeviceId,
      );
    }
  }

  Future<void> updateDeviceId(String deviceId) async {
    await _torchController?.init(deviceId);
    await _whiteBalanceController?.init(deviceId);
    await _exposureController?.init(deviceId);
    await _focusController?.init(deviceId);
    await _zoomController?.init(deviceId);

    _streamController.add(
      CameraDevice(uniqueID: deviceId),
    );
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
    await _streamController.close();
    await _torchController?.dispose();
    await _whiteBalanceController?.dispose();
    await _exposureController?.dispose();
    await _focusController?.dispose();
    await _zoomController?.dispose();
  }
}
