part of 'two_finance_blockchain.dart';

extension Raffle on TwoFinanceBlockchain {

  Future<ContractOutput> addRaffle({
    required String address,
    required String owner,
    required String tokenAddress,
    required String ticketPrice,
    required int maxEntries,
    required int maxEntriesPerUser,
    required DateTime startAt,
    required DateTime expiredAt,
    required bool paused,
    required String seedCommitHex,
    required Map<String, String> metadata,
  }) async {
    final data = {
      "address": address,
      "expired_at": expiredAt.toIso8601String(),
      "max_entries": maxEntries,
      "max_entries_per_user": maxEntriesPerUser,
      "metadata": metadata,
      "owner": owner,
      "paused": paused,
      "seed_commit_hex": seedCommitHex,
      "start_at": startAt.toIso8601String(),
      "ticket_price": ticketPrice,
      "token_address": tokenAddress,
    };

    return sendTransaction(
      publicKey,
      "DEPLOY_CONTRACT_ADDRESS",
      "RAFFLE_CONTRACT_V1",
      "METHOD_ADD_RAFFLE",
      data,
    );
  }

  Future<ContractOutput> updateRaffle({
    required String address,
    String? tokenAddress,
    String? ticketPrice,
    int? maxEntries,
    int? maxEntriesPerUser,
    DateTime? startAt,
    DateTime? expiredAt,
    String? seedCommitHex,
    Map<String, String>? metadata,
  }) async {
    final data = {
      "address": address,
      if (expiredAt != null) "expired_at": expiredAt.toIso8601String(),
      if (maxEntries != null) "max_entries": maxEntries,
      if (maxEntriesPerUser != null) "max_entries_per_user": maxEntriesPerUser,
      if (metadata != null) "metadata": metadata,
      if (seedCommitHex != null) "seed_commit_hex": seedCommitHex,
      if (startAt != null) "start_at": startAt.toIso8601String(),
      if (ticketPrice != null) "ticket_price": ticketPrice,
      if (tokenAddress != null) "token_address": tokenAddress,
    };

    return sendTransaction(
      publicKey,
      address,
      "RAFFLE_CONTRACT_V1",
      "METHOD_UPDATE_RAFFLE",
      data,
    );
  }

  Future<ContractOutput> pauseRaffle(String address) async {
    final data = {
      "address": address,
      "paused": true,
    };

    return sendTransaction(
      publicKey,
      address,
      "RAFFLE_CONTRACT_V1",
      "METHOD_PAUSE_RAFFLE",
      data,
    );
  }

  Future<ContractOutput> unpauseRaffle(String address) async {
    final data = {
      "address": address,
      "paused": false,
    };

    return sendTransaction(
      publicKey,
      address,
      "RAFFLE_CONTRACT_V1",
      "METHOD_UNPAUSE_RAFFLE",
      data,
    );
  }

  Future<ContractOutput> enterRaffle({
    required String address,
    required int tickets,
    required String payTokenAddress,
  }) async {
    final data = {
      "address": address,
      "entrant": publicKey,
      "pay_token_address": payTokenAddress,
      "tickets": tickets,
    };

    return sendTransaction(
      publicKey,
      address,
      "RAFFLE_CONTRACT_V1",
      "METHOD_ENTER_RAFFLE",
      data,
    );
  }

  Future<ContractOutput> drawRaffle({
    required String address,
    required String revealSeed,
  }) async {
    final data = {
      "address": address,
      "reveal_seed": revealSeed,
    };

    return sendTransaction(
      publicKey,
      address,
      "RAFFLE_CONTRACT_V1",
      "METHOD_DRAW_RAFFLE",
      data,
    );
  }

  Future<ContractOutput> claimRaffle({
    required String address,
    required String winner,
  }) async {
    final data = {
      "address": address,
      "winner": winner,
    };

    return sendTransaction(
      publicKey,
      address,
      "RAFFLE_CONTRACT_V1",
      "METHOD_CLAIM_RAFFLE",
      data,
    );
  }

  Future<ContractOutput> withdrawRaffle({
    required String address,
    required String tokenAddress,
    required String amount,
  }) async {
    final data = {
      "address": address,
      "amount": amount,
      "token_address": tokenAddress,
    };

    return sendTransaction(
      publicKey,
      address,
      "RAFFLE_CONTRACT_V1",
      "METHOD_WITHDRAW_RAFFLE",
      data,
    );
  }

  Future<ContractOutput> addRafflePrize({
    required String raffleAddress,
    required String tokenAddress,
    required String amount,
  }) async {
    final data = {
      "amount": amount,
      "raffle_address": raffleAddress,
      "token_address": tokenAddress,
    };

    return sendTransaction(
      publicKey,
      raffleAddress,
      "RAFFLE_CONTRACT_V1",
      "METHOD_ADD_RAFFLE_PRIZE",
      data,
    );
  }

  Future<ContractOutput> removeRafflePrize({
    required String raffleAddress,
    required String uuid,
  }) async {
    final data = {
      "raffle_address": raffleAddress,
      "uuid": uuid,
    };

    return sendTransaction(
      publicKey,
      raffleAddress,
      "RAFFLE_CONTRACT_V1",
      "METHOD_REMOVE_RAFFLE_PRIZE",
      data,
    );
  }

  Future<ContractOutput> getRaffle(String address) async {
    final data = {
      "address": address,
    };

    return getState(
      "RAFFLE_CONTRACT_V1",
      "METHOD_GET_RAFFLE",
      data,
    );
  }

  Future<ContractOutput> listRaffles({
    String? owner,
    String? tokenAddress,
    bool? paused,
    bool? activeOnly,
    required int page,
    required int limit,
    required bool ascending,
  }) async {
    final data = {
      "ascending": ascending,
      "limit": limit,
      "owner": owner ?? "",
      "page": page,
      "token_address": tokenAddress ?? "",
      if (activeOnly != null) "active_only": activeOnly,
      if (paused != null) "paused": paused,
    };

    return getState(
      "RAFFLE_CONTRACT_V1",
      "METHOD_LIST_RAFFLES",
      data,
    );
  }
}
