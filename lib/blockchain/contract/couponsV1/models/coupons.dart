// lib/models/coupon_models.dart

class CouponStateModel {
  static const String tableName = "coupon_state_v1";

  final int? id;
  final String address;
  final String owner;
  final String tokenAddress;

  final String programType; // "percentage" | "fixed-amount"
  final String? percentageBps; // opcional se percentage
  final String? fixedAmount;   // opcional se fixed
  final String? minOrder;      // opcional

  final DateTime? startAt;
  final DateTime? expiredAt;

  final bool paused;
  final bool stackable;
  final int maxRedemptions; // 0 = ilimitado
  final int perUserLimit;   // 0 = ilimitado

  final String passcodeHash; // sha256(preimage) hex
  final int totalRedemptions;

  final String hash;
  final DateTime createdAt;
  final DateTime updatedAt;

  CouponStateModel({
    this.id,
    required this.address,
    required this.owner,
    required this.tokenAddress,
    required this.programType,
    this.percentageBps,
    this.fixedAmount,
    this.minOrder,
    this.startAt,
    this.expiredAt,
    this.paused = false,
    this.stackable = false,
    this.maxRedemptions = 0,
    this.perUserLimit = 0,
    required this.passcodeHash,
    this.totalRedemptions = 0,
    required this.hash,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CouponStateModel.fromJson(Map<String, dynamic> json) {
    return CouponStateModel(
      id: json['id'],
      address: json['address'] ?? '',
      owner: json['owner'] ?? '',
      tokenAddress: json['token_address'] ?? '',
      programType: json['program_type'] ?? '',
      percentageBps: json['percentage_bps'],
      fixedAmount: json['fixed_amount'],
      minOrder: json['min_order'],
      startAt: json['start_at'] != null ? DateTime.tryParse(json['start_at']) : null,
      expiredAt: json['expired_at'] != null ? DateTime.tryParse(json['expired_at']) : null,
      paused: json['paused'] ?? false,
      stackable: json['stackable'] ?? false,
      maxRedemptions: json['max_redemptions'] ?? 0,
      perUserLimit: json['per_user_limit'] ?? 0,
      passcodeHash: json['passcode_hash'] ?? '',
      totalRedemptions: json['total_redeems'] ?? 0,
      hash: json['hash'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'owner': owner,
      'token_address': tokenAddress,
      'program_type': programType,
      'percentage_bps': percentageBps,
      'fixed_amount': fixedAmount,
      'min_order': minOrder,
      'start_at': startAt?.toIso8601String(),
      'expired_at': expiredAt?.toIso8601String(),
      'paused': paused,
      'stackable': stackable,
      'max_redemptions': maxRedemptions,
      'per_user_limit': perUserLimit,
      'passcode_hash': passcodeHash,
      'total_redeems': totalRedemptions,
      'hash': hash,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class CouponUserRedeemModel {
  static const String tableName = "coupon_user_redeem_v1";

  final int? id;
  final String couponAddress;
  final String userAddress;
  final int count;
  final DateTime createdAt;
  final DateTime updatedAt;

  CouponUserRedeemModel({
    this.id,
    required this.couponAddress,
    required this.userAddress,
    this.count = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CouponUserRedeemModel.fromJson(Map<String, dynamic> json) {
    return CouponUserRedeemModel(
      id: json['id'],
      couponAddress: json['coupon_address'] ?? '',
      userAddress: json['user_address'] ?? '',
      count: json['count'] ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coupon_address': couponAddress,
      'user_address': userAddress,
      'count': count,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
