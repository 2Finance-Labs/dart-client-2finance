part of 'two_finance_blockchain.dart';

extension Token on TwoFinanceBlockchain {

  Future<ContractOutput> addToken({
    required String symbol,
    required String name,
    required int decimals,
    required String totalSupply,
    required String description,
    required String owner,
    required String image,
    required String website,
    required Map<String, String> tagsSocialMedia,
    required Map<String, String> tagsCategory,
    required Map<String, String> tags,
    required String creator,
    required String creatorWebsite,
    required Map<String, bool> allowUsers,
    required Map<String, bool> blockUsers,
    required List<Map<String, dynamic>> feeTiersList,
    required String feeAddress,
    bool freezeAuthorityRevoked = false,
    bool mintAuthorityRevoked = false,
    bool updateAuthorityRevoked = false,
    bool paused = false,
    required DateTime expiredAt,
  }) async {
    // Validate required fields
    if (symbol.isEmpty) throw ArgumentError('symbol not set');
    if (name.isEmpty) throw ArgumentError('name not set');
    if (totalSupply.isEmpty) throw ArgumentError('total supply not set');
    if (owner.isEmpty) throw ArgumentError('owner not set');
    if (creator.isEmpty) throw ArgumentError('creator not set');
    if (creatorWebsite.isEmpty) throw ArgumentError('creator website not set');
    if (image.isEmpty) throw ArgumentError('image not set');
    if (website.isEmpty) throw ArgumentError('website not set');
    if (feeAddress.isEmpty) throw ArgumentError('fee address not set');

    // Validate keys
    KeyManager.validateEdDSAPublicKey(feeAddress);
    validateUserMap(allowUsers, 'allow users');
    validateUserMap(blockUsers, 'block users');

    final String from = _activePublicKey!;
    if (from.isEmpty) throw ArgumentError('from address not set');
    KeyManager.validateEdDSAPublicKey(from);

    const String to = DEPLOY_CONTRACT_ADDRESS;
    const String contractVersion = TOKEN_CONTRACT_V1;
    const String method = METHOD_ADD_TOKEN;

    final Map<String, dynamic> data = {
      "allow_users": allowUsers,
      "block_users": blockUsers,
      "creator": creator,
      "creator_website": creatorWebsite,
      "decimals": decimals,
      "description": description,
      "expired_at": expiredAt.toUtc().toIso8601String(),
      "fee_address": feeAddress,
      "fee_tiers_list": feeTiersList,
      "freeze_authority_revoked": freezeAuthorityRevoked,
      "image": image,
      "mint_authority_revoked": mintAuthorityRevoked,
      "name": name,
      "owner": owner,
      "paused": paused,
      "symbol": symbol,
      "tags": tags,
      "tags_category": tagsCategory,
      "tags_social_media": tagsSocialMedia,
      "total_supply": totalSupply,
      "update_authority_revoked": updateAuthorityRevoked,
      "website": website,
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

  Future<ContractOutput> mintToken({
    required String to,         // Token contract address
    required String mintTo,     // Recipient address
    required String amount,
    required int decimals,
  }) async {
    final String from = _activePublicKey!;
    if (from.isEmpty) throw ArgumentError('from address not set');
    if (to.isEmpty) throw ArgumentError('token address not set');
    if (mintTo.isEmpty) throw ArgumentError('mint to address not set');
    if (amount.isEmpty) throw ArgumentError('amount not set');

    // Validate keys
    KeyManager.validateEdDSAPublicKey(from);
    KeyManager.validateEdDSAPublicKey(to);
    KeyManager.validateEdDSAPublicKey(mintTo);

    // Convert amount if decimals > 0
    String finalAmount = amount;
    if (decimals != 0) {
      try {
        finalAmount = DecimalRescaler.rescaleString(amount, 0, decimals);
      } catch (e) {
        throw Exception('failed to convert amount to target decimals: $e');
      }
    }

    const String contractVersion = TOKEN_CONTRACT_V1;
    const String method = METHOD_MINT_TOKEN;

    final Map<String, dynamic> data = {
      "amount": finalAmount,
      "mint_to": mintTo,
      "token_address": to,
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

Future<ContractOutput> burnToken({
  required String to,       // Token contract address
  required String amount,
  required int decimals,
}) async {
  final String from = _activePublicKey!;
  if (from.isEmpty) throw ArgumentError('from address not set');
  if (to.isEmpty) throw ArgumentError('token address not set');
  if (amount.isEmpty) throw ArgumentError('amount not set');

  // Validate keys
  KeyManager.validateEdDSAPublicKey(from);
  KeyManager.validateEdDSAPublicKey(to);

  // Convert amount if decimals > 0
  String finalAmount = amount;
  if (decimals != 0) {
    try {
      finalAmount = DecimalRescaler.rescaleString(amount, 0, decimals);
    } catch (e) {
      throw Exception('failed to convert amount to target decimals: $e');
    }
  }

  const String contractVersion = TOKEN_CONTRACT_V1;
  const String method = METHOD_BURN_TOKEN;

  // Ordem alfabética das chaves
  final Map<String, dynamic> data = {
    "amount": finalAmount,
    "token_address": to,
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

Future<ContractOutput> transferToken({
  required String tokenAddress,  // Token contract address
  required String transferTo,    // Recipient address
  required String amount,
  required int decimals,
}) async {
  final String from = _activePublicKey!;
  if (from.isEmpty) throw ArgumentError('from address not set');
  if (transferTo.isEmpty) throw ArgumentError('to address not set');
  if (tokenAddress.isEmpty) throw ArgumentError('token address not set');
  if (amount.isEmpty) throw ArgumentError('amount not set');
  if (from == transferTo) throw ArgumentError('from and to addresses are the same');

  // Validate keys
  KeyManager.validateEdDSAPublicKey(from);
  KeyManager.validateEdDSAPublicKey(transferTo);
  KeyManager.validateEdDSAPublicKey(tokenAddress);

  // Convert amount if decimals > 0
  String finalAmount = amount;
  if (decimals != 0) {
    try {
      finalAmount = DecimalRescaler.rescaleString(amount, 0, decimals);
    } catch (e) {
      throw Exception('failed to convert amount to target decimals: $e');
    }
  }

  const String contractVersion = TOKEN_CONTRACT_V1;
  const String method = METHOD_TRANSFER_TOKEN;

  // Ordem alfabética das chaves
  final Map<String, dynamic> data = {
    "amount": finalAmount,
    "token_address": tokenAddress,
    "transfer_to": transferTo,
  };

  try {
    final contractOutput = await signAndSendTransaction(
      from: from,
      to: tokenAddress,
      contractVersion: contractVersion,
      method: method,
      data: data,
    );
    return contractOutput;
  } catch (e) {
    throw Exception('failed to send transaction: $e');
  }
}

Future<ContractOutput> allowUsers({
  required String tokenAddress,
  required Map<String, bool> users,
}) async {
  final String from = _activePublicKey!;
  if (from.isEmpty) throw ArgumentError('from address not set');
  if (tokenAddress.isEmpty) throw ArgumentError('token address not set');
  if (users.isEmpty) throw ArgumentError('users map is empty');

  // Validate keys
  KeyManager.validateEdDSAPublicKey(from);
  KeyManager.validateEdDSAPublicKey(tokenAddress);

  // Validate users map
  try {
    validateUserMap(users, 'allow users');
  } catch (e) {
    throw Exception('invalid allow users: $e');
  }

  const String contractVersion = TOKEN_CONTRACT_V1;
  const String method = METHOD_ALLOW_USERS;

  // Ordem alfabética das chaves
  final Map<String, dynamic> data = {
    "address": tokenAddress,
    "allow_users": users,
  };

  try {
    final contractOutput = await signAndSendTransaction(
      from: from,
      to: tokenAddress,
      contractVersion: contractVersion,
      method: method,
      data: data,
    );
    return contractOutput;
  } catch (e) {
    throw Exception('failed to send transaction: $e');
  }
}

Future<ContractOutput> disallowUsers({
  required String tokenAddress,
  required Map<String, bool> users,
}) async {
  final String from = _activePublicKey!;
  if (from.isEmpty) throw ArgumentError('from address not set');
  if (tokenAddress.isEmpty) throw ArgumentError('token address not set');
  if (users.isEmpty) throw ArgumentError('users map is empty');

  // Validate keys
  KeyManager.validateEdDSAPublicKey(from);
  KeyManager.validateEdDSAPublicKey(tokenAddress);

  // Validate users map
  try {
    validateUserMap(users, 'disallow users');
  } catch (e) {
    throw Exception('invalid disallow users: $e');
  }

  const String contractVersion = TOKEN_CONTRACT_V1;
  const String method = METHOD_DISALLOW_USERS;

  // Ordem alfabética das chaves
  final Map<String, dynamic> data = {
    "address": tokenAddress,
    "allow_users": users,
  };

  try {
    final contractOutput = await signAndSendTransaction(
      from: from,
      to: tokenAddress,
      contractVersion: contractVersion,
      method: method,
      data: data,
    );
    return contractOutput;
  } catch (e) {
    throw Exception('failed to send transaction: $e');
  }
}

Future<ContractOutput> unblockUsers({
  required String tokenAddress,
  required Map<String, bool> users,
}) async {
  final String from = _activePublicKey!;
  if (from.isEmpty) throw ArgumentError('from address not set');
  if (tokenAddress.isEmpty) throw ArgumentError('token address not set');
  if (users.isEmpty) throw ArgumentError('users map is empty');

  // Validate keys
  KeyManager.validateEdDSAPublicKey(from);
  KeyManager.validateEdDSAPublicKey(tokenAddress);

  // Validate users map
  try {
    validateUserMap(users, 'unblock users');
  } catch (e) {
    throw Exception('invalid unblock users: $e');
  }

  const String contractVersion = TOKEN_CONTRACT_V1;
  const String method = METHOD_UNBLOCK_USERS;

  // Ordem alfabética das chaves
  final Map<String, dynamic> data = {
    "address": tokenAddress,
    "block_users": users,
  };

  try {
    final contractOutput = await signAndSendTransaction(
      from: from,
      to: tokenAddress,
      contractVersion: contractVersion,
      method: method,
      data: data,
    );
    return contractOutput;
  } catch (e) {
    throw Exception('failed to send transaction: $e');
  }
}

Future<ContractOutput> revokeFreezeAuthority({
  required String tokenAddress,
  required bool revoke,
}) async {
  final String from = _activePublicKey!;
  if (from.isEmpty) throw ArgumentError('from address not set');
  if (tokenAddress.isEmpty) throw ArgumentError('token address not set');

  // Validate keys
  KeyManager.validateEdDSAPublicKey(from);
  KeyManager.validateEdDSAPublicKey(tokenAddress);

  const String contractVersion = TOKEN_CONTRACT_V1;
  const String method = METHOD_REVOKE_FREEZE_AUTHORITY;

  // Ordem alfabética das chaves
  final Map<String, dynamic> data = {
    "address": tokenAddress,
    "freeze_authority_revoked": revoke,
  };

  try {
    final contractOutput = await signAndSendTransaction(
      from: from,
      to: tokenAddress,
      contractVersion: contractVersion,
      method: method,
      data: data,
    );
    return contractOutput;
  } catch (e) {
    throw Exception('failed to send transaction: $e');
  }
}

Future<ContractOutput> revokeUpdateAuthority({
    required String tokenAddress,
    required bool revoke,
  }) async {
  final from = _activePublicKey!;
  if (from.isEmpty) {
    throw Exception("from address not set");
  }
  if (tokenAddress.isEmpty) {
    throw Exception("token address not set");
  }

 KeyManager.validateEdDSAPublicKey(from);
  if (tokenAddress.isNotEmpty) {
    KeyManager.validateEdDSAPublicKey(tokenAddress);
  }
  if (from.isNotEmpty) {
    KeyManager.validateEdDSAPublicKey(from);
  }

 /* if (!KeyManager.validateEdDSAPublicKey(from)) {
    throw Exception("invalid from address");
  }

  if (!KeyManager.isValidPublicKey(tokenAddress)) {
    throw Exception("invalid token address");
  }
*/
  const contractVersion = TOKEN_CONTRACT_V1;
  const method = METHOD_REVOKE_UPDATE_AUTHORITY;

  final data = {
    "address": tokenAddress,
    "update_authority_revoked": revoke,
  };

  try {
    final contractOutput = await signAndSendTransaction(
      from: from,
      to: tokenAddress,
      contractVersion: contractVersion,
      method: method,
      data: data,
    );
    return contractOutput;
  } catch (e) {
    throw Exception("failed to send transaction: $e");
  }
}

Future<ContractOutput> revokeMintAuthority({
  required String tokenAddress,
  required bool revoke,
}) async {
  final from = _activePublicKey ?? "";
  if (from.isEmpty) {
    throw Exception("from address not set");
  }
  if (tokenAddress.isEmpty) {
    throw Exception("token address not set");
  }

  // validações de chave
  KeyManager.validateEdDSAPublicKey(from);
  KeyManager.validateEdDSAPublicKey(tokenAddress);

  const contractVersion = TOKEN_CONTRACT_V1;
  const method = METHOD_REVOKE_MINT_AUTHORITY;

  final data = {
    "address": tokenAddress,
    "mint_authority_revoked": revoke,
  };

  try {
    final contractOutput = await signAndSendTransaction(
      from: from,
      to: tokenAddress,
      contractVersion: contractVersion,
      method: method,
      data: data,
    );
    return contractOutput;
  } catch (e) {
    throw Exception("failed to send transaction: $e");
  }
}


Future<ContractOutput> updateMetadata(
  String publicKey,
  String tokenAddress,
  String symbol,
  String name,
  int decimals,
  String description,
  String image,
  String website,
  Map<String, String> tagsSocialMedia,
  Map<String, String> tagsCategory,
  Map<String, String> tags,
  String creator,
  String creatorWebsite,
  DateTime expiredAt,
) async {
  final from = publicKey;
  if (from.isEmpty) {
    throw Exception("from address not set");
  }
  if (tokenAddress.isEmpty) {
    throw Exception("token address not set");
  }
  if (symbol.isEmpty) {
    throw Exception("symbol not set");
  }
  if (name.isEmpty) {
    throw Exception("name not set");
  }
  if (description.isEmpty) {
    throw Exception("description not set");
  }
  if (image.isEmpty) {
    throw Exception("image not set");
  }
  if (website.isEmpty) {
    throw Exception("website not set");
  }
  if (creator.isEmpty) {
    throw Exception("creator not set");
  }
  if (creatorWebsite.isEmpty) {
    throw Exception("creator website not set");
  }

  KeyManager.validateEdDSAPublicKey(from);
  if (tokenAddress.isNotEmpty) {
    KeyManager.validateEdDSAPublicKey(tokenAddress);
  }
  if (from.isNotEmpty) {
    KeyManager.validateEdDSAPublicKey(from);
  }


 /* if (!KeyManager.validateEdDSAPublicKey(from)) {
    throw Exception("invalid from address");
  }
  if (!KeyManager.validateEdDSAPublicKey(tokenAddress)) {
    throw Exception("invalid token address");
  }
*/

  const contractVersion = TOKEN_CONTRACT_V1;
  const method = METHOD_UPDATE_METADATA;

  final data = {
    "address": tokenAddress,
    "creator": creator,
    "creator_website": creatorWebsite,
    "decimals": decimals,
    "description": description,
    "expired_at": expiredAt.toIso8601String(),
    "image": image,
    "name": name,
    "symbol": symbol,
    "tags": tags,
    "tags_category": tagsCategory,
    "tags_social_media": tagsSocialMedia,
    "website": website,
  };

  try {
    var nonce = await getNonce(from);
    nonce += 1;

    final newTx = Transaction(
      from: from,
      to: tokenAddress,
      contractVersion: contractVersion,
      method: method,
      data: data,
      nonce: nonce,
    );

    final tx = newTx.get();
    final txSigned = signTransaction( activePrivateKey ?? "", tx);

    final contractOutputBytes = await sendTransaction(
      REQUEST_METHOD_SEND_TRANSACTION,
      txSigned,
      _replyTo,
    ) as String;

    return ContractOutput.fromJson(jsonDecode(contractOutputBytes));
  } catch (e) {
    throw Exception("failed to send transaction: $e");
  }
}

Future<ContractOutput> pauseToken({
  required String tokenAddress,
  required bool paused,
}) async {
  final String from = _activePublicKey!;
  if (from.isEmpty) throw ArgumentError('from address not set');
  if (tokenAddress.isEmpty) throw ArgumentError('token address not set');
  if (paused != true) throw ArgumentError('paused must be true to pause token');

  // Validate keys
  KeyManager.validateEdDSAPublicKey(from);
  KeyManager.validateEdDSAPublicKey(tokenAddress);

  const String contractVersion = TOKEN_CONTRACT_V1;
  const String method = METHOD_PAUSE_TOKEN;

  // Ordem alfabética das chaves
  final Map<String, dynamic> data = {
    "address": tokenAddress,
    "paused": paused,
  };

  try {
    final contractOutput = await signAndSendTransaction(
      from: from,
      to: tokenAddress,
      contractVersion: contractVersion,
      method: method,
      data: data,
    );
    return contractOutput;
  } catch (e) {
    throw Exception('failed to send transaction: $e');
  }
}

Future<ContractOutput> unpauseToken({
  required String tokenAddress,
  required bool paused,
}) async {
  final String from = _activePublicKey!;
  if (from.isEmpty) throw ArgumentError('from address not set');
  if (tokenAddress.isEmpty) throw ArgumentError('token address not set');
  if (paused != false) throw ArgumentError('paused must be false to unpause token');

  // Validate keys
  KeyManager.validateEdDSAPublicKey(from);
  KeyManager.validateEdDSAPublicKey(tokenAddress);

  const String contractVersion = TOKEN_CONTRACT_V1;
  const String method = METHOD_UNPAUSE_TOKEN;

  // Ordem alfabética das chaves
  final Map<String, dynamic> data = {
    "address": tokenAddress,
    "paused": paused,
  };

  try {
    final contractOutput = await signAndSendTransaction(
      from: from,
      to: tokenAddress,
      contractVersion: contractVersion,
      method: method,
      data: data,
    );
    return contractOutput;
  } catch (e) {
    throw Exception('failed to send transaction: $e');
  }
}

Future<ContractOutput> updateFeeTiers({
  required String tokenAddress,
  required List<Map<String, dynamic>> feeTiersList,
}) async {
  final String from = _activePublicKey!;
  if (from.isEmpty) throw ArgumentError('from address not set');
  if (tokenAddress.isEmpty) throw ArgumentError('token address not set');
  if (feeTiersList.isEmpty) throw ArgumentError('fee tiers list is empty');

  // Validate keys
  KeyManager.validateEdDSAPublicKey(from);
  KeyManager.validateEdDSAPublicKey(tokenAddress);

  const String contractVersion = TOKEN_CONTRACT_V1;
  const String method = METHOD_UPDATE_FEE_TIERS;

  // Ordem alfabética das chaves
  final Map<String, dynamic> data = {
    "fee_tiers_list": feeTiersList,
    "token_address": tokenAddress,
  };

  try {
    final contractOutput = await signAndSendTransaction(
      from: from,
      to: tokenAddress,
      contractVersion: contractVersion,
      method: method,
      data: data,
    );
    return contractOutput;
  } catch (e) {
    throw Exception('failed to send transaction: $e');
  }
}

Future<ContractOutput> updateFeeAddress({
  required String tokenAddress,
  required String feeAddress,
}) async {
  final String from = _activePublicKey!;
  if (from.isEmpty) throw ArgumentError('from address not set');
  if (tokenAddress.isEmpty) throw ArgumentError('token address not set');
  if (feeAddress.isEmpty) throw ArgumentError('fee address not set');

  // Validate keys
  KeyManager.validateEdDSAPublicKey(from);
  KeyManager.validateEdDSAPublicKey(tokenAddress);

  const String contractVersion = TOKEN_CONTRACT_V1;
  const String method = METHOD_UPDATE_FEE_ADDRESS;

  // Ordem alfabética das chaves
  final Map<String, dynamic> data = {
    "address": tokenAddress,
    "fee_address": feeAddress,
  };

  try {
    final contractOutput = await signAndSendTransaction(
      from: from,
      to: tokenAddress,
      contractVersion: contractVersion,
      method: method,
      data: data,
    );
    return contractOutput;
  } catch (e) {
    throw Exception('failed to send transaction: $e');
  }
}

Future<ContractOutput> getToken({
  required String tokenAddress,
  String symbol = '',
  String name = '',
}) async {
  final String from = _activePublicKey!;
  if (from.isEmpty) throw ArgumentError('from address not set');

  if (tokenAddress.isEmpty && symbol.isEmpty && name.isEmpty) {
    throw ArgumentError('token address, symbol or name must be set');
  }

  // Validate keys
  KeyManager.validateEdDSAPublicKey(from);
  if (tokenAddress.isNotEmpty) {
    KeyManager.validateEdDSAPublicKey(tokenAddress);
  }

  const String contractVersion = TOKEN_CONTRACT_V1;
  const String method = METHOD_GET_TOKEN;

  // Ordem alfabética das chaves
  final Map<String, dynamic> data = {
    "address": tokenAddress,
    "name": name,
    "symbol": symbol,
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

Future<ContractOutput> listTokens({
  String ownerAddress = '',
  String symbol = '',
  String name = '',
  int page = 1,
  int limit = 10,
  bool ascending = true,
}) async {
  final String from = _activePublicKey!;
  if (from.isEmpty) throw ArgumentError('from address not set');

  // Valida ownerAddress apenas se não estiver vazio
  if (ownerAddress.isNotEmpty) {
    KeyManager.validateEdDSAPublicKey(ownerAddress);
  }

  KeyManager.validateEdDSAPublicKey(from);

  const String contractVersion = TOKEN_CONTRACT_V1;
  const String method = METHOD_LIST_TOKENS;

  // Ordem alfabética das chaves
  final Map<String, dynamic> data = {
    "ascending": ascending,
    "limit": limit,
    "name": name,
    "owner": ownerAddress,
    "page": page,
    "symbol": symbol,
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

Future<ContractOutput> getTokenBalance({
  required String tokenAddress,
  required String ownerAddress,
}) async {
  final String from = _activePublicKey!;
  if (from.isEmpty) throw ArgumentError('from address not set');
  if (tokenAddress.isEmpty) throw ArgumentError('token address not set');
  if (ownerAddress.isEmpty) throw ArgumentError('owner address not set');

  // Validate keys
  KeyManager.validateEdDSAPublicKey(from);
  KeyManager.validateEdDSAPublicKey(tokenAddress);
  KeyManager.validateEdDSAPublicKey(ownerAddress);

  const String contractVersion = TOKEN_CONTRACT_V1;
  const String method = METHOD_GET_TOKEN_BALANCE;

  // Ordem alfabética das chaves
  final Map<String, dynamic> data = {
    "owner_address": ownerAddress,
    "token_address": tokenAddress,
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

Future<ContractOutput> listTokenBalances({
  String tokenAddress = '',
  String ownerAddress = '',
  int page = 1,
  int limit = 10,
  bool ascending = true,
}) async {
  final String from = _activePublicKey!;
  if (from.isEmpty) throw ArgumentError('from address not set');

  // Validar apenas se não estiver vazio
  KeyManager.validateEdDSAPublicKey(from);
  if (tokenAddress.isNotEmpty) {
    KeyManager.validateEdDSAPublicKey(tokenAddress);
  }
  if (ownerAddress.isNotEmpty) {
    KeyManager.validateEdDSAPublicKey(ownerAddress);
  }

  const String contractVersion = TOKEN_CONTRACT_V1;
  const String method = METHOD_LIST_TOKEN_BALANCES;

  // Ordem alfabética das chaves
  final Map<String, dynamic> data = {
    "ascending": ascending,
    "limit": limit,
    "owner_address": ownerAddress,
    "page": page,
    "token_address": tokenAddress,
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