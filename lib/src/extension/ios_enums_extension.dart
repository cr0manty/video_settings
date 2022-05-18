import 'package:video_settings/src/enum/ios_enums.dart';

extension CameraDeviceTypeEX on CameraDeviceType {
  String get nativeName {
    switch (this) {
      case CameraDeviceType.telephoto:
        return 'TelephotoCamera';
      case CameraDeviceType.ultraWide:
        return 'UltraWideCamera';
      default:
        return 'WideAngleCamera';
    }
  }

  static CameraDeviceType typeByName(String name) {
    switch (name) {
      case 'TelephotoCamera':
        return CameraDeviceType.telephoto;
      case 'UltraWideCamera':
        return CameraDeviceType.ultraWide;
      default:
        return CameraDeviceType.wideAngle;
    }
  }

  bool get isDefaultCamera => this == CameraDeviceType.wideAngle;
}
