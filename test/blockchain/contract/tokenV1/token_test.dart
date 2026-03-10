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
import 'package:two_finance_blockchain/blockchain/utils/marshal.dart';
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

      final addr = deployed.logs!.first.contractAddress;
      expect(addr, isNotEmpty);

      // final addr = contr.address!;
      final owner = kp.publicKey;
      final feeAddress = kp.publicKey;
      final expiredAt = DateTime.now()
         .toUtc()
         .add(const Duration(days: 365));
      final symbol = "TST_${generateRandomSuffix(6)}";
      final frozenAcc = await validKeyPair();

      final outAdd = await c.addToken(
         address: addr,
         symbol: symbol,
         name: "Test Token",
         decimals: 2,
         totalSupply: "1000",
         description: "token test",
         owner: owner,
         image: "https://example.com/image.png",
         website: "https://example.com",
         tagsSocialMedia: {"x": "@test"},
         tagsCategory: {"cat": "test"},
         tags: {"k": "v"},
         creator: "Name of creator",
         creatorWebsite: "https://creator.example.com",
         accessPolicy: AccessPolicy(users: {owner: true}, mode: "ALLOW"),
         frozenAccounts: {frozenAcc.publicKey: true},
         feeTiersList: const <Map<String, dynamic>>[
           {
             "min_amount": "0",
             "max_amount": "10000",
             "min_volume": "0",
             "max_volume": "100000",
             "fee_bps": 50,
           },
         ],
         feeAddress: feeAddress,
         freezeAuthorityRevoked: false,
         mintAuthorityRevoked: false,
         updateAuthorityRevoked: false,
         paused: false,
         expiredAt: expiredAt,
         assetGlbUri: "https://example.com/asset.glb",
         tokenType: TOKEN_TYPE_FUNGIBLE,
         transferable: true,
         stablecoin: false,
       );

        final tokenAddress = addr;
        final outGet = await c.getToken(tokenAddress: tokenAddress);
        expect(outGet.states, isNotNull);
        expect(outGet.states!, isNotEmpty);

        ContractOutput? outGetBySymbol;
        for (var i = 0; i < 10; i++) {
          outGetBySymbol = await c.getToken(symbol: symbol);
          if (outGetBySymbol.states != null && outGetBySymbol.states!.isNotEmpty) break;
          await Future.delayed(const Duration(milliseconds: 300));
        }

        expect(outGetBySymbol, isNotNull);
        expect(outGetBySymbol!.states, isNotNull);
        expect(outGetBySymbol.states!, isNotEmpty);

        final tokenBySymbol = unmarshalState(
          outGetBySymbol.states!.first.object,
          (json) => TokenState.fromJson(json),
        );

        expect(tokenBySymbol.address, equals(addr));
        expect(tokenBySymbol.symbol, equals(symbol));
        expect(tokenBySymbol.name, equals("Test Token"));
        expect(tokenBySymbol.tokenType, equals(TOKEN_TYPE_FUNGIBLE));

        final tokenState = unmarshalState(
         outGet.states!.first.object,
         (json) => TokenState.fromJson(json),
       );

       expect(tokenState.address, equals(addr));
       expect(tokenState.symbol, equals(symbol));
       expect(tokenState.name, equals("Test Token"));
       expect(tokenState.decimals, equals(2));
       expect(tokenState.owner, equals(owner));
       expect(tokenState.totalSupply, equals("1000"));
       expect(tokenState.description, equals("token test"));
       expect(tokenState.image, equals("https://example.com/image.png"));
       expect(tokenState.website, equals("https://example.com"));
       expect(tokenState.tagsSocialMedia, equals({"x": "@test"}));
       expect(tokenState.tagsCategory, equals({"cat": "test"}));
       expect(tokenState.tags, equals({"k": "v"}));
       expect(tokenState.creator, equals("Name of creator"));
       expect(tokenState.creatorWebsite, equals("https://creator.example.com"));
       expect(tokenState.frozenAccounts, isNotNull);
       expect(tokenState.frozenAccounts, equals({frozenAcc.publicKey: true}));
       expect(tokenState.accessPolicy, isNotNull);
       expect(tokenState.accessPolicy!.users, equals({owner: true}));
       expect(tokenState.accessPolicy!.mode, equals("ALLOW"));
       expect(tokenState.feeTiersList, isNotNull);
       expect(tokenState.feeTiersList, equals([
         FeeTier(
           min_amount: "0",
           max_amount: "10000",
           min_volume: "0",
           max_volume: "100000",
           fee_bps: 50,
         ),
       ]));
       expect(tokenState.feeAddress, equals(feeAddress));
       expect(tokenState.freezeAuthorityRevoked, isFalse);
       expect(tokenState.mintAuthorityRevoked, isFalse);
       expect(tokenState.updateAuthorityRevoked, isFalse);
       expect(tokenState.paused, isFalse);
       expect(tokenState.expiredAt, equals(expiredAt));
       expect(tokenState.assetGlbUri, equals("https://example.com/asset.glb"));
       expect(tokenState.tokenType, equals(TOKEN_TYPE_FUNGIBLE));
       expect(tokenState.transferable, isTrue);
       expect(tokenState.stablecoin, isFalse);

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


      ContractOutput? outGetByName;
      for (var i = 0; i < 10; i++) {
        outGetByName = await c.getToken(name: "Test Token");
        if (outGetByName.states != null && outGetByName.states!.isNotEmpty) break;
        await Future.delayed(const Duration(milliseconds: 300));
      }

      expect(outGetByName, isNotNull);
      expect(outGetByName!.states, isNotNull);
      expect(outGetByName.states!, isNotEmpty);

      final tokenByName = unmarshalState(
        outGetByName.states!.first.object,
        (json) => TokenState.fromJson(json),
      );

      expect(tokenByName.address, equals(addr));
      expect(tokenByName.symbol, equals(symbol));
      expect(tokenByName.name, equals("Test Token"));
      expect(tokenByName.tokenType, equals(TOKEN_TYPE_FUNGIBLE));


      ContractOutput? outListTokens;
      TokenState? listedToken;
      bool foundListedToken = false;

      for (var i = 0; i < 10; i++) {
        outListTokens = await c.listTokens(
        page: 1,
        symbol: symbol,
        ascending: false,
      );

        if (outListTokens.states != null && outListTokens.states!.isNotEmpty) {
          for (final state in outListTokens.states!) {
            final rawObject = state.object;

            if (rawObject is List) {
              for (final item in rawObject) {
                final token = TokenState.fromJson(
                  Map<String, dynamic>.from(item as Map),
                );

                if (token.address == addr) {
                  listedToken = token;
                  foundListedToken = true;
                  break;
                }
              }
            }

            if (foundListedToken) break;
          }
        }

        if (foundListedToken) break;
        await Future.delayed(const Duration(milliseconds: 300));
      }

      expect(outListTokens, isNotNull);
      expect(outListTokens!.states, isNotNull);
      expect(outListTokens.states!, isNotEmpty);
      expect(foundListedToken, isTrue);
      expect(listedToken, isNotNull);

      expect(listedToken!.address, equals(addr));
      expect(listedToken!.symbol, equals(symbol));
      expect(listedToken!.name, equals("Test Token"));
      expect(listedToken!.tokenType, equals(TOKEN_TYPE_FUNGIBLE));


       final outMint = await c.mintToken(
         tokenAddress: tokenAddress,
         mintTo: owner,
         amount: "150",
         decimals: 0,
         tokenType: TOKEN_TYPE_FUNGIBLE,
       );
       expect(outMint, isA<ContractOutput>());
       expect(outMint.logs, isNotNull);
       expect(outMint.logs!, isNotEmpty);
      

      // // balance do owner
       final outBal = await c.getTokenBalance(tokenAddress: tokenAddress, ownerAddress: owner);
       expect(outBal.states, isNotNull);
       expect(outBal.states!, isNotEmpty);

       final bal = unmarshalState(
         outBal.states!.first.object,
         (json) => BalanceState.fromJson(json),
       );
       expect(bal.ownerAddress, equals(owner));
       expect(bal.tokenAddress, equals(tokenAddress));
       expect(bal.amount, isNotNull);
       expect(int.parse(bal.amount!), int.parse("1150")); // depende do supply/mint do contrato
       
       // list balances
      final outListBalances = await c.listTokenBalances(
        tokenAddress: tokenAddress,
        ownerAddress: owner,
        page: 1,
      );

      expect(outListBalances.states, isNotNull);
      expect(outListBalances.states!, isNotEmpty);

      BalanceState? listedBalance;
      bool foundListedBalance = false;

      for (final state in outListBalances.states!) {
        final rawObject = state.object;

        if (rawObject is List) {
          for (final item in rawObject) {
            final balance = BalanceState.fromJson(
              Map<String, dynamic>.from(item as Map),
            );

            if (balance.tokenAddress == tokenAddress &&
                balance.ownerAddress == owner) {
              listedBalance = balance;
              foundListedBalance = true;
              break;
            }
          }
        } else if (rawObject is Map) {
          final balance = BalanceState.fromJson(
            Map<String, dynamic>.from(rawObject),
          );

          if (balance.tokenAddress == tokenAddress &&
              balance.ownerAddress == owner) {
            listedBalance = balance;
            foundListedBalance = true;
          }
        }

        if (foundListedBalance) break;
      }

      expect(foundListedBalance, isTrue);
      expect(listedBalance, isNotNull);

      expect(listedBalance!.tokenAddress, equals(tokenAddress));
      expect(listedBalance!.ownerAddress, equals(owner));
      expect(listedBalance!.amount, isNotNull);
      expect(int.parse(listedBalance!.amount!), int.parse("1150"));
      
        // ------------------
        //       PAUSE
        // ------------------
        final outPause = await c.pauseToken(tokenAddress);
        expect(outPause, isA<ContractOutput>());
        expect(outPause.logs, isNotNull);
        expect(outPause.logs!, isNotEmpty);

        final pauseLog = outPause.logs!.first;
        expect(pauseLog.logType, equals('Token_Paused'));
        expect(pauseLog.contractAddress, equals(tokenAddress));

        final pauseEvent = jsonDecode(
          utf8.decode(base64Decode(pauseLog.event)),
        ) as Map<String, dynamic>;

        expect(pauseEvent['token_address'], equals(tokenAddress));
        expect(pauseEvent['enabled'], isTrue);

        final outGetPaused = await c.getToken(tokenAddress: tokenAddress);
        expect(outGetPaused.states, isNotNull);
        expect(outGetPaused.states!, isNotEmpty);

        final pausedTokenState = unmarshalState(
          outGetPaused.states!.first.object,
          (json) => TokenState.fromJson(json),
        );

        expect(pausedTokenState.address, equals(tokenAddress));
        expect(pausedTokenState.paused, isTrue);


        // ------------------
        //      UNPAUSE
        // ------------------
        final outUnpause = await c.unpauseToken(tokenAddress);
        expect(outUnpause, isA<ContractOutput>());
        expect(outUnpause.logs, isNotNull);
        expect(outUnpause.logs!, isNotEmpty);

        final unpauseLog = outUnpause.logs!.first;
        expect(unpauseLog.logType, equals('Token_Unpaused'));
        expect(unpauseLog.contractAddress, equals(tokenAddress));

        final unpauseEvent = jsonDecode(
          utf8.decode(base64Decode(unpauseLog.event)),
        ) as Map<String, dynamic>;

        expect(unpauseEvent['token_address'], equals(tokenAddress));

        final outGetUnpaused = await c.getToken(tokenAddress: tokenAddress);
        expect(outGetUnpaused.states, isNotNull);
        expect(outGetUnpaused.states!, isNotEmpty);

        final unpausedTokenState = unmarshalState(
          outGetUnpaused.states!.first.object,
          (json) => TokenState.fromJson(json),
        );

        expect(unpausedTokenState.address, equals(tokenAddress));
        expect(unpausedTokenState.paused, isFalse);

        // ------------------
        //    UPDATE FEE TIERS
        // ------------------
        final newFeeTiers = <Map<String, dynamic>>[
          {
            "min_amount": "0",
            "max_amount": "20000",
            "min_volume": "0",
            "max_volume": "300000",
            "fee_bps": 75,
          },
        ];

        final outUpdateFeeTiers = await c.updateFeeTiers(tokenAddress, newFeeTiers);

        expect(outUpdateFeeTiers, isA<ContractOutput>());
        expect(outUpdateFeeTiers.logs, isNotNull);
        expect(outUpdateFeeTiers.logs!, isNotEmpty);

        final updateFeeTiersLog = outUpdateFeeTiers.logs!.first;
        expect(updateFeeTiersLog.logType, equals('Token_FeeUpdated'));
        expect(updateFeeTiersLog.contractAddress, equals(tokenAddress));

        final updateFeeTiersEvent = jsonDecode(
          utf8.decode(base64Decode(updateFeeTiersLog.event)),
        ) as Map<String, dynamic>;

        expect(updateFeeTiersEvent['fee_tiers_list'], isA<List>());
        final feeTiersEventList =
            List<Map<String, dynamic>>.from(updateFeeTiersEvent['fee_tiers_list']);

        expect(feeTiersEventList, hasLength(1));

        final updatedFeeTierEvent = feeTiersEventList.first;
        expect(updatedFeeTierEvent['min_amount'], equals('0'));
        expect(updatedFeeTierEvent['max_amount'], equals('20000'));
        expect(updatedFeeTierEvent['min_volume'], equals('0'));
        expect(updatedFeeTierEvent['max_volume'], equals('300000'));
        expect(updatedFeeTierEvent['fee_bps'], equals(75));

        final outGetUpdatedFeeTiers = await c.getToken(tokenAddress: tokenAddress);
        expect(outGetUpdatedFeeTiers.states, isNotNull);
        expect(outGetUpdatedFeeTiers.states!, isNotEmpty);

        final updatedFeeTiersTokenState = unmarshalState(
          outGetUpdatedFeeTiers.states!.first.object,
          (json) => TokenState.fromJson(json),
        );

        expect(updatedFeeTiersTokenState.address, equals(tokenAddress));
        expect(updatedFeeTiersTokenState.feeTiersList, isNotNull);
        expect(updatedFeeTiersTokenState.feeTiersList!, isNotEmpty);

        final updatedFeeTier = updatedFeeTiersTokenState.feeTiersList!.first;
        expect(updatedFeeTier.min_amount, equals("0"));
        expect(updatedFeeTier.max_amount, equals("20000"));
        expect(updatedFeeTier.min_volume, equals("0"));
        expect(updatedFeeTier.max_volume, equals("300000"));
        expect(updatedFeeTier.fee_bps, equals(75));


       // transfer para outro user
       // final kp2 = await validKeyPair();
      //  final to = kp2.publicKey;

      //  final outTransfer = await c.transferToken(
      //    tokenAddress: tokenAddress,
      //    transferTo: to,
      //    amount: "0.50",
      //    decimals: 2,
      //    tokenType: TOKEN_TYPE_FUNGIBLE,
      //    uuid: "",
      //  );
      //  expect(outTransfer, isA<ContractOutput>());

       // balance do receiver (pode precisar de retries dependendo da consistência eventual)
      //  final outBal2 = await c.getTokenBalance(tokenAddress: tokenAddress, ownerAddress: to);
      //  expect(outBal2.states, isNotNull);
      //  expect(outBal2.states!, isNotEmpty);

      //  final bal2 = unmarshalState(
      //    outBal2.states!.first.object,
      //    (json) => BalanceState.fromJson(json),
      //  );
      //  expect(bal2.ownerAddress, equals(to));
      //  expect(int.parse(bal2.amount!), greaterThanOrEqualTo(50));
     });


    
    test('rescaleDecimalString converts amount correctly', () {
      expect(rescaleDecimalString("1", 0, 2), equals("100"));
      expect(rescaleDecimalString("1.5", 2, 2), equals("150"));
      expect(rescaleDecimalString("1.50", 2, 2), equals("150"));
      expect(rescaleDecimalString("0.01", 2, 2), equals("1"));
    });
  });
}