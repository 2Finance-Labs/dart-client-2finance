part of two_finance_blockchain;


extension Wallet on TwoFinanceBlockchain {
  Future<ContractOutput> addWallet(String address, String pubKey) async {
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
      final contractOutput = await signAndSendTransaction(
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

  Future<ContractOutput> transferWallet({
  required String to,
  required String amount,
  int decimals = 0,
}) async {
  final from = _activePublicKey!;
  if (from.isEmpty) throw ArgumentError('public key not set');

  if (to.isEmpty) throw ArgumentError('to address not set');
  if (to == from) throw ArgumentError('cannot transfer to the same address');
  KeyManager.validateEdDSAPublicKey(to);

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

  const String contractVersion = WALLET_CONTRACT_V1;
  const String method = METHOD_TRANSFER_WALLET;
  final Map<String, dynamic> data = {
    "amount": finalAmount,
    "from": from,
    "to": to,
  };

  final DateTime timestamp = DateTime.now().toUtc();

  // Recupera nonce e incrementa
  int nonce;
  try {
    nonce = await getNonce(from);
    nonce += 1;
  } catch (e) {
    throw Exception('failed to get nonce: $e');
  }

  // Cria a transação
  final newTx = Transaction.create(
    from: from,
    to: to,
    contractVersion: contractVersion,
    method: method,
    data: data,
    nonce: nonce,
  );

  final tx = newTx.get();
  late String txSigned;
  try {
    txSigned = signTransaction(_activePrivateKey!, tx) as String;
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