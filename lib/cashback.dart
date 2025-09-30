
part of 'two_finance_blockchain.dart';
extension Cashback on TwoFinanceBlockchain{

  /// Mock dos métodos SendTransaction e GetState
  /// Substitua com sua implementação real

  Future<ContractOutput> addCashback({
    required String owner,
    required String tokenAddress,
    required String programType,
    required String percentage,
    required DateTime startAt,
    required DateTime expiredAt,
    required bool paused,
  }) async {
    final from = _activePublicKey!;
    if (from.isEmpty) throw Exception("from address not set");
    KeyManager.validateEdDSAPublicKey(from!);
    //keys.validateEDDSAPublicKey(from);

    if (owner.isEmpty) throw Exception("owner not set");
    KeyManager.validateEdDSAPublicKey(owner);
    //keys.validateEDDSAPublicKey(owner);

    if (tokenAddress.isEmpty) throw Exception("token address not set");
    KeyManager.validateEdDSAPublicKey(tokenAddress);
    //keys.validateEDDSAPublicKey(tokenAddress);

    if (programType != "fixed-percentage" && programType != "variable-percentage") {
      throw Exception("invalid programType: $programType");
    }
    if (percentage.isEmpty) throw Exception("percentage not set");

    final to = types.DEPLOY_CONTRACT_ADDRESS;
    final contractVersion = CASHBACK_CONTRACT_V1;
    final method = METHOD_ADD_CASHBACK;

    final data = {
      "expired_at": expiredAt.toIso8601String(),
      "owner": owner,
      "paused": paused,
      "percentage": percentage,
      "program_type": programType,
      "start_at": startAt.toIso8601String(),
      "token_address": tokenAddress,
    };

    try {
      return await signAndSendTransaction(from: from, to: to, contractVersion: contractVersion, method: method, data: data);
    } catch (e) {
      throw Exception("failed to add cashback: $e");
    }
  }

  Future<ContractOutput> updateCashback({
    required String address,
    required String tokenAddress,
    required String programType,
    required String percentage,
    required DateTime startAt,
    required DateTime expiredAt,
  }) async {
    if (address.isEmpty) throw Exception("address not set");
    KeyManager.validateEdDSAPublicKey(address);
    //keys.validateEDDSAPublicKey(address);

    if (tokenAddress.isNotEmpty) KeyManager.validateEdDSAPublicKey(tokenAddress);//keys.validateEDDSAPublicKey(tokenAddress);

    if (programType != "fixed-percentage" && programType != "variable-percentage") {
      throw Exception("invalid programType: $programType");
    }
    if (percentage.isEmpty) throw Exception("percentage not set");

    final from = _activePublicKey!;
    if (from.isEmpty) throw Exception("from address not set");
    KeyManager.validateEdDSAPublicKey(from!);
    //keys.validateEDDSAPublicKey(from);

    final to = address;
    final contractVersion = CASHBACK_CONTRACT_V1;
    final method = METHOD_UPDATE_CASHBACK;

    final data = {
      "address": address,
      "expired_at": expiredAt.toIso8601String(),
      "percentage": percentage,
      "program_type": programType,
      "start_at": startAt.toIso8601String(),
      "token_address": tokenAddress,
    };

    return signAndSendTransaction(from: from, to: to, contractVersion: contractVersion, method: method, data: data);
  }

  Future<ContractOutput> pauseCashback(String address, bool pause) async {
    if (address.isEmpty) throw Exception("address not set");
    //keys.validateEDDSAPublicKey(address);
    KeyManager.validateEdDSAPublicKey(address);
    if (!pause) throw Exception("pause must be true: Pause: $pause");

    final from = _activePublicKey!;
    if (from.isEmpty) throw Exception("from address not set");
    
    KeyManager.validateEdDSAPublicKey(from);

    final to = address;
    final contractVersion = CASHBACK_CONTRACT_V1;
    final method = METHOD_PAUSE_CASHBACK;

    final data = {"address": address, "paused": pause};

    return signAndSendTransaction(from: from, to: to, contractVersion: contractVersion, method: method, data: data);
  }

  Future<ContractOutput> unpauseCashback(String address, bool pause) async {
    if (address.isEmpty) throw Exception("address not set");
    //keys.validateEDDSAPublicKey(address);
    KeyManager.validateEdDSAPublicKey(address);
    if (pause) throw Exception("pause must be false: Pause: $pause");

    final from = _activePrivateKey!;
    if (from.isEmpty) throw Exception("from address not set");
    //keys.validateEDDSAPublicKey(from);
    KeyManager.validateEdDSAPublicKey(from);
    final to = address;
    final contractVersion = CASHBACK_CONTRACT_V1;
    final method = METHOD_UNPAUSE_CASHBACK;

    final data = {"address": address, "paused": pause};

    return signAndSendTransaction(from: from, to: to, contractVersion: contractVersion, method: method, data: data);
  }

  Future<ContractOutput> depositCashbackFunds(
      String address, String tokenAddress, String amount) async {
    if (address.isEmpty) throw Exception("address not set");
    //keys.validateEDDSAPublicKey(address);
    KeyManager.validateEdDSAPublicKey(address);
    if (amount.isEmpty) throw Exception("amount not set");
    if (tokenAddress.isEmpty) throw Exception("token address not set");
    //keys.validateEDDSAPublicKey(tokenAddress);
    KeyManager.validateEdDSAPublicKey(tokenAddress);
    final from = _activePublicKey!;
    if (from.isEmpty) throw Exception("from address not set");
    //keys.validateEDDSAPublicKey(from);
    KeyManager.validateEdDSAPublicKey(from);
    final to = address;
    final contractVersion = CASHBACK_CONTRACT_V1;
    final method = METHOD_DEPOSIT_CASHBACK;

    final data = {"address": address, "token_address": tokenAddress, "amount": amount};

    try {
      return await signAndSendTransaction(from: from, to: to, contractVersion: contractVersion, method: method, data: data);
    } catch (e) {
      throw Exception("failed to deposit cashback: $e");
    }
  }

  Future<ContractOutput> withdrawCashbackFunds(
      String address, String tokenAddress, String amount) async {
    if (address.isEmpty) throw Exception("address not set");
    //keys.validateEDDSAPublicKey(address);
    KeyManager.validateEdDSAPublicKey(address);
    if (amount.isEmpty) throw Exception("amount not set");
    if (tokenAddress.isEmpty) throw Exception("token address not set");
    //keys.validateEDDSAPublicKey(tokenAddress);
    KeyManager.validateEdDSAPublicKey(tokenAddress);
    final from = _activePublicKey!;
    if (from.isEmpty) throw Exception("from address not set");
    KeyManager.validateEdDSAPublicKey(from);
    //keys.validateEDDSAPublicKey(from);

    final to = address;
    final contractVersion = CASHBACK_CONTRACT_V1;
    final method = METHOD_WITHDRAW_CASHBACK;

    final data = {"address": address, "amount": amount, "token_address": tokenAddress};

    return signAndSendTransaction(from: from, to: to, contractVersion: contractVersion, method: method, data: data);
  }

  Future<ContractOutput> getCashback(String address) async {
    final from = _activePublicKey!;
    if (from.isEmpty) throw Exception("from address not set");
    if (address.isEmpty) throw Exception("cashback address must be set");
    KeyManager.validateEdDSAPublicKey(from);
    KeyManager.validateEdDSAPublicKey(address);

    final contractVersion = CASHBACK_CONTRACT_V1;
    final method = METHOD_GET_CASHBACK;
    final data = {"address": address};

    return getState(contractVersion: contractVersion, method: method, data: data);
  }

  Future<ContractOutput> listCashbacks({
    String? owner,
    String? tokenAddress,
    String? programType,
    required bool paused,
    required int page,
    required int limit,
    required bool ascending,
  }) async {
    final from = _activePublicKey!;
    if (from.isEmpty) throw Exception("from address not set");
    KeyManager.validateEdDSAPublicKey(from);
    //keys.validateEDDSAPublicKey(from);

    if (owner != null && owner.isNotEmpty) KeyManager.validateEdDSAPublicKey(owner);//keys.validateEDDSAPublicKey(owner);
    if (tokenAddress != null && tokenAddress.isNotEmpty) KeyManager.validateEdDSAPublicKey(tokenAddress);//keys.validateEDDSAPublicKey(tokenAddress);
    if (programType != null &&
        programType.isNotEmpty &&
        programType != "fixed-percentage" &&
        programType != "variable-percentage") {
      throw Exception("invalid programType: $programType");
    }
    if (page < 1) throw Exception("page must be greater than 0");
    if (limit < 1) throw Exception("limit must be greater than 0");

    final contractVersion = CASHBACK_CONTRACT_V1;
    final method = METHOD_LIST_CASHBACKS;
    final data = {
      "ascending": ascending,
      "limit": limit,
      "owner": owner,
      "page": page,
      "paused": paused,
      "program_type": programType,
      "token_address": tokenAddress,
    };
    return getState(contractVersion: contractVersion, method: method, data: data);
  }

  Future<ContractOutput> claimCashback(String address, String amount) async {
    if (address.isEmpty) throw Exception("address not set");
    KeyManager.validateEdDSAPublicKey(address);
    //keys.validateEDDSAPublicKey(address);
    if (amount.isEmpty) throw Exception("amount not set");

    final from = _activePublicKey!;
    if (from.isEmpty) throw Exception("from address not set");
    KeyManager.validateEdDSAPublicKey(from);
    //keys.validateEDDSAPublicKey(from);

    final to = address;
    final contractVersion = CASHBACK_CONTRACT_V1;
    final method = METHOD_CLAIM_CASHBACK;

    final data = {"address": address, "amount": amount};

    return signAndSendTransaction(from: from, to: to, contractVersion: contractVersion, method: method, data: data);
  }
}
