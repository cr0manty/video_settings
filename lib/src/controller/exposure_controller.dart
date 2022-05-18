import 'dart:async';

import 'package:flutter/services.dart';
import 'package:video_settings/src/controller/base/base_controller.dart';
import 'package:video_settings/src/enum/ios_enums.dart';
import 'package:video_settings/src/error/exposure_error.dart';
import 'package:video_settings/src/model/exposure.dart';

export '../error/exposure_error.dart';
export '../model/exposure.dart';

class ExposureController extends BaseVideoSettingsController {
  final _exposureModeChannel = const EventChannel(
    'ExposureController/modeChannel',
  );
  final _exposureDurationChannel = const EventChannel(
    'ExposureController/durationChannel',
  );
  final _iSOChannel = const EventChannel(
    'ExposureController/isoChannel',
  );
  final _exposureTargetBiasChannel = const EventChannel(
    'ExposureController/targetBiasChannel',
  );
  final _exposureTargetOffsetChannel = const EventChannel(
    'ExposureController/offsetChannel',
  );

  Stream<ExposureMode>? _exposureModeStream;
  Stream<ExposureDuration>? _exposureDurationStream;
  Stream<double>? _iSOStream;
  Stream<double>? _exposureTargetBiasStream;
  Stream<double>? _exposureTargetOffsetStream;

  Stream<ExposureMode> get exposureModeStream {
    _exposureModeStream ??=
        _exposureModeChannel.receiveBroadcastStream().transform(
      StreamTransformer.fromHandlers(
        handleData: (index, sink) {
          sink.add(ExposureMode.values[index]);
        },
      ),
    );
    return _exposureModeStream!;
  }

  Stream<double> get iSOStream {
    _iSOStream ??= _iSOChannel.receiveBroadcastStream().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(data);
        },
      ),
    );
    return _iSOStream!;
  }

  Stream<double> get exposureTargetBiasStream {
    _exposureTargetBiasStream ??=
        _exposureTargetBiasChannel.receiveBroadcastStream().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(data);
        },
      ),
    );
    return _exposureTargetBiasStream!;
  }

  Stream<double> get exposureTargetOffsetStream {
    _exposureTargetOffsetStream ??=
        _exposureTargetOffsetChannel.receiveBroadcastStream().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(data);
        },
      ),
    );
    return _exposureTargetOffsetStream!;
  }

  Stream<ExposureDuration> get exposureDurationStream {
    _exposureDurationStream ??=
        _exposureDurationChannel.receiveBroadcastStream().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          final value = ExposureDuration.fromJson(data);
          sink.add(value);
        },
      ),
    );
    return _exposureDurationStream!;
  }

  Future<bool> isExposureModeSupported(
    ExposureMode mode,
  ) async {
    final result = await invokeMethod<bool>(
      'ExposureController/isExposureModeSupported',
      {'mode': mode.index},
    );
    return result ?? false;
  }

  Future<bool> setExposureMode(
    ExposureMode mode,
  ) async {
    final result = await invokeMethod<bool>(
      'ExposureController/setExposureMode',
      {'mode': mode.index},
    );
    return result ?? false;
  }

  Future<ExposureMode> getExposureMode() async {
    final index = await invokeMethod<int>(
      'ExposureController/getExposureMode',
    );

    if (index == null || ExposureMode.values.length < index) {
      throw ExposureModeNotFound();
    }

    final mode = ExposureMode.values[index];

    return mode;
  }

  Future<bool> changeISO(
    double value,
  ) async {
    final result = await invokeMethod<bool>(
      'ExposureController/changeISO',
      {'value': value},
    );
    return result ?? false;
  }

  Future<double> getISO() async {
    final result = await invokeMethod<double>(
      'ExposureController/getISO',
    );
    return result ?? 0.0;
  }

  Future<double> getExposureTargetBias() async {
    final result = await invokeMethod<double>(
      'ExposureController/getExposureTargetBias',
    );
    return result ?? 0.0;
  }

  Future<double> getMaxExposureTargetBias() async {
    final result = await invokeMethod<double>(
      'ExposureController/getMaxExposureTargetBias',
    );
    return result ?? 0.0;
  }

  Future<double> getMinExposureTargetBias() async {
    final result = await invokeMethod<double>(
      'ExposureController/getMinExposureTargetBias',
    );
    return result ?? 0.0;
  }

  Future<double> getMaxISO() async {
    final result = await invokeMethod<double>(
      'ExposureController/getMaxISO',
    );
    return result ?? 0.0;
  }

  Future<double> getExposureTargetOffset() async {
    final result = await invokeMethod<double>(
      'ExposureController/getExposureTargetOffset',
    );
    return result ?? 0.0;
  }

  Future<double> getMinISO() async {
    final result = await invokeMethod<double>(
      'ExposureController/getMinISO',
    );
    return result ?? 0.0;
  }

  Future<ExposureDuration> getExposureDuration() async {
    final result = await invokeMethod<Map>(
      'ExposureController/getExposureDuration',
    );

    if (result == null || result.length < 2) {
      throw ExposureNotEnoughtDurationData();
    }
    final data = ExposureDuration.fromJson(result);

    return data;
  }

  Future<ExposureDuration> getExposureDurationSeconds() async {
    final result = await invokeMethod<Map>(
      'ExposureController/getExposureDurationSeconds',
    );

    if (result == null || result.length < 2) {
      throw ExposureNotEnoughtDurationData();
    }
    final data = ExposureDuration.fromJson(result);

    return data;
  }

  Future<ExposureDuration> minExposureDuration() async {
    final result = await invokeMethod<Map>(
      'ExposureController/minExposureDuration',
    );

    if (result == null || result.length < 2) {
      throw ExposureNotEnoughtDurationData();
    }
    final data = ExposureDuration.fromJson(result);

    return data;
  }

  Future<ExposureDuration> maxExposureDuration() async {
    final result = await invokeMethod<Map>(
      'ExposureController/maxExposureDuration',
    );

    if (result == null || result.length < 2) {
      throw ExposureNotEnoughtDurationData();
    }
    final data = ExposureDuration.fromJson(result);

    return data;
  }

  Future<bool> changeBias(
    double value
  ) async {
    final result = await invokeMethod<bool>(
      'ExposureController/changeBias',
      {'value': value},
    );
    return result ?? false;
  }

  Future<bool> changeExposureDuration(
    double value,
  ) async {
    final result = await invokeMethod<bool>(
      'ExposureController/changeExposureDuration',
      {'value': value},
    );
    return result ?? false;
  }

  Future<List<ExposureMode>> getSupportedExposureMode() async {
    final result = await invokeMethod<List>(
      'ExposureController/getSupportedExposureMode',
    );

    final supportedMode = <ExposureMode>[];

    for (final index in result ?? []) {
      supportedMode.add(ExposureMode.values[index]);
    }

    return supportedMode;
  }
}
