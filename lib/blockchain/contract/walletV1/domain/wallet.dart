//wallet.go
class Wallet {
  final String publicKey;
  final String amount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Wallet({
    required this.publicKey,
    required this.amount,
    this.createdAt,
    this.updatedAt,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      publicKey: json['public_key'] as String,
      amount: json['amount'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'public_key': publicKey,
      'amount': amount,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'Wallet(publicKey: $publicKey, amount: $amount, createdAt: $createdAt, updatedAt: $updatedAt)';
}