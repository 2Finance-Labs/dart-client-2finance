
part of two_finance_blockchain;
extension RaffleClient on TwoFinanceBlockchain{

  // Future<ContractOutput> addRaffle({
  //   String? raffleAddress,
  //   required String tokenAddress,
  //   required String title,
  //   required String description,
  //   required String imageUrl,
  //   required String payTokenAddress,
  //   required String startAmount,
  //   required int maxTickets,
  //   required int maxTicketsPerWallet,
  //   required DateTime endTime,
  //   bool paused = false,
  // }) async {
  //   final from = _publicKeyHex!;
  //   final to = tokenAddress;
  //   final contractVersion = RAFFLE_CONTRACT_V1;
  //   final method = METHOD_ADD_RAFFLE;
  //   if (_publicKeyHex!.isEmpty) throw Exception("public key not set");
  //   if (tokenAddress.isEmpty) throw Exception("token address not set");
  //   if (payTokenAddress.isEmpty) throw Exception("pay token address not set");
  //   if (startAmount.isEmpty) throw Exception("start amount not set");

  //    KeyManager.validateEDDSAPublicKeyHex(_publicKeyHex!);
  //    KeyManager.validateEDDSAPublicKeyHex(tokenAddress);
  //    KeyManager.validateEDDSAPublicKeyHex(payTokenAddress);

  //   final data = {
  //     "raffle_address": raffleAddress,
  //     "token_address": tokenAddress,
  //     "title": title,
  //     "description": description,
  //     "image_url": imageUrl,
  //     "pay_token_address": payTokenAddress,
  //     "start_amount": startAmount,
  //     "max_tickets": maxTickets,
  //     "max_tickets_per_wallet": maxTicketsPerWallet,
  //     "end_time": endTime.toIso8601String(),
  //     "paused": paused,
  //   };

  //   return signAndSendTransaction(chainID: chainID, from: from, to: to, method: method, data: data, version:version, uuid7:uuid7);
  // }

  // Future<ContractOutput> updateRaffle({
  //   required String raffleAddress,
  //   String? title,
  //   String? description,
  //   String? imageUrl,
  //   int? maxTickets,
  //   int? maxTicketsPerWallet,
  //   DateTime? endTime,
  // }) async {
  //   final from = _publicKeyHex!;
  //   final to = raffleAddress;
  //   final contractVersion = RAFFLE_CONTRACT_V1;
  //   final method = METHOD_UPDATE_RAFFLE;
  //   if (to.isEmpty) throw Exception("public key not set");
  //   if (raffleAddress.isEmpty) throw Exception("raffle address not set");

  //    KeyManager.validateEDDSAPublicKeyHex(_publicKeyHex!);
  //    KeyManager.validateEDDSAPublicKeyHex(raffleAddress);

  //   final data = {
  //     "raffle_address": raffleAddress,
  //     if (title != null) "title": title,
  //     if (description != null) "description": description,
  //     if (imageUrl != null) "image_url": imageUrl,
  //     if (maxTickets != null) "max_tickets": maxTickets,
  //     if (maxTicketsPerWallet != null) "max_tickets_per_wallet": maxTicketsPerWallet,
  //     if (endTime != null) "end_time": endTime.toIso8601String(),
  //   };

  //   return signAndSendTransaction(chainID: chainID, from: from, to: to, method: method, data: data, version:version, uuid7:uuid7);
  // }

  // Future<ContractOutput> pauseRaffle(String raffleAddress) async {
  //   final from = _publicKeyHex!;
  //   final to = raffleAddress;
  //   final contractVersion = RAFFLE_CONTRACT_V1;
  //   final method = METHOD_PAUSE_RAFFLE;
  //   if (raffleAddress.isEmpty) throw Exception("raffle address not set");
  //    KeyManager.validateEDDSAPublicKeyHex(raffleAddress);

  //   final data = {"raffle_address": raffleAddress, "paused": true};
  //   return signAndSendTransaction(chainID: chainID, from: from, to: to, method: method, data: data, version:version, uuid7:uuid7);
  // }

  // Future<ContractOutput> unpauseRaffle(String raffleAddress) async {
  //   final from = _publicKeyHex!;
  //   final to = raffleAddress;
  //   final contractVersion = RAFFLE_CONTRACT_V1;
  //   final method = METHOD_UNPAUSE_RAFFLE;
  //   if (raffleAddress.isEmpty) throw Exception("raffle address not set");
  //    KeyManager.validateEDDSAPublicKeyHex(raffleAddress);

  //   final data = {"raffle_address": raffleAddress, "paused": false};
  //   return signAndSendTransaction(chainID: chainID, from: from, to: to, method: method, data: data, version:version, uuid7:uuid7);
  // }

  // Future<ContractOutput> enterRaffle({
  //   required String raffleAddress,
  //   required String payTokenAddress,
  //   required int tickets,
  // }) async {
  //   final from = _publicKeyHex!;
  //   final to = raffleAddress;
  //   final contractVersion = RAFFLE_CONTRACT_V1;
  //   final method = METHOD_ENTER_RAFFLE;
  //   if (raffleAddress.isEmpty) throw Exception("raffle address not set");
  //   if (tickets <= 0) throw Exception("tickets must be greater than 0");
  //   if (payTokenAddress.isEmpty) throw Exception("pay token address not set");

  //    KeyManager.validateEDDSAPublicKeyHex(raffleAddress);
  //    KeyManager.validateEDDSAPublicKeyHex(payTokenAddress);

  //   final data = {
  //     "raffle_address": raffleAddress,
  //     "pay_token_address": payTokenAddress,
  //     "tickets": tickets,
  //   };

  //   return signAndSendTransaction(chainID: chainID, from: from, to: to, method: method, data: data, version:version, uuid7:uuid7);
  // }

  // Future<ContractOutput> claimRaffle(String raffleAddress) async {
  //   final from = _publicKeyHex!;
  //   final to = raffleAddress;
  //   final contractVersion = RAFFLE_CONTRACT_V1;
  //   final method = METHOD_CLAIM_RAFFLE;
  //   if (raffleAddress.isEmpty) throw Exception("raffle address not set");
  //    KeyManager.validateEDDSAPublicKeyHex(raffleAddress);

  //   final data = {"raffle_address": raffleAddress};
  //   return signAndSendTransaction(chainID: chainID, from: from, to: to, method: method, data: data, version:version, uuid7:uuid7);
  // }

  // Future<ContractOutput> withdrawRaffle(String raffleAddress) async {
  //   final from = _publicKeyHex!;
  //   final to = raffleAddress;
  //   final contractVersion = RAFFLE_CONTRACT_V1;
  //   final method = METHOD_WITHDRAW_RAFFLE;
  //   if (raffleAddress.isEmpty) throw Exception("raffle address not set");
  //    KeyManager.validateEDDSAPublicKeyHex(raffleAddress);

  //   final data = {"raffle_address": raffleAddress};
  //   return signAndSendTransaction(from: from, to: to, contractVersion: contractVersion, method: method, data:data);
  // }

  // Future<ContractOutput> addRafflePrize({
  //   required String raffleAddress,
  //   required String tokenAddress,
  //   required String amount,
  // }) async {
  //   final from = _publicKeyHex!;
  //   final to = raffleAddress;
  //   final contractVersion = RAFFLE_CONTRACT_V1;
  //   final method = METHOD_ADD_RAFFLE_PRIZE;
  //   if (raffleAddress.isEmpty) throw Exception("raffle address not set");
  //   if (tokenAddress.isEmpty) throw Exception("token address not set");
  //   if (amount.isEmpty) throw Exception("amount not set");

  //    KeyManager.validateEDDSAPublicKeyHex(raffleAddress);
  //    KeyManager.validateEDDSAPublicKeyHex(tokenAddress);

  //   final data = {
  //     "raffle_address": raffleAddress,
  //     "token_address": tokenAddress,
  //     "amount": amount,
  //   };

  //   return signAndSendTransaction(chainID: chainID, from: from, to: to, method: method, data: data, version:version, uuid7:uuid7);
  // }

  // Future<ContractOutput> removeRafflePrize({
  //   required String raffleAddress,
  //   required String tokenAddress,
  // }) async {
  //   final from = _publicKeyHex!;
  //   final to = raffleAddress;
  //   final contractVersion = RAFFLE_CONTRACT_V1;
  //   final method = METHOD_REMOVE_RAFFLE_PRIZE;
  //   if (raffleAddress.isEmpty) throw Exception("raffle address not set");
  //   if (tokenAddress.isEmpty) throw Exception("token address not set");

  //    KeyManager.validateEDDSAPublicKeyHex(raffleAddress);
  //    KeyManager.validateEDDSAPublicKeyHex(tokenAddress);

  //   final data = {
  //     "raffle_address": raffleAddress,
  //     "token_address": tokenAddress,
  //   };

  //   return signAndSendTransaction(chainID: chainID, from: from, to: to, method: method, data: data, version:version, uuid7:uuid7);
    
  // }

  // Future<ContractOutput> drawRaffle(String raffleAddress, String seed) async {
  //   final from = _publicKeyHex!;
  //   final to = raffleAddress;
  //   final method = METHOD_DRAW_RAFFLE;
  //   final contractVersion = RAFFLE_CONTRACT_V1;
  //   if (raffleAddress.isEmpty) throw Exception("raffle address not set");
  //   if (seed.isEmpty) throw Exception("seed not set");

  //    KeyManager.validateEDDSAPublicKeyHex(raffleAddress);

  //   final data = {"raffle_address": raffleAddress, "seed": seed};
  //   return signAndSendTransaction(chainID: chainID, from: from, to: to, method: method, data: data, version:version, uuid7:uuid7);
    
  // }

  // Future<ContractOutput> getRaffle(String raffleAddress) async {
  //   if (raffleAddress.isEmpty) throw Exception("raffle address not set");
  //    KeyManager.validateEDDSAPublicKeyHex(raffleAddress);

  //   final data = {"raffle_address": raffleAddress};
  //   return getState(contractVersion: RAFFLE_CONTRACT_V1, method: METHOD_GET_RAFFLE, data: data);
    
  // }

  // Future<ContractOutput> listRaffles({
  //   String? owner,
  //   String? tokenAddress,
  //   bool? paused,
  //   bool activeOnly = false,
  //   int page = 1,
  //   int limit = 10,
  //   bool ascending = false,
  // }) async {
  //    KeyManager.validateEDDSAPublicKeyHex(_publicKeyHex!);
  //   if (owner != null && owner.isNotEmpty)  KeyManager.validateEDDSAPublicKeyHex(owner);
  //   if (tokenAddress != null && tokenAddress.isNotEmpty)  KeyManager.validateEDDSAPublicKeyHex(tokenAddress);

  //   final data = {
  //     "owner": owner ?? "",
  //     "token_address": tokenAddress ?? "",
  //     "paused": paused,
  //     "active_only": activeOnly,
  //     "page": page,
  //     "limit": limit,
  //     "ascending": ascending,
  //   };

  //   return getState(contractVersion: RAFFLE_CONTRACT_V1, method: METHOD_LIST_RAFFLES, data: data);
    
  // }

  
}
