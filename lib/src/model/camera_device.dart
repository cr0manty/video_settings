import 'package:video_settings/src/enum/ios_enums.dart';

class CameraDevice {
  final String uniqueID;
  final String localizedName;
  final CameraDeviceType deviceType;

  CameraDevice({
    required this.uniqueID,
    required this.localizedName,
    required this.deviceType,
  });

  factory CameraDevice.fromJson(Map<String, dynamic> json) => CameraDevice(
        uniqueID: json['uniqueID'] ?? '',
        deviceType: json['deviceType'] ?? CameraDeviceType.wideAngle,
        localizedName: json['localizedName'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'uniqueID': uniqueID,
        'localizedName': localizedName,
        'deviceType': deviceType.nativeName,
      };

  @override
  String toString() => toJson().toString();
}
