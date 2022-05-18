export '../extension/ios_enums_extension.dart';

enum ExposureMode {
  locked,
  autoExpose,
  continuousAutoExposure,
  custom,
}

enum WhiteBalanceMode {
  locked,
  autoWhiteBalance,
  continuousAutoWhiteBalance,
}

enum FocusMode {
  locked,
  autoFocus,
  continuousAutoFocus,
}

enum CameraDeviceType {
  wideAngle,
  ultraWide,
  telephoto,
}

enum CameraDevicePosition {
  unspecified,
  back,
  front,
}

enum CameraDeviceTypeExtenden {
  externalUnknown,
  wideAngle,
  telephoto,
  ultraWide,
  dual,
  dualWide,
  triple,
  trueDepth,
  lLiDARDepth,
}
