import 'dart:async';

import 'package:two_finance_blockchain/blockchain/contract/cashbackV1.dart' as cashbackV1;
import 'package:two_finance_blockchain/blockchain/keys.dart' as keys;
import 'package:two_finance_blockchain/blockchain/types.dart';

class Cashback {
  final String publicKey;

  Cashback({required this.publicKey});

  /// Mock dos métodos SendTransaction e GetState
  /// Substitua com sua implementação real
  Future<ContractOutput> sendTransaction(
      String from,
      String to,
      String contractVersion,
      String method,
      Map<String, dynamic> data,
      ) async {
    // Implementação real aqui
    return ContractOutput();
  }

  Future<ContractOutput> getState(
      String contractVersion,
      String method,
      Map<String, dynamic> data,
      ) async {
    // Implementação real aqui
    return ContractOutput();
  }

  Future<ContractOutput> addCashback({
    required String owner,
    required String tokenAddress,
    required String programType,
    required String percentage,
    required DateTime startAt,
    required DateTime expiredAt,
    required bool paused,
  }) async {
    final from = publicKey;
    if (from.isEmpty) throw Exception("from address not set");
    keys.validateEDDSAPublicKey(from);

    if (owner.isEmpty) throw Exception("owner not set");
    keys.validateEDDSAPublicKey(owner);

    if (tokenAddress.isEmpty) throw Exception("token address not set");
    keys.validateEDDSAPublicKey(tokenAddress);

    if (programType != "fixed-percentage" && programType != "variable-percentage") {
      throw Exception("invalid programType: $programType");
    }
    if (percentage.isEmpty) throw Exception("percentage not set");

    final to = types.DEPLOY_CONTRACT_ADDRESS;
    final contractVersion = cashbackV1.CASHBACK_CONTRACT_V1;
    final method = cashbackV1.METHOD_ADD_CASHBACK;

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
      return await sendTransaction(from, to, contractVersion, method, data);
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
    keys.validateEDDSAPublicKey(address);

    if (tokenAddress.isNotEmpty) keys.validateEDDSAPublicKey(tokenAddress);

    if (programType != "fixed-percentage" && programType != "variable-percentage") {
      throw Exception("invalid programType: $programType");
    }
    if (percentage.isEmpty) throw Exception("percentage not set");

    final from = publicKey;
    if (from.isEmpty) throw Exception("from address not set");
    keys.validateEDDSAPublicKey(from);

    final to = address;
    final contractVersion = cashbackV1.CASHBACK_CONTRACT_V1;
    final method = cashbackV1.METHOD_UPDATE_CASHBACK;

    final data = {
      "address": address,
      "expired_at": expiredAt.toIso8601String(),
      "percentage": percentage,
      "program_type": programType,
      "start_at": startAt.toIso8601String(),
      "token_address": tokenAddress,
    };

    return sendTransaction(from, to, contractVersion, method, data);
  }

  Future<ContractOutput> pauseCashback(String address, bool pause) async {
    if (address.isEmpty) throw Exception("address not set");
    keys.validateEDDSAPublicKey(address);
    if (!pause) throw Exception("pause must be true: Pause: $pause");

    final from = publicKey;
    if (from.isEmpty) throw Exception("from address not set");
    keys.validateEDDSAPublicKey(from);

    final to = address;
    final contractVersion = cashbackV1.CASHBACK_CONTRACT_V1;
    final method = cashbackV1.METHOD_PAUSE_CASHBACK;

    final data = {"address": address, "paused": pause};

    return sendTransaction(from, to, contractVersion, method, data);
  }

  Future<ContractOutput> unpauseCashback(String address, bool pause) async {
    if (address.isEmpty) throw Exception("address not set");
    keys.validateEDDSAPublicKey(address);
    if (pause) throw Exception("pause must be false: Pause: $pause");

    final from = publicKey;
    if (from.isEmpty) throw Exception("from address not set");
    keys.validateEDDSAPublicKey(from);

    final to = address;
    final contractVersion = cashbackV1.CASHBACK_CONTRACT_V1;
    final method = cashbackV1.METHOD_UNPAUSE_CASHBACK;

    final data = {"address": address, "paused": pause};

    return sendTransaction(from, to, contractVersion, method, data);
  }

  Future<ContractOutput> depositCashbackFunds(
      String address, String tokenAddress, String amount) async {
    if (address.isEmpty) throw Exception("address not set");
    keys.validateEDDSAPublicKey(address);

    if (amount.isEmpty) throw Exception("amount not set");
    if (tokenAddress.isEmpty) throw Exception("token address not set");
    keys.validateEDDSAPublicKey(tokenAddress);

    final from = publicKey;
    if (from.isEmpty) throw Exception("from address not set");
    keys.validateEDDSAPublicKey(from);

    final to = address;
    final contractVersion = cashbackV1.CASHBACK_CONTRACT_V1;
    final method = cashbackV1.METHOD_DEPOSIT_CASHBACK;

    final data = {"address": address, "token_address": tokenAddress, "amount": amount};

    try {
      return await sendTransaction(from, to, contractVersion, method, data);
    } catch (e) {
      throw Exception("failed to deposit cashback: $e");
    }
  }

  Future<ContractOutput> withdrawCashbackFunds(
      String address, String tokenAddress, String amount) async {
    if (address.isEmpty) throw Exception("address not set");
    keys.validateEDDSAPublicKey(address);

    if (amount.isEmpty) throw Exception("amount not set");
    if (tokenAddress.isEmpty) throw Exception("token address not set");
    keys.validateEDDSAPublicKey(tokenAddress);

    final from = publicKey;
    if (from.isEmpty) throw Exception("from address not set");
    keys.validateEDDSAPublicKey(from);

    final to = address;
    final contractVersion = cashbackV1.CASHBACK_CONTRACT_V1;
    final method = cashbackV1.METHOD_WITHDRAW_CASHBACK;

    final data = {"address": address, "amount": amount, "token_address": tokenAddress};

    return sendTransaction(from, to, contractVersion, method, data);
  }

  Future<ContractOutput> getCashback(String address) async {
    final from = publicKey;
    if (from.isEmpty) throw Exception("from address not set");
    if (address.isEmpty) throw Exception("cashback address must be set");
    keys.validateEDDSAPublicKey(from);
    keys.validateEDDSAPublicKey(address);

    final contractVersion = cashbackV1.CASHBACK_CONTRACT_V1;
    final method = cashbackV1.METHOD_GET_CASHBACK;
    final data = {"address": address};

    return getState(contractVersion, method, data);
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
    final from = publicKey;
    if (from.isEmpty) throw Exception("from address not set");
    keys.validateEDDSAPublicKey(from);

    if (owner != null && owner.isNotEmpty) keys.validateEDDSAPublicKey(owner);
    if (tokenAddress != null && tokenAddress.isNotEmpty) keys.validateEDDSAPublicKey(tokenAddress);
    if (programType != null &&
        programType.isNotEmpty &&
        programType != "fixed-percentage" &&
        programType != "variable-percentage") {
      throw Exception("invalid programType: $programType");
    }
    if (page < 1) throw Exception("page must be greater than 0");
    if (limit < 1) throw Exception("limit must be greater than 0");

    final contractVersion = cashbackV1.CASHBACK_CONTRACT_V1;
    final method = cashbackV1.METHOD_LIST_CASHBACKS;
    final data = {
      "ascending": ascending,
      "limit": limit,
      "owner": owner,
      "page": page,
      "paused": paused,
      "program_type": programType,
      "token_address": tokenAddress,
    };
    return getState(contractVersion, method, data);
  }

  Future<ContractOutput> claimCashback(String address, String amount) async {
    if (address.isEmpty) throw Exception("address not set");
    keys.validateEDDSAPublicKey(address);
    if (amount.isEmpty) throw Exception("amount not set");

    final from = publicKey;
    if (from.isEmpty) throw Exception("from address not set");
    keys.validateEDDSAPublicKey(from);

    final to = address;
    final contractVersion = cashbackV1.CASHBACK_CONTRACT_V1;
    final method = cashbackV1.METHOD_CLAIM_CASHBACK;

    final data = {"address": address, "amount": amount};

    return sendTransaction(from, to, contractVersion, method, data);
  }
}
