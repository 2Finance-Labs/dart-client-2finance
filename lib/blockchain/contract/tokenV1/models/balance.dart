class BalanceStateModel {
  final int? id;
  final String? tokenAddress;
  final String? ownerAddress;
  final String? amount;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BalanceStateModel({
    this.id,
    this.tokenAddress,
    this.ownerAddress,
    this.amount,
    this.createdAt,
    this.updatedAt,
  });

  factory BalanceStateModel.fromJson(Map<String, dynamic> json) {
    int? _parseInt(dynamic v) {
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
      return null;
    }

    DateTime? _parseDate(dynamic v) {
      if (v is String) return DateTime.tryParse(v);
      return null;
    }

    return BalanceStateModel(
      id: _parseInt(json['id']),
      tokenAddress: json['token_address'] as String?,
      ownerAddress: json['owner_address'] as String?,
      amount: json['amount'] as String?,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'token_address': tokenAddress,
      'owner_address': ownerAddress,
      'amount': amount,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'Balance(tokenAddress: $tokenAddress, ownerAddress: $ownerAddress, amount: $amount)';

}
