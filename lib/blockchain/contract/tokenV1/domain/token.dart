import 'package:two_finance_blockchain/blockchain/keys/keys.dart';
import 'package:two_finance_blockchain/blockchain/contract/tokenV1/domain/fee.dart';

void validateUserMap(Map<String, bool> users, String label) {
for (final entry in users.entries) {
    final addr = entry.key.trim();
    try {
    KeyManager.validateEdDSAPublicKey(addr);
    } catch (e) {
    throw ArgumentError("invalid $label address '$addr': $e");
    }
}
}


class Token {
  final String? symbol;
  final String? name;
  final int? decimals;
  final String? totalSupply;

  final String? description;
  final String? address;
  final String? hash;
  final String? owner;
  final List<FeeTier>? feeTiersList;
  final String? feeAddress;

  // Metadata fields
  final String? image;
  final String? website;

  final Map<String, String>? tagsSocialMedia;
  final Map<String, String>? tagsCategory;
  final Map<String, String>? tags;

  // Creator information
  final String? creator;
  final String? creatorWebsite;

  // Allow and block lists
  final Map<String, bool>? allowUsersMap;
  final Map<String, bool>? blockUsersMap;

  // Authority revocation flags
  final bool? freezeAuthorityRevoked;
  final bool? mintAuthorityRevoked;
  final bool? updateAuthorityRevoked;

  // Pause
  final bool? paused;
  final DateTime? expiredAt;

  Token({
    this.symbol,
    this.name,
    this.decimals,
    this.totalSupply,
    this.description,
    this.address,
    this.hash,
    this.owner,
    this.feeTiersList,
    this.feeAddress,
    this.image,
    this.website,
    this.tagsSocialMedia,
    this.tagsCategory,
    this.tags,
    this.creator,
    this.creatorWebsite,
    this.allowUsersMap,
    this.blockUsersMap,
    this.freezeAuthorityRevoked,
    this.mintAuthorityRevoked,
    this.updateAuthorityRevoked,
    this.paused,
    this.expiredAt,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      symbol: json['symbol'] as String?,
      name: json['name'] as String?,
      decimals: json['decimals'] as int?,
      totalSupply: json['total_supply'] as String?,
      description: json['description'] as String?,
      address: json['address'] as String?,
      hash: json['hash'] as String?,
      owner: json['owner'] as String?,
      feeTiersList: (json['fee_tiers_list'] as List<dynamic>?)
          ?.map((e) => FeeTier.fromJson(e as Map<String, dynamic>))
          .toList(),
      feeAddress: json['fee_address'] as String?,
      image: json['image'] as String?,
      website: json['website'] as String?,
      tagsSocialMedia: (json['tags_social_media'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v as String)),
      tagsCategory: (json['tags_category'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v as String)),
      tags: (json['tags'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v as String)),
      creator: json['creator'] as String?,
      creatorWebsite: json['creator_website'] as String?,
      allowUsersMap: (json['allow_users'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v as bool)),
      blockUsersMap: (json['block_users'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v as bool)),
      freezeAuthorityRevoked: json['freeze_authority_revoked'] as bool?,
      mintAuthorityRevoked: json['mint_authority_revoked'] as bool?,
      updateAuthorityRevoked: json['update_authority_revoked'] as bool?,
      paused: json['paused'] as bool?,
      expiredAt: json['expired_at'] != null
          ? DateTime.tryParse(json['expired_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'decimals': decimals,
      'total_supply': totalSupply,
      'description': description,
      'address': address,
      'hash': hash,
      'owner': owner,
      'fee_tiers_list': feeTiersList?.map((e) => e.toJson()).toList(),
      'fee_address': feeAddress,
      'image': image,
      'website': website,
      'tags_social_media': tagsSocialMedia,
      'tags_category': tagsCategory,
      'tags': tags,
      'creator': creator,
      'creator_website': creatorWebsite,
      'allow_users': allowUsersMap,
      'block_users': blockUsersMap,
      'freeze_authority_revoked': freezeAuthorityRevoked,
      'mint_authority_revoked': mintAuthorityRevoked,
      'update_authority_revoked': updateAuthorityRevoked,
      'paused': paused,
      'expired_at': expiredAt?.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'Token(symbol: $symbol, name: $name, decimals: $decimals, totalSupply: $totalSupply, address: $address)';
}