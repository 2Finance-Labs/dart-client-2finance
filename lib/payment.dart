part of two_finance_blockchain;

extension PaymentClient on TwoFinanceBlockchain{
  Future<ContractOutput> createPayment({
    required String address,
    required String tokenAddress,
    required String orderId,
    required String payer,
    required String payee,
    required String amount,
    required DateTime expiredAt,
  }) async {
    final from = _activePublicKey!;
    final to = address;
    final contractVersion = PAYMENT_CONTRACT_V1;
    final method = METHOD_CREATE_PAYMENT;
    if (from.isEmpty) throw Exception("from address not set");
    KeyManager.validateEdDSAPublicKey(from);

    if (address.isEmpty) throw Exception("address not set");
    KeyManager.validateEdDSAPublicKey(address);

    if (tokenAddress.isEmpty) throw Exception("token address not set");
    KeyManager.validateEdDSAPublicKey(tokenAddress);

    if (payer.isEmpty) throw Exception("payer not set");
    KeyManager.validateEdDSAPublicKey(payer);

    if (payee.isEmpty) throw Exception("payee not set");
    KeyManager.validateEdDSAPublicKey(payee);

    if (payer == payee) {
      throw Exception("payee and payer cannot be the same: $payee - $payer");
    }

    if (orderId.isEmpty) throw Exception("order_id not set");
    if (amount.isEmpty) throw Exception("amount not set");
    if (expiredAt == DateTime(0)) throw Exception("expired_at not set");

    final data = {
      "address": address,
      "token_address": tokenAddress,
      "order_id": orderId,
      "payer": payer,
      "payee": payee,
      "amount": amount,
      "expired_at": expiredAt.toIso8601String(),
    };

    return signAndSendTransaction(from: from, to: to, contractVersion: contractVersion, method: method, data: data);
  }

  Future<ContractOutput> directPay({
    required String address,
    required String tokenAddress,
    required String orderId,
    required String payer,
    required String payee,
    required String amount,
  }) async {
    final to = _activePublicKey!;
    final from = address;
    final contractVersion = PAYMENT_CONTRACT_V1;
    final method = METHOD_DIRECT_PAY;
    if (to.isEmpty) throw Exception("from address not set");
    KeyManager.validateEdDSAPublicKey(_activePublicKey!);

    if (address.isEmpty) throw Exception("address not set");
    KeyManager.validateEdDSAPublicKey(address);

    if (tokenAddress.isEmpty) throw Exception("token address not set");
    KeyManager.validateEdDSAPublicKey(tokenAddress);

    if (payer.isEmpty) throw Exception("payer not set");
    KeyManager.validateEdDSAPublicKey(payer);

    if (payee.isEmpty) throw Exception("payee not set");
    KeyManager.validateEdDSAPublicKey(payee);

    if (orderId.isEmpty) throw Exception("order_id not set");
    if (amount.isEmpty) throw Exception("amount not set");

    final data = {
      "address": address,
      "token_address": tokenAddress,
      "order_id": orderId,
      "payer": payer,
      "payee": payee,
      "amount": amount,
    };

    return signAndSendTransaction(from: from, to: to, contractVersion: contractVersion, method: method, data: data);
    
  }

  Future<ContractOutput> authorizePayment(String address) async {
    final from = _activePublicKey!;
    final to = address;
    final contractVersion = PAYMENT_CONTRACT_V1;
    final method = METHOD_AUTHORIZE_PAYMENT;
    if (address.isEmpty) throw Exception("address not set");
    KeyManager.validateEdDSAPublicKey(address);

    if (from.isEmpty) throw Exception("from address not set");
    KeyManager.validateEdDSAPublicKey(from);

    final data = {"address": address};
    return signAndSendTransaction(from: from, to: to, contractVersion: contractVersion, method: method, data: data);
    
  }

  Future<ContractOutput> capturePayment(String address) async {
    final from = _activePublicKey!;
    final to = address;
    final contractVersion = PAYMENT_CONTRACT_V1;
    final method = METHOD_AUTHORIZE_PAYMENT;
    if (address.isEmpty) throw Exception("address not set");
    KeyManager.validateEdDSAPublicKey(address);

    if (from.isEmpty) throw Exception("from address not set");
    KeyManager.validateEdDSAPublicKey(from);

    final data = {"address": address};
    return signAndSendTransaction(from: from, to: to, contractVersion: contractVersion, method: method, data: data);
  }

  Future<ContractOutput> refundPayment(String address, String amount) async {
    final from = _activePublicKey!;
    final to = address;
    final contractVersion = PAYMENT_CONTRACT_V1;
    final method = METHOD_REFUND_PAYMENT;
    if (address.isEmpty) throw Exception("address not set");
    KeyManager.validateEdDSAPublicKey(address);

    if (amount.isEmpty) throw Exception("amount not set");

    if (from.isEmpty) throw Exception("from address not set");
    KeyManager.validateEdDSAPublicKey(from);

    final data = {"address": address, "amount": amount};
    return signAndSendTransaction(from: from, to: to, contractVersion: contractVersion, method: method, data: data);
  }

  Future<ContractOutput> voidPayment(String address) async {
    final from = _activePublicKey!;
    final to = address;
    final contractVersion = PAYMENT_CONTRACT_V1;
    final method = METHOD_VOID_PAYMENT;
    if (address.isEmpty) throw Exception("address not set");
    KeyManager.validateEdDSAPublicKey(address);

    if (from.isEmpty) throw Exception("from address not set");
    KeyManager.validateEdDSAPublicKey(from);

    final data = {"address": address};
    return signAndSendTransaction(from: from, to: to, contractVersion: contractVersion, method: method, data: data);
  }

  Future<ContractOutput> pausePayment(String address, bool paused) async {
    final from = _activePublicKey!;
    final to = address;
    final contractVersion = PAYMENT_CONTRACT_V1;
    final method = METHOD_PAUSE_PAYMENT;
    if (address.isEmpty) throw Exception("address not set");
    KeyManager.validateEdDSAPublicKey(address);

    if (!paused) throw Exception("paused must be true: Pause: $paused");

    if (from.isEmpty) throw Exception("from address not set");
    KeyManager.validateEdDSAPublicKey(from);

    final data = {"address": address, "paused": paused};
    return signAndSendTransaction(from: from, to: to, contractVersion: contractVersion, method: method, data: data);
  }

  Future<ContractOutput> unpausePayment(String address, bool paused) async {
    final from = _activePublicKey!;
    final to = address;
    final contractVersion = PAYMENT_CONTRACT_V1;
    final method = METHOD_UNPAUSE_PAYMENT;
    if (address.isEmpty) throw Exception("address not set");
    KeyManager.validateEdDSAPublicKey(address);

    if (paused) throw Exception("paused must be false: Pause: $paused");

    if (from.isEmpty) throw Exception("from address not set");
    KeyManager.validateEdDSAPublicKey(from);

    final data = {"address": address, "paused": paused};
    return signAndSendTransaction(from: from, to: to, contractVersion: contractVersion, method: method, data: data);
  }

  Future<ContractOutput> getPayment(String address) async {
    final from = _activePublicKey!;
    final to = address;
    final contractVersion = PAYMENT_CONTRACT_V1;
    final method = METHOD_GET_PAYMENT;

    if (from.isEmpty) throw Exception("from address not set");
    KeyManager.validateEdDSAPublicKey(from);

    if (address.isEmpty) throw Exception("payment address must be set");
    KeyManager.validateEdDSAPublicKey(address);

    final data = {"address": address};
    return getState(contractVersion: contractVersion, method: method, data: data);
  }

  Future<ContractOutput> listPayments({
    String payer = "",
    String payee = "",
    String orderId = "",
    String tokenAddress = "",
    List<String> status = const [],
    int page = 1,
    int limit = 10,
    bool ascending = false,
  }) async {
    final publicKey = _activePublicKey!;

    if (publicKey.isEmpty) throw Exception("from address not set");
    KeyManager.validateEdDSAPublicKey(publicKey);

    if (tokenAddress.isNotEmpty) KeyManager.validateEdDSAPublicKey(tokenAddress);
    if (payer.isNotEmpty) KeyManager.validateEdDSAPublicKey(payer);
    if (payee.isNotEmpty) KeyManager.validateEdDSAPublicKey(payee);

    if (page < 1) throw Exception("page must be greater than 0");
    if (limit < 1) throw Exception("limit must be greater than 0");

    final data = {
      "token_address": tokenAddress,
      "status": status,
      "payer": payer,
      "payee": payee,
      "page": page,
      "limit": limit,
      "ascending": ascending,
    };

    return getState(contractVersion: PAYMENT_CONTRACT_V1, method: METHOD_LIST_PAYMENTS, data: data);
  }
}
