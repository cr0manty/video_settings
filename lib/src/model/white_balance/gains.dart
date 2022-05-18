class WhiteBalanceGains {
  const WhiteBalanceGains({
    required this.redGain,
    required this.greenGain,
    required this.blueGain,
  });

  factory WhiteBalanceGains.zero() => const WhiteBalanceGains(
        greenGain: 1,
        redGain: 1,
        blueGain: 1,
      );

  factory WhiteBalanceGains.fromJson(
    Map<dynamic, dynamic> json,
  ) =>
      WhiteBalanceGains(
        redGain: json['redGain']!,
        greenGain: json['greenGain']!,
        blueGain: json['blueGain']!,
      );

  final double redGain;
  final double greenGain;
  final double blueGain;

  bool get isZeroGains => redGain == 1.0 && greenGain == 1.0 && blueGain == 1.0;

  @override
  String toString() => toJson().toString();

  Map<String, double> toJson() => {
        'redGain': redGain,
        'greenGain': greenGain,
        'blueGain': blueGain,
      };

  WhiteBalanceGains copyWith({
    double? red,
    double? green,
    double? blue,
  }) =>
      WhiteBalanceGains(
        redGain: red ?? redGain,
        blueGain: blue ?? blueGain,
        greenGain: green ?? greenGain,
      );
}
