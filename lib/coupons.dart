part of 'two_finance_blockchain.dart';

extension CouponClient on TwoFinanceBlockchain {

  Future<types.ContractOutput> AddCoupon(
    String address,
    String tokenAddress,
    String programType,
    String percentageBPS,
    String fixedAmount,
    String minOrder,
    DateTime startAt,
    DateTime expiredAt,
    bool paused,
    bool stackable,
    int maxRedemptions,
    int perUserLimit,
    String passcodeHash,
  ) async {
    final from = _activePublicKey!;
    final to = address;
    final contractVersion = COUPON_CONTRACT_V1;
    final method = METHOD_ADD_COUPON;
    if (from.isEmpty) throw Exception("from address not set");
    KeyManager.validateEdDSAPublicKey(from);
    
    if (address.isEmpty) throw Exception("address not set");
    KeyManager.validateEdDSAPublicKey(address);
    if (tokenAddress.isEmpty) throw Exception("token address not set");
    KeyManager.validateEdDSAPublicKey(tokenAddress);
    if (!(programType == "percentage" || programType == "fixed-amount")) {
      throw Exception("invalid program_type: $programType");
    }
    if (programType == "percentage" && percentageBPS.isEmpty) {
      throw Exception("percentage_bps must be set for program_type=percentage");
    }
    if (programType == "fixed-amount" && fixedAmount.isEmpty) {
      throw Exception("fixed_amount must be set for program_type=fixed-amount");
    }

   
    final data = {
      "address": address,
      "token_address": tokenAddress,
      "program_type": programType,
      "percentage_bps": percentageBPS,
      "fixed_amount": fixedAmount,
      "min_order": minOrder,
      "start_at": startAt.toIso8601String(),
      "expired_at": expiredAt.toIso8601String(),
      "paused": paused,
      "stackable": stackable,
      "max_redemptions": maxRedemptions,
      "per_user_limit": perUserLimit,
      "passcode_hash": passcodeHash,
    };

    return await signAndSendTransaction(from: from, to: to, contractVersion: contractVersion, method: method, data: data);
  }

  Future<types.ContractOutput> UpdateCoupon(
    String address,
    String tokenAddress,
    String programType,
    String percentageBPS,
    String fixedAmount,
    String minOrder,
    DateTime startAt,
    DateTime expiredAt,
    bool stackable,
    int maxRedemptions,
    int perUserLimit,
    String passcodeHash,
  ) async {
    if (address.isEmpty) throw Exception("address not set");
    KeyManager.validateEdDSAPublicKey(address);
    /*if (tokenAddress.isNotEmpty &&
        !KeyManager.validateEdDSAPublicKey(tokenAddress)) {
      throw Exception("invalid token address: $tokenAddress");
    }*/
    if (programType.isNotEmpty &&
        !(programType == "percentage" || programType == "fixed-amount")) {
      throw Exception("invalid program_type: $programType");
    }

    final from = _activePublicKey!;
    final to = address;
    final contractVersion = COUPON_CONTRACT_V1;
    final method = METHOD_UPDATE_COUPON;
    if (from.isEmpty) throw Exception("from address not set");
    KeyManager.validateEdDSAPublicKey(from);
    final data = {
      "address": address,
      "token_address": tokenAddress,
      "program_type": programType,
      "percentage_bps": percentageBPS,
      "fixed_amount": fixedAmount,
      "min_order": minOrder,
      "start_at": startAt.toIso8601String(),
      "expired_at": expiredAt.toIso8601String(),
      "stackable": stackable,
      "max_redemptions": maxRedemptions,
      "per_user_limit": perUserLimit,
      "passcode_hash": passcodeHash,
    };

    return await signAndSendTransaction(from: from, to: to, contractVersion: contractVersion, method: method, data: data);
  }

  Future<types.ContractOutput> PauseCoupon(String address, bool pause) async {
    final from = _activePublicKey!;
    final to = address;
    final contractVersion = COUPON_CONTRACT_V1;
    final method = METHOD_PAUSE_COUPON;
    if (address.isEmpty) throw Exception("address not set");
    KeyManager.validateEdDSAPublicKey(address);
    if (!pause) throw Exception("pause must be true: paused=$pause");

    if (from.isEmpty) throw Exception("from address not set");
    KeyManager.validateEdDSAPublicKey(from);
    final data = {"address": address, "paused": pause};

    return await signAndSendTransaction(from: from, to: to, contractVersion: contractVersion, method: method, data: data);
  }

  Future<types.ContractOutput> UnpauseCoupon(String address, bool pause) async {
    final from = _activePublicKey!;
    final to = address;
    final contractVersion = COUPON_CONTRACT_V1;
    final method = METHOD_UNPAUSE_COUPON;
    if (address.isEmpty) throw Exception("address not set");
    KeyManager.validateEdDSAPublicKey(address);
    if (pause) throw Exception("pause must be false: paused=$pause");
    if (from.isEmpty) throw Exception("from address not set");
    KeyManager.validateEdDSAPublicKey(from);
    final data = {"address": address, "paused": pause};

    return await signAndSendTransaction(from: from, to: to, contractVersion: contractVersion, method: method, data: data);
  }

  Future<types.ContractOutput> RedeemCoupon(
    String address,
    String orderAmount,
    String passcode,
  ) async {
    final from = _activePublicKey!;
    final to = address;
    final contractVersion = COUPON_CONTRACT_V1;
    final method = METHOD_REDEEM_COUPON;
    if (address.isEmpty) throw Exception("address not set");
    KeyManager.validateEdDSAPublicKey(address);
    if (orderAmount.isEmpty) throw Exception("order_amount not set");
    if (passcode.isEmpty) throw Exception("passcode (preimage) not set");


    if (from.isEmpty) throw Exception("from address not set");
    KeyManager.validateEdDSAPublicKey(from);

    final data = {
      "address": address,
      "order_amount": orderAmount,
      "passcode": passcode,
    };

    return await signAndSendTransaction(from: from, to: to, contractVersion: contractVersion, method: method, data: data);
  }

  Future<types.ContractOutput> GetCoupon(String address) async {
    final from = _activePublicKey!;
    if (from.isEmpty) throw Exception("from address not set");
    KeyManager.validateEdDSAPublicKey(from);
    if (address.isEmpty) throw Exception("coupon address must be set");
    KeyManager.validateEdDSAPublicKey(address);

    final contractVersion = COUPON_CONTRACT_V1;
    final method = METHOD_GET_COUPON;
    final data = {"address": address};

    return await getState(contractVersion: contractVersion, method: method, data: data);
  }

  Future<types.ContractOutput> ListCoupons(
    String owner,
    String tokenAddress,
    String programType,
    bool? paused,
    int page,
    int limit,
    bool ascending,
  ) async {
    final from = _activePublicKey!;
    if (from.isEmpty) throw Exception("from address not set");
    KeyManager.validateEdDSAPublicKey(from);

    KeyManager.validateEdDSAPublicKey(owner);
    KeyManager.validateEdDSAPublicKey(tokenAddress);
    if (programType.isNotEmpty &&
        !(programType == "percentage" || programType == "fixed-amount")) {
      throw Exception("invalid program_type: $programType");
    }
    if (page < 1) throw Exception("page must be greater than 0");
    if (limit < 1) throw Exception("limit must be greater than 0");

    final contractVersion = COUPON_CONTRACT_V1;
    final method = METHOD_LIST_COUPONS;

    final data = {
      "owner": owner,
      "token_address": tokenAddress,
      "program_type": programType,
      "paused": paused,
      "page": page,
      "limit": limit,
      "ascending": ascending,
    };

    return await getState(contractVersion: contractVersion, method: method, data: data);
  }
}
