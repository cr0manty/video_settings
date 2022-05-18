class TemperatureAndTintWhiteBalanceGains {
  const TemperatureAndTintWhiteBalanceGains({
    required this.temperature,
    required this.tint,
  });

  factory TemperatureAndTintWhiteBalanceGains.zero() =>
      const TemperatureAndTintWhiteBalanceGains(
        temperature: 1,
        tint: 1,
      );

  factory TemperatureAndTintWhiteBalanceGains.fromJson(
      Map<dynamic, dynamic> json,
      ) =>
      TemperatureAndTintWhiteBalanceGains(
        temperature: json['temperature']!,
        tint: json['tint']!,
      );

  final double temperature;
  final double tint;

  @override
  String toString() => toJson().toString();

  Map<String, double> toJson() => {
    'temperature': temperature,
    'tint': tint,
  };

  TemperatureAndTintWhiteBalanceGains copyWith({
    double? temperature,
    double? tint,
  }) =>
      TemperatureAndTintWhiteBalanceGains(
        temperature: temperature ?? this.temperature,
        tint: tint ?? this.tint,
      );
}
