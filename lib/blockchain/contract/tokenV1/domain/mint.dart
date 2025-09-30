class Mint {
  final String tokenAddress;
  final String mintTo;
  final String amount;

  Mint({
    required this.tokenAddress,
    required this.mintTo,
    required this.amount,
  });

  factory Mint.fromJson(Map<String, dynamic> json) {
    return Mint(
      tokenAddress: json['token_address'] as String,
      mintTo: json['mint_to'] as String,
      amount: json['amount'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token_address': tokenAddress,
      'mint_to': mintTo,
      'amount': amount,
    };
  }

  @override
  String toString() =>
      'Mint(tokenAddress: $tokenAddress, mintTo: $mintTo, amount: $amount)';
}
