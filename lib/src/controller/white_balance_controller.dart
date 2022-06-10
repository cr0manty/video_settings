import 'dart:async';

import 'package:flutter/services.dart';
import 'package:video_settings/src/controller/base/base_controller.dart';
import 'package:video_settings/src/enum/ios_enums.dart';
import 'package:video_settings/src/error/white_balance_error.dart';
import 'package:video_settings/src/model/white_balance/gains.dart';
import 'package:video_settings/src/model/white_balance/temperature_gains.dart';

export '../error/white_balance_error.dart';
export '../model/white_balance/gains.dart';
export '../model/white_balance/temperature_gains.dart';

class WhiteBalanceController extends BaseVideoSettingsController {
  final _whiteBalanceModeChannel = const EventChannel(
    'WhiteBalanceController/modeChannel',
  );
  final _whiteBalanceGainsChannel = const EventChannel(
    'WhiteBalanceController/gainsChannel',
  );

  Stream<WhiteBalanceMode>? _whiteBalanceModeStream;
  Stream<TemperatureAndTintWhiteBalanceGains>? _whiteBalanceTempGainsStream;
  Stream<WhiteBalanceGains>? _whiteBalanceGainsStream;

  @override
  String get methodType => 'WhiteBalanceController';

  Stream<WhiteBalanceMode> get whiteBalanceModeStream {
    _whiteBalanceModeStream ??=
        _whiteBalanceModeChannel.receiveBroadcastStream().transform(
          StreamTransformer.fromHandlers(
            handleData: (index, sink) {
              sink.add(WhiteBalanceMode.values[index]);
            },
          ),
        );
    return _whiteBalanceModeStream!;
  }

  Stream<TemperatureAndTintWhiteBalanceGains> get whiteBalanceTempGainsStream {
    _whiteBalanceTempGainsStream ??= whiteBalanceGainsStream.transform(
      StreamTransformer.fromHandlers(
        handleData: (gains, sink) async {
          final tempGains = await convertDeviceGainsToTemperature(gains);
          sink.add(tempGains);
        },
      ),
    );
    return _whiteBalanceTempGainsStream!;
  }

  Stream<WhiteBalanceGains> get whiteBalanceGainsStream {
    _whiteBalanceGainsStream ??=
        _whiteBalanceGainsChannel.receiveBroadcastStream().transform(
          StreamTransformer.fromHandlers(
            handleData: (json, sink) async {
              final gains = WhiteBalanceGains.fromJson(json);
              sink.add(gains);
            },
          ),
        );
    return _whiteBalanceGainsStream!;
  }

  Future<WhiteBalanceMode> getWhiteBalanceMode() async {
    final index = await invokeMethod<int>(
      'WhiteBalanceController/getWhiteBalanceMode',
    );

    if (index == null || WhiteBalanceMode.values.length < index) {
      throw WhiteBalanceModeNotFound();
    }

    final mode = WhiteBalanceMode.values[index];

    return mode;
  }

  Future<bool> isWhiteBalanceLockSupported() async {
    final result = await invokeMethod<bool>(
      'WhiteBalanceController/isWhiteBalanceLockSupported',
    );
    return result ?? false;
  }

  Future<bool> isWhiteBalanceModeSupported(WhiteBalanceMode mode,) async {
    final result = await invokeMethod<bool>(
      'WhiteBalanceController/isWhiteBalanceModeSupported',
      {'mode': mode.index},
    );
    return result ?? false;
  }

  Future<List<WhiteBalanceMode>> getSupportedWhiteBalanceMode() async {
    final result = await invokeMethod<List>(
      'WhiteBalanceController/getSupportedWhiteBalanceMode',
    );

    final supportedMode = <WhiteBalanceMode>[];

    for (final index in result ?? []) {
      supportedMode.add(WhiteBalanceMode.values[index]);
    }

    return supportedMode;
  }

  Future<bool> setWhiteBalanceMode(WhiteBalanceMode mode,) async {
    final isSupported = await isWhiteBalanceLockSupported();

    if (!isSupported && mode == WhiteBalanceMode.locked) {
      return false;
    }

    final result = await invokeMethod<bool>(
      'WhiteBalanceController/setWhiteBalanceMode',
      {'mode': mode.index},
    );
    return result ?? false;
  }

  Future<bool> changeWhiteBalanceGains(WhiteBalanceGains gains) async {
    final isSupported = await isWhiteBalanceLockSupported();

    if (!isSupported) {
      throw const WhilteBalanceLockIsNotSupported(
        'changeWhiteBalanceGains',
      );
    }

    final result = await invokeMethod<bool>(
      'WhiteBalanceController/changeWhiteBalanceGains',
      gains.toJson(),
    );
    return result ?? false;
  }

  Future<bool> changeWhiteBalanceTemperatureAndTint(
      TemperatureAndTintWhiteBalanceGains gains,) async {
    final isSupported = await isWhiteBalanceLockSupported();

    if (!isSupported) {
      throw const WhilteBalanceLockIsNotSupported(
        'changeWhiteBalanceTemperatureAndTint',
      );
    }

    final result = await invokeMethod<bool>(
      'WhiteBalanceController/changeWhiteBalanceTemperatureAndTint',
      gains.toJson(),
    );
    return result ?? false;
  }

  Future<bool> lockWithGrayWorld() async {
    final isSupported = await isWhiteBalanceLockSupported();

    if (!isSupported) {
      throw const WhilteBalanceLockIsNotSupported(
        'lockWithGrayWorld',
      );
    }

    final result = await invokeMethod<bool>(
      'WhiteBalanceController/lockWithGrayWorld',
    );
    return result ?? false;
  }

  Future<double> getMaxBalanceGains() async {
    final result = await invokeMethod<double>(
      'WhiteBalanceController/getMaxBalanceGains',
    );
    return result ?? 1.1;
  }

  Future<WhiteBalanceGains> getCurrentBalanceGains() async {
    final result = await invokeMethod<Map>(
      'WhiteBalanceController/getCurrentBalanceGains',
    );
    if (result == null || result.isEmpty || result.length < 3) {
      return WhiteBalanceGains.zero();
    }

    return WhiteBalanceGains.fromJson(result);
  }

  Future<TemperatureAndTintWhiteBalanceGains>
  getCurrentTemperatureBalanceGains() async {
    final result = await invokeMethod<Map>(
      'WhiteBalanceController/getCurrentTemperatureBalanceGains',
    );
    if (result == null || result.isEmpty || result.length < 2) {
      throw WhiteBalanceGetTemperatureGainsError();
    }

    return TemperatureAndTintWhiteBalanceGains.fromJson(result);
  }

  Future<TemperatureAndTintWhiteBalanceGains> convertDeviceGainsToTemperature(
      WhiteBalanceGains gains,) async {
    final result = await invokeMethod<Map>(
      'WhiteBalanceController/convertDeviceGainsToTemperature',
      gains.toJson(),
    );
    if (result == null || result.isEmpty || result.length < 2) {
      throw WhiteBalanceConvertGainsError();
    }

    return TemperatureAndTintWhiteBalanceGains(
      temperature: result['temperature']!,
      tint: result['tint']!,
    );
  }
}
