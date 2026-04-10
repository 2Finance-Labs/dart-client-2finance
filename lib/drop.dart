part of 'two_finance_blockchain.dart';

extension DropClient on TwoFinanceBlockchain {
  static const int _txVersion = 1;

  String _requireDropFromAddress() {
    final from = publicKeyHex ?? '';
    if (from.isEmpty) {
      throw ArgumentError('from address not set');
    }
    KeyManager.validateEDDSAPublicKeyHex(from);
    return from;
  }

  String _newDropUuid7() => newUUID7();

  bool _isZeroLikeDropDateTime(DateTime value) {
    final isUnixEpoch = value.millisecondsSinceEpoch == 0;
    final isGoZeroLike =
        value.year <= 1 &&
        value.month == 1 &&
        value.day == 1 &&
        value.hour == 0 &&
        value.minute == 0 &&
        value.second == 0 &&
        value.millisecond == 0 &&
        value.microsecond == 0;

    return isUnixEpoch || isGoZeroLike;
  }

  void _validateDropAddress(String value, String label) {
    try {
      KeyManager.validateEDDSAPublicKeyHex(value);
    } catch (e) {
      throw ArgumentError('invalid $label: $e');
    }
  }

  Future<ContractOutput> newDrop({
    required String address,
    required String programAddress,
    required String tokenAddress,
    required String owner,
    required String title,
    required String description,
    required String shortDescription,
    String imageUrl = '',
    String bannerUrl = '',
    required Map<String, bool> categories,
    Map<String, bool> socialRequirements = const <String, bool>{},
    Map<String, bool> postLinks = const <String, bool>{},
    required String verificationType,
    required DateTime startAt,
    required DateTime expireAt,
    required int requestLimit,
    required String claimAmount,
    required int claimIntervalSeconds,
  }) async {
    final from = _requireDropFromAddress();

    if (address.isEmpty) throw ArgumentError('drop address not set');
    if (programAddress.isEmpty) {
      throw ArgumentError('program address not set');
    }
    if (tokenAddress.isEmpty) throw ArgumentError('token address not set');
    if (owner.isEmpty) throw ArgumentError('owner not set');
    if (title.isEmpty) throw ArgumentError('title not set');
    if (description.isEmpty) throw ArgumentError('description not set');
    if (shortDescription.isEmpty) {
      throw ArgumentError('short description not set');
    }
    if (categories.isEmpty) throw ArgumentError('categories cannot be empty');
    if (verificationType.isEmpty) {
      throw ArgumentError('verification type not set');
    }
    if (_isZeroLikeDropDateTime(startAt)) {
      throw ArgumentError('start_at not set');
    }
    if (_isZeroLikeDropDateTime(expireAt)) {
      throw ArgumentError('expire_at not set');
    }
    if (requestLimit <= 0) {
      throw ArgumentError('request_limit must be greater than 0');
    }
    if (claimAmount.isEmpty) throw ArgumentError('claim_amount not set');
    if (claimIntervalSeconds < 0) {
      throw ArgumentError('claim_interval_seconds must be >= 0');
    }

    _validateDropAddress(address, 'drop address');
    _validateDropAddress(programAddress, 'program address');
    _validateDropAddress(tokenAddress, 'token address');
    _validateDropAddress(owner, 'owner address');

    return signAndSendTransaction(
      chainID: _chainID,
      from: from,
      to: address,
      method: METHOD_NEW_DROP,
      data: {
        'address': address,
        'program_address': programAddress,
        'token_address': tokenAddress,
        'owner': owner,
        'title': title,
        'description': description,
        'short_description': shortDescription,
        'image_url': imageUrl,
        'banner_url': bannerUrl,
        'categories': categories,
        'social_requirements': socialRequirements,
        'post_links': postLinks,
        'verification_type': verificationType,
        'start_at': startAt.toUtc().toIso8601String(),
        'expire_at': expireAt.toUtc().toIso8601String(),
        'request_limit': requestLimit,
        'claim_amount': claimAmount,
        'claim_interval_seconds': claimIntervalSeconds,
      },
      version: _txVersion,
      uuid7: _newDropUuid7(),
    );
  }

  Future<ContractOutput> updateDropMetadata({
    required String address,
    String programAddress = '',
    String tokenAddress = '',
    String title = '',
    String description = '',
    String shortDescription = '',
    String imageUrl = '',
    String bannerUrl = '',
    Map<String, bool> categories = const <String, bool>{},
    Map<String, bool> socialRequirements = const <String, bool>{},
    Map<String, bool> postLinks = const <String, bool>{},
    String verificationType = '',
    DateTime? startAt,
    DateTime? expireAt,
    int? requestLimit,
    String claimAmount = '',
    int? claimIntervalSeconds,
  }) async {
    if (address.isEmpty) throw ArgumentError('drop address not set');
    _validateDropAddress(address, 'drop address');

    final from = _requireDropFromAddress();

    if (programAddress.isNotEmpty) {
      _validateDropAddress(programAddress, 'program address');
    }
    if (tokenAddress.isNotEmpty) {
      _validateDropAddress(tokenAddress, 'token address');
    }
    if (requestLimit != null && requestLimit <= 0) {
      throw ArgumentError('request_limit must be greater than 0');
    }
    if (claimIntervalSeconds != null && claimIntervalSeconds < 0) {
      throw ArgumentError('claim_interval_seconds must be >= 0');
    }
    if (startAt != null && _isZeroLikeDropDateTime(startAt)) {
      throw ArgumentError('start_at not set');
    }
    if (expireAt != null && _isZeroLikeDropDateTime(expireAt)) {
      throw ArgumentError('expire_at not set');
    }

    final data = <String, dynamic>{'address': address};

    if (programAddress.isNotEmpty) data['program_address'] = programAddress;
    if (tokenAddress.isNotEmpty) data['token_address'] = tokenAddress;
    if (title.isNotEmpty) data['title'] = title;
    if (description.isNotEmpty) data['description'] = description;
    if (shortDescription.isNotEmpty) {
      data['short_description'] = shortDescription;
    }
    if (imageUrl.isNotEmpty) data['image_url'] = imageUrl;
    if (bannerUrl.isNotEmpty) data['banner_url'] = bannerUrl;
    if (categories.isNotEmpty) data['categories'] = categories;
    if (socialRequirements.isNotEmpty) {
      data['social_requirements'] = socialRequirements;
    }
    if (postLinks.isNotEmpty) data['post_links'] = postLinks;
    if (verificationType.isNotEmpty) {
      data['verification_type'] = verificationType;
    }
    if (startAt != null) data['start_at'] = startAt.toUtc().toIso8601String();
    if (expireAt != null) {
      data['expire_at'] = expireAt.toUtc().toIso8601String();
    }
    if (requestLimit != null) data['request_limit'] = requestLimit;
    if (claimAmount.isNotEmpty) data['claim_amount'] = claimAmount;
    if (claimIntervalSeconds != null) {
      data['claim_interval_seconds'] = claimIntervalSeconds;
    }

    if (data.length == 1) {
      throw ArgumentError('no fields to update');
    }

    return signAndSendTransaction(
      chainID: _chainID,
      from: from,
      to: address,
      method: METHOD_UPDATE_DROP_METADATA,
      data: data,
      version: _txVersion,
      uuid7: _newDropUuid7(),
    );
  }

  Future<ContractOutput> allowOracles({
    required String address,
    required Map<String, bool> oracles,
  }) async {
    final from = _requireDropFromAddress();

    if (address.isEmpty) throw ArgumentError('drop address not set');
    if (oracles.isEmpty) throw ArgumentError('oracles map is empty');

    _validateDropAddress(address, 'drop address');
    validateUserMap(oracles, 'oracles');

    return signAndSendTransaction(
      chainID: _chainID,
      from: from,
      to: address,
      method: METHOD_ALLOW_ORACLES,
      data: {'oracles': oracles},
      version: _txVersion,
      uuid7: _newDropUuid7(),
    );
  }

  Future<ContractOutput> disallowOracles({
    required String address,
    required Map<String, bool> oracles,
  }) async {
    final from = _requireDropFromAddress();

    if (address.isEmpty) throw ArgumentError('drop address not set');
    if (oracles.isEmpty) throw ArgumentError('oracles map is empty');

    _validateDropAddress(address, 'drop address');
    validateUserMap(oracles, 'oracles');

    return signAndSendTransaction(
      chainID: _chainID,
      from: from,
      to: address,
      method: METHOD_DISALLOW_ORACLES,
      data: {'oracles': oracles},
      version: _txVersion,
      uuid7: _newDropUuid7(),
    );
  }

  Future<ContractOutput> depositDrop({
    required String address,
    required String programAddress,
    required String tokenAddress,
    required String amount,
    List<String> uuids = const <String>[],
  }) async {
    final from = _requireDropFromAddress();

    if (address.isEmpty) throw ArgumentError('drop address not set');
    if (programAddress.isEmpty) {
      throw ArgumentError('program address not set');
    }
    if (tokenAddress.isEmpty) throw ArgumentError('token address not set');
    if (amount.isEmpty && uuids.isEmpty) {
      throw ArgumentError('amount or uuids must be set');
    }

    _validateDropAddress(address, 'drop address');
    _validateDropAddress(programAddress, 'program address');
    _validateDropAddress(tokenAddress, 'token address');

    final data = <String, dynamic>{
      'program_address': programAddress,
      'token_address': tokenAddress,
      'amount': amount,
      'uuid': uuids,
    };

    return signAndSendTransaction(
      chainID: _chainID,
      from: from,
      to: address,
      method: METHOD_DEPOSIT_DROP,
      data: data,
      version: _txVersion,
      uuid7: _newDropUuid7(),
    );
  }

  Future<ContractOutput> claimDrop({required String address}) async {
    final from = _requireDropFromAddress();

    if (address.isEmpty) throw ArgumentError('drop address not set');
    _validateDropAddress(address, 'drop address');

    return signAndSendTransaction(
      chainID: _chainID,
      from: from,
      to: address,
      method: METHOD_CLAIM_DROP,
      data: const <String, dynamic>{},
      version: _txVersion,
      uuid7: _newDropUuid7(),
    );
  }

  Future<ContractOutput> withdrawDrop({
    required String address,
    required String programAddress,
    required String tokenAddress,
    required String amount,
    List<String> uuids = const <String>[],
  }) async {
    final from = _requireDropFromAddress();

    if (address.isEmpty) throw ArgumentError('drop address not set');
    if (programAddress.isEmpty) {
      throw ArgumentError('program address not set');
    }
    if (tokenAddress.isEmpty) throw ArgumentError('token address not set');
    if (amount.isEmpty && uuids.isEmpty) {
      throw ArgumentError('amount or uuids must be set');
    }

    _validateDropAddress(address, 'drop address');
    _validateDropAddress(programAddress, 'program address');
    _validateDropAddress(tokenAddress, 'token address');

    final data = <String, dynamic>{
      'program_address': programAddress,
      'token_address': tokenAddress,
      'amount': amount,
      'uuid': uuids,
    };


    return signAndSendTransaction(
      chainID: _chainID,
      from: from,
      to: address,
      method: METHOD_WITHDRAW_DROP,
      data: data,
      version: _txVersion,
      uuid7: _newDropUuid7(),
    );
  }

  Future<ContractOutput> pauseDrop(String address) async {
    if (address.isEmpty) throw ArgumentError('drop address not set');
    _validateDropAddress(address, 'drop address');

    final from = _requireDropFromAddress();

    return signAndSendTransaction(
      chainID: _chainID,
      from: from,
      to: address,
      method: METHOD_PAUSE_DROP,
      data: {'address': address, 'paused': true},
      version: _txVersion,
      uuid7: _newDropUuid7(),
    );
  }

  Future<ContractOutput> unpauseDrop(String address) async {
    if (address.isEmpty) throw ArgumentError('drop address not set');
    _validateDropAddress(address, 'drop address');

    final from = _requireDropFromAddress();

    return signAndSendTransaction(
      chainID: _chainID,
      from: from,
      to: address,
      method: METHOD_UNPAUSE_DROP,
      data: {'address': address, 'paused': false},
      version: _txVersion,
      uuid7: _newDropUuid7(),
    );
  }

  Future<ContractOutput> attestParticipantEligibility({
    required String address,
    required String wallet,
    required bool approved,
  }) async {
    final from = _requireDropFromAddress();

    if (address.isEmpty) throw ArgumentError('drop address not set');
    if (wallet.isEmpty) throw ArgumentError('wallet not set');

    _validateDropAddress(address, 'drop address');
    _validateDropAddress(wallet, 'wallet address');

    return signAndSendTransaction(
      chainID: _chainID,
      from: from,
      to: address,
      method: METHOD_ATTEST_ELIGIBILITY,
      data: {'wallet': wallet, 'approved': approved},
      version: _txVersion,
      uuid7: _newDropUuid7(),
    );
  }

  Future<ContractOutput> manuallyAttestParticipantEligibility({
    required String address,
    required String wallet,
    required bool approved,
  }) async {
    final from = _requireDropFromAddress();

    if (address.isEmpty) throw ArgumentError('drop address not set');
    if (wallet.isEmpty) throw ArgumentError('wallet not set');

    _validateDropAddress(address, 'drop address');
    _validateDropAddress(wallet, 'wallet address');

    return signAndSendTransaction(
      chainID: _chainID,
      from: from,
      to: address,
      method: METHOD_MANUAL_ATTEST_ELIGIBILITY,
      data: {'wallet': wallet, 'approved': approved},
      version: _txVersion,
      uuid7: _newDropUuid7(),
    );
  }

  Future<ContractOutput> getDrop({required String address}) async {
    final from = _requireDropFromAddress();

    if (address.isEmpty) throw ArgumentError('drop address must be set');

    _validateDropAddress(from, 'from address');
    _validateDropAddress(address, 'drop address');

    return getState(
      to: address,
      method: METHOD_GET_DROP,
      data: const <String, dynamic>{},
    );
  }

  Future<ContractOutput> listDrops({
    String owner = '',
    int page = 1,
    int limit = 10,
    bool ascending = false,
  }) async {
    final from = _requireDropFromAddress();
    _validateDropAddress(from, 'from address');

    if (owner.isNotEmpty) {
      _validateDropAddress(owner, 'owner address');
    }
    if (page < 1) throw ArgumentError('page must be greater than 0');
    if (limit < 1) throw ArgumentError('limit must be greater than 0');

    return getState(
      to: '',
      method: METHOD_LIST_DROPS,
      data: {
        'owner': owner,
        'page': page,
        'limit': limit,
        'ascending': ascending,
        'contract_version': DROP_CONTRACT_V1,
      },
    );
  }
}
