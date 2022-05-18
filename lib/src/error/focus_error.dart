class FocusModeNotFound implements Exception {
  @override
  String toString() => 'Focus mode not found';
}

class FocusLockLensNotSuported implements Exception {
  @override
  String toString() => 'setFocusPointLockedWithLensPosition is not '
      'supported on this device use '
      '[isLockingFocusWithCustomLensPositionSupported] to check is Lens '
      'Position Supported on this device';
}
