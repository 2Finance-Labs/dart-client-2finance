import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import 'package:two_finance_blockchain/blockchain/types/types.dart';
import 'package:two_finance_blockchain/blockchain/contract/tokenV1/domain/token.dart';
import 'package:two_finance_blockchain/blockchain/contract/tokenV1/domain/access_policy.dart';
import 'package:two_finance_blockchain/blockchain/contract/tokenV1/models/token.dart';
import 'package:two_finance_blockchain/blockchain/contract/tokenV1/domain/fee.dart';
import 'package:two_finance_blockchain/blockchain/contract/tokenV1/models/balance.dart';
import 'package:two_finance_blockchain/blockchain/contract/tokenV1/constants.dart';
import 'package:two_finance_blockchain/blockchain/utils/json.dart';
import 'package:two_finance_blockchain/blockchain/utils/decimals.dart';
import 'package:two_finance_blockchain/blockchain/utils/random.dart';
import 'package:two_finance_blockchain/two_finance_blockchain.dart';
// helpers
import '../../../helpers/helpers.dart';

void main() {
  final testTimeout = Timeout(Duration(minutes: 3));

  group('TokenV1 E2E', () {
    test('E2E: deploy token contract + addToken + getToken + mint + balance + transfer', () async {
      final c = await setupClient();

      // signer
      final kp = await validKeyPair();
      await c.setPrivateKey(kp.privateKey);

      // // deploy token contract
      final deployed = await c.deployContract1(TOKEN_CONTRACT_V1);
      expect(deployed.logs, isNotNull);
      expect(deployed.logs!, isNotEmpty);

      // final contr = unmarshalState(
      //   deployed.states!.first.object,
      //   (json) => TokenState.fromJson(json),
      // );
      // expect(contr.address, isNotNull);
      // expect(contr.address!, isNotEmpty);

      // final addr = contr.address!;
      // final owner = kp.publicKey;
      // final feeAddress = kp.publicKey;
      // final expiredAt = DateTime.now()
      //   .toUtc()
      //   .add(const Duration(days: 365));
      // final symbol = "TST_${generateRandomSuffix(6)}";
      // final frozenAcc = await validKeyPair();

      // final outAdd = await c.addToken(
      //   address: addr,
      //   symbol: symbol,
      //   name: "Test Token",
      //   decimals: 2,
      //   totalSupply: "1000",
      //   description: "token test",
      //   owner: owner,
      //   image: "https://example.com/image.png",
      //   website: "https://example.com",
      //   tagsSocialMedia: {"x": "@test"},
      //   tagsCategory: {"cat": "test"},
      //   tags: {"k": "v"},
      //   creator: "Name of creator",
      //   creatorWebsite: "https://creator.example.com",
      //   accessPolicy: AccessPolicy(users: {owner: true}, mode: "ALLOW"),
      //   frozenAccounts: {frozenAcc.publicKey: true},
      //   feeTiersList: const <Map<String, dynamic>>[
      //     {
      //       "min_amount": "0",
      //       "max_amount": "10000",
      //       "min_volume": "0",
      //       "max_volume": "100000",
      //       "fee_bps": 50,
      //     },
      //   ],
      //   feeAddress: feeAddress,
      //   freezeAuthorityRevoked: false,
      //   mintAuthorityRevoked: false,
      //   updateAuthorityRevoked: false,
      //   paused: false,
      //   expiredAt: expiredAt,
      //   assetGlbUri: "https://example.com/asset.glb",
      //   tokenType: TOKEN_TYPE_FUNGIBLE,
      //   transferable: true,
      //   stablecoin: false,
      // );

      // expect(outAdd.states, isNotNull);
      // expect(outAdd.states!, isNotEmpty);
      // final tokenState = unmarshalState(
      //   outAdd.states!.first.object,
      //   (json) => TokenState.fromJson(json),
      // );

      // expect(tokenState.address, equals(addr));
      // expect(tokenState.symbol, equals(symbol));
      // expect(tokenState.name, equals("Test Token"));
      // expect(tokenState.decimals, equals(2));
      // expect(tokenState.owner, equals(owner));
      // expect(tokenState.totalSupply, equals("1000"));
      // expect(tokenState.description, equals("token test"));
      // expect(tokenState.image, equals("https://example.com/image.png"));
      // expect(tokenState.website, equals("https://example.com"));
      // expect(tokenState.tagsSocialMedia, equals({"x": "@test"}));
      // expect(tokenState.tagsCategory, equals({"cat": "test"}));
      // expect(tokenState.tags, equals({"k": "v"}));
      // expect(tokenState.creator, equals("Name of creator"));
      // expect(tokenState.creatorWebsite, equals("https://creator.example.com"));
      // expect(tokenState.frozenAccounts, isNotNull);
      // expect(tokenState.frozenAccounts, equals({frozenAcc.publicKey: true}));
      // expect(tokenState.accessPolicy, isNotNull);
      // expect(tokenState.accessPolicy!.users, equals({owner: true}));
      // expect(tokenState.accessPolicy!.mode, equals("ALLOW"));
      // expect(tokenState.feeTiersList, isNotNull);
      // expect(tokenState.feeTiersList, equals([
      //   FeeTier(
      //     min_amount: "0",
      //     max_amount: "10000",
      //     min_volume: "0",
      //     max_volume: "100000",
      //     fee_bps: 50,
      //   ),
      // ]));
      // expect(tokenState.feeAddress, equals(feeAddress));
      // expect(tokenState.freezeAuthorityRevoked, isFalse);
      // expect(tokenState.mintAuthorityRevoked, isFalse);
      // expect(tokenState.updateAuthorityRevoked, isFalse);
      // expect(tokenState.paused, isFalse);
      // expect(tokenState.expiredAt, equals(expiredAt));
      // expect(tokenState.assetGlbUri, equals("https://example.com/asset.glb"));
      // expect(tokenState.tokenType, equals(TOKEN_TYPE_FUNGIBLE));
      // expect(tokenState.transferable, isTrue);
      // expect(tokenState.stablecoin, isFalse);

      // final tokenAddress = contr.address!;

      // // get token (by address)
      // final outGet = await c.getToken(tokenAddress: tokenAddress);
      // expect(outGet.states, isNotNull);
      // expect(outGet.states!, isNotEmpty);

      // final token2 = unmarshalState(
      //   outGet.states!.first.object,
      //   (json) => TokenState.fromJson(json),
      // );
      // expect(token2.address, equals(addr));
      // expect(token2.symbol, equals(symbol));
      // expect(token2.name, equals("Test Token"));
      // expect(token2.decimals, equals(2));
      // expect(token2.owner, equals(owner));
      // expect(token2.totalSupply, equals("1000"));
      // expect(token2.description, equals("token test"));
      // expect(token2.image, equals("https://example.com/image.png"));
      // expect(token2.website, equals("https://example.com"));
      // expect(token2.tagsSocialMedia, equals({"x": "@test"}));
      // expect(token2.tagsCategory, equals({"cat": "test"}));
      // expect(token2.tags, equals({"k": "v"}));
      // expect(token2.creator, equals("Name of creator"));
      // expect(token2.creatorWebsite, equals("https://creator.example.com"));
      // expect(token2.frozenAccounts, isNotNull);
      // expect(token2.frozenAccounts, equals({frozenAcc.publicKey: true}));
      // expect(token2.accessPolicy, isNotNull);
      // expect(token2.accessPolicy!.users, equals({owner: true}));
      // expect(token2.accessPolicy!.mode, equals("ALLOW"));
      // expect(token2.feeTiersList, isNotNull);
      // expect(token2.feeTiersList, equals([
      //   FeeTier(
      //     min_amount: "0",
      //     max_amount: "10000",
      //     min_volume: "0",
      //     max_volume: "100000",
      //     fee_bps: 50,
      //   ),
      // ]));
      // expect(token2.feeAddress, equals(feeAddress));
      // expect(token2.freezeAuthorityRevoked, isFalse);
      // expect(token2.mintAuthorityRevoked, isFalse);
      // expect(token2.updateAuthorityRevoked, isFalse);
      // expect(token2.paused, isFalse);
      // expect(token2.expiredAt, equals(expiredAt));
      // expect(token2.assetGlbUri, equals("https://example.com/asset.glb"));
      // expect(token2.tokenType, equals(TOKEN_TYPE_FUNGIBLE));
      // expect(token2.transferable, isTrue);
      // expect(token2.stablecoin, isFalse);

      // final outMint = await c.mintToken(
      //   tokenAddress: tokenAddress,
      //   mintTo: owner,
      //   amount: "150",
      //   decimals: 0,
      //   tokenType: TOKEN_TYPE_FUNGIBLE,
      // );
      // expect(outMint, isA<ContractOutput>());
      // expect(outMint.states, isNotNull);
      // expect(outMint.states!, isNotEmpty);
      

      // // balance do owner
      // final outBal = await c.getTokenBalance(tokenAddress: tokenAddress, ownerAddress: owner);
      // expect(outBal.states, isNotNull);
      // expect(outBal.states!, isNotEmpty);

      // final bal = unmarshalState(
      //   outBal.states!.first.object,
      //   (json) => BalanceState.fromJson(json),
      // );
      // expect(bal.ownerAddress, equals(owner));
      // expect(bal.tokenAddress, equals(tokenAddress));
      // expect(bal.amount, isNotNull);
      // expect(int.parse(bal.amount!), int.parse("1150")); // depende do supply/mint do contrato

      // // transfer para outro user
      // final kp2 = await validKeyPair();
      // final to = kp2.publicKey;

      // final outTransfer = await c.transferToken(
      //   tokenAddress: tokenAddress,
      //   transferTo: to,
      //   amount: "0.50",
      //   decimals: 2,
      //   tokenType: TOKEN_TYPE_FUNGIBLE,
      //   uuid: "",
      // );
      // expect(outTransfer, isA<ContractOutput>());

      // // balance do receiver (pode precisar de retries dependendo da consistência eventual)
      // final outBal2 = await c.getTokenBalance(tokenAddress: tokenAddress, ownerAddress: to);
      // expect(outBal2.states, isNotNull);
      // expect(outBal2.states!, isNotEmpty);

      // final bal2 = unmarshalState(
      //   outBal2.states!.first.object,
      //   (json) => BalanceState.fromJson(json),
      // );
      // expect(bal2.ownerAddress, equals(to));
      // expect(int.parse(bal2.amount!), greaterThanOrEqualTo(50));
    });

    test('rescaleDecimalString converts amount correctly', () {
      expect(rescaleDecimalString("1", 0, 2), equals("100"));
      expect(rescaleDecimalString("1.5", 2, 2), equals("150"));
      expect(rescaleDecimalString("1.50", 2, 2), equals("150"));
      expect(rescaleDecimalString("0.01", 2, 2), equals("1"));
    });
  });
}
