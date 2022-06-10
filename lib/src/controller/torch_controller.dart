import 'package:video_settings/src/controller/base/base_controller.dart';
import 'package:video_settings/src/enum/ios_enums.dart';

class TorchController extends BaseVideoSettingsController {
  @override
  String get methodType => 'TorchController';

  Future<bool> switchTorch(TorchMode mode) async {
    final result = await invokeMethod<bool>(
      'TorchController/switchTorch',
      {
        'mode': mode.nativeName,
      },
    );
    return result ?? false;
  }

  Future<bool> isTorchSupported() async {
    final result = await invokeMethod<bool>(
      'TorchController/isTorchSupported',
    );
    return result ?? false;
  }

  Future<bool> isTorchEnabled() async {
    final result = await invokeMethod<bool>(
      'TorchController/isTorchEnabled',
    );
    return result ?? false;
  }

  Future<bool> isTorchModeSupported(TorchMode mode) async {
    final result =
        await invokeMethod<bool>('TorchController/isTorchModeSupported', {
      'mode': mode.nativeName,
    });
    return result ?? false;
  }

  Future<bool> torchMode() async {
    final result = await invokeMethod<bool>(
      'TorchController/torchMode',
    );
    return result ?? false;
  }
}
