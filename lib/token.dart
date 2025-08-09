
import 'package:two_finance_blockchain/blockchain/utils/decimals.dart';

part of two_finance_blockchain;

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
}