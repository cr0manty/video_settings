import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:video_settings/src/controller/base/base_controller.dart';
import 'package:video_settings/src/enum/ios_enums.dart';
import 'package:video_settings/src/error/focus_error.dart';

export '../error/focus_error.dart';

class FocusController extends BaseVideoSettingsController {
  final _focusModeChannel = const EventChannel(
    'FocusController/modeChannel',
  );
  final _focusLensDistanceChannel = const EventChannel(
    'FocusController/lensDistanceChannel',
  );

  Stream<FocusMode>? _focusModeStream;
  Stream<double>? _focusLensDistanceStream;

  @override
  String get methodType => 'FocusController';

  Stream<FocusMode> get focusModeStream {
    _focusModeStream ??= _focusModeChannel.receiveBroadcastStream().transform(
      StreamTransformer.fromHandlers(
        handleData: (index, sink) {
          sink.add(FocusMode.values[index]);
        },
      ),
    );
    return _focusModeStream!;
  }

  Stream<double> get focusLensDistanceStream {
    _focusLensDistanceStream ??=
        _focusLensDistanceChannel.receiveBroadcastStream().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(data);
        },
      ),
    );
    return _focusLensDistanceStream!;
  }

  Future<bool> isFocusModeSupported(
    FocusMode mode,
  ) async {
    final result = await invokeMethod<bool>(
      'FocusController/isFocusModeSupported',
      {'mode': mode.index},
    );
    return result ?? false;
  }

  Future<bool> isFocusPointOfInterestSupported() async {
    final result = await invokeMethod<bool>(
      'FocusController/isFocusPointOfInterestSupported',
    );
    return result ?? false;
  }

  Future<bool> isLockingFocusWithCustomLensPositionSupported() async {
    final result = await invokeMethod<bool>(
      'FocusController/isLockingFocusWithCustomLensPositionSupported',
    );
    return result ?? false;
  }

  Future<bool> setFocusMode(
    FocusMode mode,
  ) async {
    final result = await invokeMethod<bool>(
      'FocusController/setFocusMode',
      {'mode': mode.index},
    );
    return result ?? false;
  }

  Future<FocusMode> getFocusMode() async {
    final index = await invokeMethod<int>(
      'FocusController/getFocusMode',
    );

    if (index == null || FocusMode.values.length < index) {
      throw FocusModeNotFound();
    }

    final mode = FocusMode.values[index];

    return mode;
  }

  Future<bool> refocus({
    required TapDownDetails details,
    required Size screenSize,
    required Size previewSize,
  }) async {
    final isSupported = await isFocusPointOfInterestSupported();

    if (!isSupported) {
      return setFocusMode(
        FocusMode.autoFocus,
      );
    }

    return setFocusPoint(
      details: details,
      screenSize: screenSize,
      previewSize: previewSize,
    );
  }

  Future<bool> setFocusPoint({
    required TapDownDetails details,
    required Size screenSize,
    required Size previewSize,
  }) async {
    final isSupported = await isFocusPointOfInterestSupported();

    if (!isSupported) {
      return false;
    }

    final x = details.localPosition.dx;
    final y = details.localPosition.dy;

    final aspectRatio = previewSize.width / previewSize.height;

    final fullWidth = screenSize.width;
    final cameraHeight = fullWidth * aspectRatio;

    final xp = x / fullWidth;
    final yp = y / cameraHeight;

    final result = await invokeMethod<bool>(
      'FocusController/setFocusPoint',
      {
        'point': {
          'x': xp,
          'y': yp,
        },
      },
    );
    return result ?? false;
  }

  Future<double> getFocusPointLockedWithLensPosition() async {
    final result = await invokeMethod<double>(
      'FocusController/getFocusPointLockedWithLensPosition',
    );
    return result ?? 0.0;
  }

  Future<bool> setFocusPointLockedWithLensPosition(double value) async {
    final isSupported = await isLockingFocusWithCustomLensPositionSupported();

    if (!isSupported) {
      throw FocusLockLensNotSuported();
    }

    final result = await invokeMethod<bool>(
      'FocusController/setFocusPointLockedWithLensPosition',
      {
        'position': value,
      },
    );
    return result ?? false;
  }

  Future<List<FocusMode>> getSupportedFocusMode() async {
    final result = await invokeMethod<List>(
      'FocusController/getSupportedFocusMode',
    );

    final supportedMode = <FocusMode>[];

    for (final index in result ?? []) {
      supportedMode.add(FocusMode.values[index]);
    }

    return supportedMode;
  }
}
