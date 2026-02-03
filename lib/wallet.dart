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
    
    final data = mapToJsonRawMessage({
      'public_key': pubKey,
    });

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

  Future<ContractOutput> getWallet(String pubKey) async {
    if (pubKey.isEmpty) {
      throw ArgumentError('public key not set');
    }

    try {
      KeyManager.validateEDDSAPublicKeyHex(pubKey);
    } catch (e) {
      throw ArgumentError('invalid public key: $e');
    }

    const String method = METHOD_GET_WALLET_BY_PUBLIC_KEY;
    final JsonRawMessage data = mapToJsonRawMessage({
      'public_key': pubKey,
    });

    try {
      final contractOutput = await getState(
        to: pubKey,
        method: method,
        data: data,
      );
      return contractOutput;
    } catch (e) {
      throw Exception('failed to get state: $e');
    }
  }

  Future<ContractOutput> transferWallet({
  required String to,
  required String amount,
  int decimals = 0,
}) async {
  final from = _publicKeyHex!;
  if (from.isEmpty) throw ArgumentError('public key not set');

  if (to.isEmpty) throw ArgumentError('to address not set');
  if (to == from) throw ArgumentError('cannot transfer to the same address');
  KeyManager.validateEDDSAPublicKeyHex(to);

  if (amount.isEmpty) throw ArgumentError('amount not set');

  // Ajusta a quantidade se houver casas decimais
  String finalAmount = amount;
  if (decimals != 0) {
    try {
      finalAmount = DecimalRescaler.rescaleString(amount, 0, decimals);
    } catch (e) {
      throw Exception('failed to convert amount to big int: $e');
    }
  }

  const String method = METHOD_TRANSFER_WALLET;
  final Map<String, dynamic> data = {
    "amount": finalAmount,
    "from": from,
    "to": to,
  };
  final int version = 1;
  final String uuid7 = newUUID7();
  // Cria a transação
  final newTx = Transaction.create(
    chainID: _chainID,
    from: from,
    to: to,
    method: method,
    data: mapToJsonRawMessage(data),
    version: version,
    uuid7: uuid7,
  );

  final tx = newTx.get();
  late String txSigned;
  try {
    txSigned = signTransaction(_privateKeyHex!, tx) as String;
  } catch (e) {
    throw Exception('failed to sign transaction: $e');
  }

  // Envia a transação
  try {
    await sendTransaction(REQUEST_METHOD_SEND_TRANSACTION, txSigned, _replyTo);
  } catch (e) {
    throw Exception('failed to send transaction: $e');
  }

  // TODO: Mapear o ContractOutput como no Go (Transfer, Events, WalletSender/Receiver, etc.)
  final contractOutput = ContractOutput();

  return contractOutput;
}

}