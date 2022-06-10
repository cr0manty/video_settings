import 'dart:async';

import 'package:video_settings/src/controller/base/base_controller.dart';

class ZoomController extends BaseVideoSettingsController {
  @override
  String get methodType => 'ZoomController';

  Future<bool> setZoom(
    double zoom, {
    String? trackId,
  }) async {
    final result = await invokeMethod<bool>(
      'ZoomController/changeZoom',
      <String, dynamic>{
        'zoom': zoom,
        'trackId': trackId,
      },
    );

    return result ?? false;
  }

  Future<double> maxZoomFactor() async {
    final result = await invokeMethod<double>(
      'ZoomController/getMaxZoomFactor',
    );

    return result ?? 2.0;
  }

  Future<double> minZoomFactor() async {
    final result = await invokeMethod<double>(
      'ZoomController/getMinZoomFactor',
    );

    return result ?? 1.0;
  }

  Future<double> currentZoomFactor() async {
    final result = await invokeMethod<double>(
      'ZoomController/getZoomFactor',
    );

    return result ?? 1.0;
  }
}
