import 'package:video_settings/src/enum/ios_enums.dart';

class CameraDevice {
  final String uniqueID;
  final String? localizedName;
  final CameraDeviceTypeExtenden? deviceType;
  final CameraDevicePosition? position;

  CameraDevice({
    required this.uniqueID,
    this.localizedName,
    this.deviceType,
    this.position,
  });

  factory CameraDevice.fromJson(Map<dynamic, dynamic> json) {
    CameraDeviceTypeExtenden? type;
    final deviceTypeString = json['deviceType'];

    if (deviceTypeString != null) {
      type = CameraDeviceTypeExtendenEX.fromNativeName(deviceTypeString);
    }

    CameraDevicePosition? position;
    final positionString = json['position'];

    if (positionString != null) {
      position = CameraDevicePositionEX.fromName(positionString);
    }

    return CameraDevice(
      uniqueID: json['uniqueID'] ?? '',
      deviceType: type,
      localizedName: json['localizedName'] ?? '',
      position: position,
    );
  }

  Map<String, dynamic> toJson() => {
        'uniqueID': uniqueID,
        'localizedName': localizedName,
        'deviceType': deviceType?.nativeName,
      };

  @override
  String toString() => toJson().toString();
}
