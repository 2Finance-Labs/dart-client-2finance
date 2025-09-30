class FeeTier {
  final String? tier;
  final String? value;

  FeeTier({this.tier, this.value});

  factory FeeTier.fromJson(Map<String, dynamic> json) {
    return FeeTier(
      tier: json['tier'] as String?,
      value: json['value'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tier': tier,
      'value': value,
    };
  }
}