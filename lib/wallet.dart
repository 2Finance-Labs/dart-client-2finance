part of two_finance_blockchain;


extension Wallet on TwoFinanceBlockchain {
  Future<ContractOutput> addWallet(String pubKey) async {
    if (pubKey.isEmpty) {
      throw ArgumentError('public key not set');
    }
    final from = pubKey;
    const String to = DEPLOY_CONTRACT_ADDRESS;
    const String contractVersion = WALLET_CONTRACT_V1;
    const String method = METHOD_ADD_WALLET;

    final data = {
      "amount": "0",
      "public_key": pubKey,
    };

    try {
      final contractOutput = await sendTransaction(
        from: from,
        to: to,
        contractVersion: contractVersion,
        method: method,
        data: data,
      );
      return contractOutput;
    } catch (e) {
      throw Exception('failed to send transaction: $e');
    }
  }

  Future<ContractOutput> getWallet(String pubKey) async {
    if (pubKey.isEmpty) {
      throw ArgumentError('public key not set');
    }

    try {
      KeyManager.validateEdDSAPublicKey(pubKey);
    } catch (e) {
      throw ArgumentError('invalid public key: $e');
    }

    const String contractVersion = WALLET_CONTRACT_V1;
    const String method = METHOD_GET_WALLET_BY_PUBLIC_KEY;
    final Map<String, dynamic> data = {
      'public_key': pubKey,
    };

    try {
      final contractOutput = await getState(
        contractVersion: contractVersion,
        method: method,
        data: data,
      );
      return contractOutput;
    } catch (e) {
      throw Exception('failed to get state: $e');
    }
  }
}