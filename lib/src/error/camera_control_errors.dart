class NotFoundCameraDevice implements Exception {
  final String? name;

  NotFoundCameraDevice({this.name});

  @override
  String toString() {
    if (name == null) {
      return 'CameraDevice not found';
    }

    return "CameraDevice '$name' not found";
  }
}

class ControllerNotInitialized implements Exception {
  final String methdod;

  const ControllerNotInitialized(this.methdod);

  @override
  String toString() => 'Callign method "$methdod" is not allowed,'
      'Controller not initialized, '
      'you have to call [init] first';
}
