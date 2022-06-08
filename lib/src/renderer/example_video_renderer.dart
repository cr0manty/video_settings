import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_settings/src/error/video_renderer_error.dart';
import 'package:video_settings/src/model/camera_device.dart';
import 'package:video_settings/src/video_settings_method_channel.dart';

export '../error/video_renderer_error.dart';

@visibleForTesting
class ExampleVideoRenderer {
  final _methodChannel = VideoSettingsMethodChannel();

  int? _textureId;

  ExampleVideoRenderer();

  int? get textureId => _textureId;

  Future<void> init(CameraDevice device) async {
    final textureId = await _methodChannel.invokeMethod('VideoRenderer/init', {
      'deviceId': device.uniqueID,
    });

    if (textureId == null || textureId == 0) {
      throw TextureNotRegistered();
    }
    _textureId = textureId;
  }

  Future<bool> requestCameraPermission() async {
    final result = await _methodChannel.invokeMethod(
      'PermissionHandler/requestAccessToCamera',
    );

    return result ?? false;
  }
}
