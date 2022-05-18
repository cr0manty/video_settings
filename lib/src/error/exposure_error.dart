class ExposureModeNotFound implements Exception {
  @override
  String toString() => 'Exposure mode not found';
}

class ExposureNotEnoughtDurationData implements Exception {
  @override
  String toString() => 'Exposure not enought duration data';
}