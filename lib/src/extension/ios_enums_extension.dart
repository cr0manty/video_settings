import 'package:video_settings/src/enum/ios_enums.dart';

extension CameraDeviceTypeEX on CameraDeviceType {
  String get nativeName {
    switch (this) {
      case CameraDeviceType.telephoto:
        return 'TelephotoCamera';
      case CameraDeviceType.ultraWide:
        return 'WideCamera';
      default:
        return 'WideAngleCamera';
    }
  }

  static CameraDeviceType typeByName(String? name) {
    switch (name) {
      case 'AVCaptureDeviceTypeBuiltInTelephotoCamera':
        return CameraDeviceType.telephoto;
      case 'AVCaptureDeviceTypeBuiltInUltraWideCamera':
        return CameraDeviceType.ultraWide;
      default:
        return CameraDeviceType.wideAngle;
    }
  }

  bool get isDefaultCamera => this == CameraDeviceType.wideAngle;

  CameraDeviceTypeExtenden get extended {
    switch (this) {
      case CameraDeviceType.wideAngle:
        return CameraDeviceTypeExtenden.wideAngle;
      case CameraDeviceType.ultraWide:
        return CameraDeviceTypeExtenden.ultraWide;
      case CameraDeviceType.telephoto:
        return CameraDeviceTypeExtenden.telephoto;
    }
  }
}

extension CameraDeviceTypeExtendenEX on CameraDeviceTypeExtenden {
  String get nativeName {
    switch (this) {
      case CameraDeviceTypeExtenden.wideAngle:
        return 'WideAngleCamera';
      case CameraDeviceTypeExtenden.telephoto:
        return 'TelephotoCamera';
      case CameraDeviceTypeExtenden.ultraWide:
        return 'UltraWideCamera';
      case CameraDeviceTypeExtenden.dual:
        return 'DualCamera';
      case CameraDeviceTypeExtenden.dualWide:
        return 'DualWideCamera';
      case CameraDeviceTypeExtenden.triple:
        return 'TripleCamera';
      case CameraDeviceTypeExtenden.trueDepth:
        return 'TrueDepthCamera';
      case CameraDeviceTypeExtenden.lLiDARDepth:
        return 'LiDARDepthCamera';
    }
  }

  static CameraDeviceTypeExtenden fromNativeName(String name) {
    switch (name) {
      case 'WideAngleCamera':
        return CameraDeviceTypeExtenden.wideAngle;
      case 'TelephotoCamera':
        return CameraDeviceTypeExtenden.wideAngle;
      case 'UltraWideCamera':
        return CameraDeviceTypeExtenden.wideAngle;
      case 'DualCamera':
        return CameraDeviceTypeExtenden.wideAngle;
      case 'DualWideCamera':
        return CameraDeviceTypeExtenden.wideAngle;
      case 'TripleCamera':
        return CameraDeviceTypeExtenden.wideAngle;
      case 'TrueDepthCamera':
        return CameraDeviceTypeExtenden.wideAngle;
      case 'LiDARDepthCamera':
        return CameraDeviceTypeExtenden.wideAngle;
    }

    return CameraDeviceTypeExtenden.wideAngle;
  }
}

extension TorchModeEX on TorchMode {
  static TorchMode modeFromName(String name) {
    switch (name) {
      case 'on':
        return TorchMode.on;
      case 'off':
        return TorchMode.off;
      case 'auto':
        return TorchMode.auto;
    }
    return TorchMode.off;
  }

  String get nativeName {
    switch (this) {
      case TorchMode.on:
        return 'on';
      case TorchMode.off:
        return 'off';
      case TorchMode.auto:
        return 'auto';
    }
  }
}
