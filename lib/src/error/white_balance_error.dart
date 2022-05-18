class WhiteBalanceModeNotFound implements Exception {
  @override
  String toString() => 'White balance mode not found';
}

class WhilteBalanceLockIsNotSupported implements Exception {
  final String method;

  const WhilteBalanceLockIsNotSupported(this.method);

  @override
  String toString() => '$method is not supported'
      'use [isWhiteBalanceLockSupported] for check is lock mode is supported';
}

class WhiteBalanceGetTemperatureGainsError implements Exception {
  @override
  String toString() => 'Temperature or Tint is not available at this moment';
}

class WhiteBalanceConvertGainsError implements Exception {
  @override
  String toString() => 'Convert gains is not available at this moment';
}
