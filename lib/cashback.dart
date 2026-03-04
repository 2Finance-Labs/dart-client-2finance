
part of 'two_finance_blockchain.dart';
extension Cashback on TwoFinanceBlockchain{

  // // ------------------------------------------------------------------
  // // AddCashBack (Go: AddCashback)
  // // ------------------------------------------------------------------
  // Future<ContractOutput> addCashback({
  //   required String address,
  //   required String owner,
  //   required String tokenAddress,
  //   required String programType, // fixed-percentage | variable-percentage
  //   required String percentage,
  //   required DateTime startAt,
  //   required DateTime expiredAt,
  //   required bool paused,
  // }) async {
  //   final from = _publicKeyHex!;
  //   if (from.isEmpty) throw Exception("from address not set");
  //   KeyManager.validateEDDSAPublicKeyHex(from);

  //   if (address.isEmpty) throw Exception("address not set");
  //   KeyManager.validateEDDSAPublicKeyHex(address);

  //   if (owner.isEmpty) throw Exception("owner not set");
  //   KeyManager.validateEDDSAPublicKeyHex(owner);

  //   if (tokenAddress.isEmpty) throw Exception("token address not set");
  //   KeyManager.validateEDDSAPublicKeyHex(tokenAddress);

  //   if (programType != "fixed-percentage" && programType != "variable-percentage") {
  //     throw Exception("invalid program_type: $programType");
  //   }
  //   if (percentage.isEmpty) throw Exception("percentage not set");
  //   final chainID = _chainID!;
  //   final to = address;
  //   final method = METHOD_ADD_CASHBACK;

  //   final JsonRawMessage data = mapToJsonRawMessage({
  //     "address": address,
  //     "owner": owner,
  //     "token_address": tokenAddress,
  //     "program_type": programType,
  //     "percentage": percentage,
  //     "start_at": startAt.toIso8601String(),
  //     "expired_at": expiredAt.toIso8601String(),
  //     "paused": paused,
  //   });

  //   final version = 1;
  //   final uuid7 = newUUID7();

  //   try {
  //     return await signAndSendTransaction(
  //       chainID: chainID,
  //       from: from,
  //       to: to,
  //       method: method,
  //       data: data,
  //       version: version,
  //       uuid7: uuid7,
  //     );
  //   } catch (e) {
  //     throw Exception("failed to add cashback: $e");
  //   }
  // }

  // // ------------------------------------------------------------------
  // // UpdateCashback (Go: UpdateCashback)
  // // ------------------------------------------------------------------
  // Future<ContractOutput> updateCashback({
  //   required String address,
  //   required String tokenAddress,
  //   required String programType,
  //   required String percentage,
  //   required DateTime startAt,
  //   required DateTime expiredAt,
  // }) async {
  //   if (address.isEmpty) throw Exception("address not set");
  //   KeyManager.validateEDDSAPublicKeyHex(address);

  //   if (tokenAddress.isNotEmpty) {
  //     KeyManager.validateEDDSAPublicKeyHex(tokenAddress);
  //   }

  //   if (programType != "fixed-percentage" && programType != "variable-percentage") {
  //     throw Exception("invalid program_type: $programType");
  //   }
  //   if (percentage.isEmpty) throw Exception("percentage not set");
  //   final chainID = _chainID!;
  //   final from = _publicKeyHex!;
  //   if (from.isEmpty) throw Exception("from address not set");
  //   KeyManager.validateEDDSAPublicKeyHex(from);

  //   final to = address;
  //   final method = METHOD_UPDATE_CASHBACK;

  //   final JsonRawMessage data = mapToJsonRawMessage({
  //     "address": address,
  //     "token_address": tokenAddress,
  //     "program_type": programType,
  //     "percentage": percentage,
  //     "start_at": startAt.toIso8601String(),
  //     "expired_at": expiredAt.toIso8601String(),
  //   });

  //   final version = 1;
  //   final uuid7 = newUUID7();

  //   return signAndSendTransaction(
  //     chainID: chainID,
  //     from: from,
  //     to: to,
  //     method: method,
  //     data: data,
  //     version: version,
  //     uuid7: uuid7,
  //   );
  // }

  // // ------------------------------------------------------------------
  // // PauseCashBack (Go: PauseCashback)
  // // ------------------------------------------------------------------
  // Future<ContractOutput> pauseCashback({
  //   required String address,
  //   required bool pause,
  // }) async {
  //   if (address.isEmpty) throw Exception("address not set");
  //   KeyManager.validateEDDSAPublicKeyHex(address);

  //   if (!pause) {
  //     throw Exception("pause must be true: Pause: $pause");
  //   }

  //   final chainID = _chainID!;
  //   final from = _publicKeyHex!;
  //   if (from.isEmpty) throw Exception("from address not set");
  //   KeyManager.validateEDDSAPublicKeyHex(from);

  //   final to = address;
  //   final method = METHOD_PAUSE_CASHBACK;

  //   final JsonRawMessage data = mapToJsonRawMessage({
  //     "address": address,
  //     "paused": pause,
  //   });

  //   final version = 1;
  //   final uuid7 = newUUID7();

  //   return signAndSendTransaction(
  //     chainID: chainID,
  //     from: from,
  //     to: to,
  //     method: method,
  //     data: data,
  //     version: version,
  //     uuid7: uuid7,
  //   );
  // }

  // // ------------------------------------------------------------------
  // // UnpauseCashback (Go: UnpauseCashback)
  // // ------------------------------------------------------------------
  // Future<ContractOutput> unpauseCashback({
  //   required String address,
  //   required bool pause,
  // }) async {
  //   if (address.isEmpty) throw Exception("address not set");
  //   KeyManager.validateEDDSAPublicKeyHex(address);

  //   if (pause) {
  //     throw Exception("pause must be false: Pause: $pause");
  //   }
  //   final chainID = _chainID!;
  //   final from = _publicKeyHex!;
  //   if (from.isEmpty) throw Exception("from address not set");
  //   KeyManager.validateEDDSAPublicKeyHex(from);

  //   final to = address;
  //   final method = METHOD_UNPAUSE_CASHBACK;

  //   final JsonRawMessage data = mapToJsonRawMessage({
  //     "address": address,
  //     "paused": pause,
  //   });

  //   final version = 1;
  //   final uuid7 = newUUID7();

  //   return signAndSendTransaction(
  //     chainID: chainID,
  //     from: from,
  //     to: to,
  //     method: method,
  //     data: data,
  //     version: version,
  //     uuid7: uuid7,
  //   );
  // }

  // // ------------------------------------------------------------------
  // // DepositCashBack (Go: DepositCashbackFunds)
  // // ------------------------------------------------------------------
  // Future<ContractOutput> depositCashbackFunds({
  //   required String address,
  //   required String tokenAddress,
  //   required String amount,
  //   required String tokenType,
  //   required String uuid, // required if non-fungible
  // }) async {
  //   if (address.isEmpty) throw Exception("address not set");
  //   KeyManager.validateEDDSAPublicKeyHex(address);

  //   if (amount.isEmpty) throw Exception("amount not set");
  //   if (tokenType.isEmpty) throw Exception("token type not set");

  //   if (tokenType == Domain.NON_FUNGIBLE && uuid.isEmpty) {
  //     throw Exception("uuid must be set for non-fungible tokens");
  //   }

  //   if (tokenAddress.isEmpty) throw Exception("token address not set");
  //   KeyManager.validateEDDSAPublicKeyHex(tokenAddress);
  //   final chainID = _chainID!;
  //   final from = _publicKeyHex!;
  //   if (from.isEmpty) throw Exception("from address not set");
  //   KeyManager.validateEDDSAPublicKeyHex(from);
  
  //   final to = address;
  //   final method = METHOD_DEPOSIT_CASHBACK;

  //   final JsonRawMessage data = mapToJsonRawMessage({
  //     "address": address,
  //     "token_address": tokenAddress,
  //     "amount": amount,
  //     "token_type": tokenType,
  //     "uuid": uuid,
  //   });

  //   final version = 1;
  //   final uuid7 = newUUID7();

  //   try {
  //     return await signAndSendTransaction(
  //       chainID: chainID,
  //       from: from,
  //       to: to,
  //       method: method,
  //       data: data,
  //       version: version,
  //       uuid7: uuid7,
  //     );
  //   } catch (e) {
  //     throw Exception("failed to deposit cashback: $e");
  //   }
  // }

  // // ------------------------------------------------------------------
  // // WithdrawCashBack (Go: WithdrawCashbackFunds)
  // // ------------------------------------------------------------------
  // Future<ContractOutput> withdrawCashbackFunds({
  //   required String address,
  //   required String tokenAddress,
  //   required String amount,
  //   required String tokenType,
  //   required String uuid, // required if non-fungible
  // }) async {
  //   if (address.isEmpty) throw Exception("address not set");
  //   KeyManager.validateEDDSAPublicKeyHex(address);

  //   if (amount.isEmpty) throw Exception("amount not set");
  //   if (tokenType.isEmpty) throw Exception("token type not set");

  //   if (tokenType == Domain.NON_FUNGIBLE && uuid.isEmpty) {
  //     throw Exception("uuid must be set for non-fungible tokens");
  //   }

  //   if (tokenAddress.isEmpty) throw Exception("token address not set");
  //   KeyManager.validateEDDSAPublicKeyHex(tokenAddress);
  //   final chainID = _chainID!;
  //   final from = _publicKeyHex!;
  //   if (from.isEmpty) throw Exception("from address not set");
  //   KeyManager.validateEDDSAPublicKeyHex(from);

  //   final to = address;
  //   final method = METHOD_WITHDRAW_CASHBACK;

  //   final JsonRawMessage data = mapToJsonRawMessage({
  //     "address": address,
  //     "token_address": tokenAddress,
  //     "amount": amount,
  //     "token_type": tokenType,
  //     "uuid": uuid,
  //   });

  //   final version = 1;
  //   final uuid7 = newUUID7();

  //   return signAndSendTransaction(
  //     chainID: chainID,
  //     from: from,
  //     to: to,
  //     method: method,
  //     data: data,
  //     version: version,
  //     uuid7: uuid7,
  //   );
  // }

  // // ------------------------------------------------------------------
  // // GetCashBack (Go: GetCashback)
  // // ------------------------------------------------------------------
  // Future<ContractOutput> getCashback({
  //   required String address,
  // }) async {
  //   final from = _publicKeyHex!;

  //   if (address.isEmpty) throw Exception("cashback address must be set");
  //   if (from.isEmpty) throw Exception("from address not set");

  //   KeyManager.validateEDDSAPublicKeyHex(from);
  //   KeyManager.validateEDDSAPublicKeyHex(address);

  //   final method = METHOD_GET_CASHBACK;

  //   // Go passes nil data, here we pass empty raw message
  //   return getState(
  //     address: address,
  //     method: method,
  //     data: emptyJsonRawMessage(),
  //   );
  // }

  // // ------------------------------------------------------------------
  // // ListCashBack (Go: ListCashbacks)
  // // ------------------------------------------------------------------
  // Future<ContractOutput> listCashbacks({
  //   required String owner,
  //   required String tokenAddress,
  //   required String programType,
  //   required bool paused,
  //   required int page,
  //   required int limit,
  //   required bool ascending,
  // }) async {
  //   final from = _publicKeyHex!;
  //   if (from.isEmpty) throw Exception("from address not set");
  //   KeyManager.validateEDDSAPublicKeyHex(from);

  //   if (owner.isNotEmpty) KeyManager.validateEDDSAPublicKeyHex(owner);
  //   if (tokenAddress.isNotEmpty) KeyManager.validateEDDSAPublicKeyHex(tokenAddress);

  //   if (programType.isNotEmpty &&
  //       programType != "fixed-percentage" &&
  //       programType != "variable-percentage") {
  //     throw Exception("invalid program_type: $programType");
  //   }

  //   if (page < 1) throw Exception("page must be greater than 0");
  //   if (limit < 1) throw Exception("limit must be greater than 0");

  //   final method = METHOD_LIST_CASHBACKS;

  //   final JsonRawMessage data = mapToJsonRawMessage({
  //     "owner": owner,
  //     "program_type": programType,
  //     "paused": paused,
  //     "page": page,
  //     "limit": limit,
  //     "ascending": ascending,
  //     "token_address": tokenAddress,
  //     "contract_version": CASHBACK_CONTRACT_V1,
  //   });

  //   // Go: GetState("", method, data)
  //   return getState(
  //     address: "",
  //     method: method,
  //     data: data,
  //   );
  // }

  // // ------------------------------------------------------------------
  // // ClaimCashback (Go: ClaimCashback)
  // // ------------------------------------------------------------------
  // Future<ContractOutput> claimCashback({
  //   required String address,
  //   required String amount,
  //   required String tokenType,
  //   required String uuid, // required if non-fungible
  // }) async {
  //   if (address.isEmpty) throw Exception("address not set");
  //   KeyManager.validateEDDSAPublicKeyHex(address);

  //   if (amount.isEmpty) throw Exception("amount not set");
  //   if (tokenType.isEmpty) throw Exception("token type not set");

  //   if (tokenType == Domain.NON_FUNGIBLE && uuid.isEmpty) {
  //     throw Exception("uuid must be set for non-fungible tokens");
  //   }

  //   final chainID = _chainID!;
  //   final from = _publicKeyHex!;
  //   if (from.isEmpty) throw Exception("from address not set");
  //   KeyManager.validateEDDSAPublicKeyHex(from);

  //   final to = address;
  //   final method = METHOD_CLAIM_CASHBACK;

  //   final JsonRawMessage data = mapToJsonRawMessage({
  //     "address": address,
  //     "amount": amount,
  //     "token_type": tokenType,
  //     "uuid": uuid,
  //   });

  //   final version = 1;
  //   final uuid7 = newUUID7();

  //   return signAndSendTransaction(
  //     chainID: chainID,
  //     from: from,
  //     to: to,
  //     method: method,
  //     data: data,
  //     version: version,
  //     uuid7: uuid7,
  //   );
  // }
}
