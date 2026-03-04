part of two_finance_blockchain;


extension Wallet on TwoFinanceBlockchain {
  Future<ContractOutput> addWallet(String address, String pubKey) async {
    if (pubKey.isEmpty) {
      throw ArgumentError('public key not set');
    }
    final chainID = _chainID;
    final from = pubKey;
    final String to = address;
    const String method = METHOD_ADD_WALLET;
    const int version = 1;
    final String uuid7 = newUUID7();
    
    final JsonMessage data = {
      'address': address,
      'public_key': pubKey,
    };

    try {
      final contractOutput = await signAndSendTransaction(
        chainID: chainID,
        from: from,
        to: to,
        method: method,
        data: data,
        version: version,
        uuid7: uuid7
      );
      return contractOutput;
    } catch (e) {
      throw Exception('failed to send transaction: $e');
    }
  }

  Future<ContractOutput> getWalletByPublicKey(String pubKey) async {
    if (pubKey.isEmpty) {
      throw ArgumentError('public key not set');
    }

    try {
      KeyManager.validateEDDSAPublicKeyHex(pubKey);
    } catch (e) {
      throw ArgumentError('invalid public key: $e');
    }

    const String method = METHOD_GET_WALLET_BY_PUBLIC_KEY;
    const String contractVersion = WALLET_CONTRACT_V1;
    final JsonMessage data = {
      'public_key': pubKey,
      'contract_version': contractVersion,
    };

    try {
      final contractOutput = await getState(
        to: '',
        method: method,
        data: data,
      );
      return contractOutput;
    } catch (e) {
      throw Exception('failed to get state: $e');
    }
  }

  Future<ContractOutput> getWalletByAddress(String address) async {
    if (address.isEmpty) {
      throw ArgumentError('address not set');
    }

    const String method = METHOD_GET_WALLET_BY_ADDRESS;
    const String contractVersion = WALLET_CONTRACT_V1;
    final JsonMessage data = {
      'address': address,
      'contract_version': contractVersion,
    };

    try {
      final contractOutput = await getState(
        to: '',
        method: method,
        data: data,
      );
      return contractOutput;
    } catch (e) {
      throw Exception('failed to get state: $e');
    }
  }

}