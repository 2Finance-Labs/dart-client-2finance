class Burn {
  final String tokenAddress;
  final String burnFrom;
  final String amount;

  Burn({
    required this.tokenAddress,
    required this.burnFrom,
    required this.amount,
  });

  factory Burn.fromJson(Map<String, dynamic> json) {
    return Burn(
      tokenAddress: json['token_address'] as String,
      burnFrom: json['burn_from'] as String,
      amount: json['amount'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token_address': tokenAddress,
      'burn_from': burnFrom,
      'amount': amount,
    };
  }

  @override
  String toString() =>
      'Burn(tokenAddress: $tokenAddress, burnFrom: $burnFrom, amount: $amount)';
}
