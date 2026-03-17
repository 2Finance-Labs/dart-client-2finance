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
      final feeKp = await validKeyPair();
      final feeAddress = feeKp.publicKey;
      final expiredAt = DateTime.now()
          .toUtc()
          .add(const Duration(days: 365));
      final symbol = "TST_${generateRandomSuffix(6)}";
      final frozenAcc = await validKeyPair();

      final receiverTransferKp = await validKeyPair();
      final receiverTransfer = receiverTransferKp.publicKey;

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
         allowedUsers: {receiverTransfer: true},
         blockedUsers: {},
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
       expect(tokenState.allowedUsers, isNotNull);
       expect(tokenState.allowedUsers![receiverTransfer], isTrue);
       expect(tokenState.blockedUsers ?? {}, isEmpty);
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
       expect(tokenState.expiredAt, isNotNull);
       expect(tokenState.expiredAt!.toUtc().toIso8601String(),
            equals(expiredAt.toUtc().toIso8601String()));
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

        // // Mint

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

      final outGetAfterMint = await c.getToken(tokenAddress: tokenAddress);
      expect(outGetAfterMint.states, isNotNull);
      expect(outGetAfterMint.states!, isNotEmpty);

      final tokenStateAfterMint = unmarshalState(
        outGetAfterMint.states!.first.object,
        (json) => TokenState.fromJson(json),
      );

      expect(tokenStateAfterMint.address, equals(tokenAddress));
      expect(tokenStateAfterMint.totalSupply, equals("1150"));


      

        // ------------------
        //   TRANSFER TOKEN
        // ------------------

      // tentativa com erro por saldo insuficiente
      await expectLater(
        () => c.transferToken(
          tokenAddress: tokenAddress,
          transferTo: receiverTransfer,
          amount: "5000000000000000",
          decimals: 0,
          tokenType: TOKEN_TYPE_FUNGIBLE,
          uuid: "",
        ),
        throwsA(isA<Exception>()),
      );

      // transfer com sucesso
      final outTransfer = await c.transferToken(
        tokenAddress: tokenAddress,
        transferTo: receiverTransfer,
        amount: "600",
        decimals: 0,
        tokenType: TOKEN_TYPE_FUNGIBLE,
        uuid: "",
      );

      expect(outTransfer, isA<ContractOutput>());
      expect(outTransfer.logs, isNotNull);
      expect(outTransfer.logs!, isNotEmpty);

      // saldo do owner após transfer
      final outOwnerBalAfterTransfer = await c.getTokenBalance(
        tokenAddress: tokenAddress,
        ownerAddress: owner,
      );
      expect(outOwnerBalAfterTransfer.states, isNotNull);
      expect(outOwnerBalAfterTransfer.states!, isNotEmpty);

      final ownerBalAfterTransfer = unmarshalState(
        outOwnerBalAfterTransfer.states!.first.object,
        (json) => BalanceState.fromJson(json),
      );

      // saldo do receiver após transfer
      final outReceiverBalAfterTransfer = await c.getTokenBalance(
        tokenAddress: tokenAddress,
        ownerAddress: receiverTransfer,
      );
      expect(outReceiverBalAfterTransfer.states, isNotNull);
      expect(outReceiverBalAfterTransfer.states!, isNotEmpty);

      final receiverBalAfterTransfer = unmarshalState(
        outReceiverBalAfterTransfer.states!.first.object,
        (json) => BalanceState.fromJson(json),
      );

      // supply não muda no transfer
      final outGetAfterTransfer = await c.getToken(tokenAddress: tokenAddress);
      expect(outGetAfterTransfer.states, isNotNull);
      expect(outGetAfterTransfer.states!, isNotEmpty);

      final tokenStateAfterTransfer = unmarshalState(
        outGetAfterTransfer.states!.first.object,
        (json) => TokenState.fromJson(json),
      );


      final outFeeBalAfterTransfer = await c.getTokenBalance(
      tokenAddress: tokenAddress,
      ownerAddress: feeAddress,
      );
      expect(outFeeBalAfterTransfer.states, isNotNull);
      expect(outFeeBalAfterTransfer.states!, isNotEmpty);

      final feeBalAfterTransfer = unmarshalState(
        outFeeBalAfterTransfer.states!.first.object,
        (json) => BalanceState.fromJson(json),
      );

      expect(ownerBalAfterTransfer.amount, equals("550"));
      expect(receiverBalAfterTransfer.amount, equals("597"));
      expect(feeBalAfterTransfer.amount, equals("3"));
      expect(tokenStateAfterTransfer.totalSupply, equals("1150"));



        // ------------------
        //        BURN
        // ------------------
      final outBurn = await c.burnToken(
      tokenAddress: tokenAddress,
      amount: "25",
      decimals: 0,
      tokenType: TOKEN_TYPE_FUNGIBLE,
      uuid: "",
      );

      expect(outBurn, isA<ContractOutput>());
      expect(outBurn.logs, isNotNull);
      expect(outBurn.logs!, isNotEmpty);

      // saldo do owner depois do burn
      final outBalAfterBurn = await c.getTokenBalance(
        tokenAddress: tokenAddress,
        ownerAddress: owner,
      );
      expect(outBalAfterBurn.states, isNotNull);
      expect(outBalAfterBurn.states!, isNotEmpty);

      final balAfterBurn = unmarshalState(
        outBalAfterBurn.states!.first.object,
        (json) => BalanceState.fromJson(json),
      );

      expect(balAfterBurn.ownerAddress, equals(owner));
      expect(balAfterBurn.tokenAddress, equals(tokenAddress));
      expect(balAfterBurn.amount, equals("525"));

      final outGetAfterBurn = await c.getToken(tokenAddress: tokenAddress);
      expect(outGetAfterBurn.states, isNotNull);
      expect(outGetAfterBurn.states!, isNotEmpty);

      final tokenStateAfterBurn = unmarshalState(
        outGetAfterBurn.states!.first.object,
        (json) => TokenState.fromJson(json),
      );

      expect(tokenStateAfterBurn.address, equals(tokenAddress));
      expect(tokenStateAfterBurn.totalSupply, equals("1125"));

        
        

        // ------------------
        // CHANGE ACCESS MODE
        // ------------------
     //   final outChangeAccessModeToAllow = await c.changeAccessMode(
     //     tokenAddress,
     //     'ALLOW_ACCESS_MODE',
     //   );

     //   expect(outChangeAccessModeToAllow, isA<ContractOutput>());
     //   expect(outChangeAccessModeToAllow.logs, isNotNull);
     //   expect(outChangeAccessModeToAllow.logs!, isNotEmpty);

     //   final changeAccessToAllowLog = outChangeAccessModeToAllow.logs!.first;
     //   expect(changeAccessToAllowLog.contractAddress, equals(tokenAddress));
     //   expect(changeAccessToAllowLog.logType, equals('Token_AccessModeChanged'));

      //  final changeAccessToAllowEvent = jsonDecode(
      //    utf8.decode(base64Decode(changeAccessToAllowLog.event)),
      //  ) as Map<String, dynamic>;

      //  expect(changeAccessToAllowEvent['address'], equals(tokenAddress));
       // expect(changeAccessToAllowEvent['access_mode'], equals('ALLOW_ACCESS_MODE'));

       // final outGetAfterChangeAccessModeToAllow = await c.getToken(
       //   tokenAddress: tokenAddress,
       // );
      //  expect(outGetAfterChangeAccessModeToAllow.states, isNotNull);
      //  expect(outGetAfterChangeAccessModeToAllow.states!, isNotEmpty);

       // final tokenStateAfterChangeAccessModeToAllow = unmarshalState(
       //   outGetAfterChangeAccessModeToAllow.states!.first.object,
      //    (json) => TokenState.fromJson(json),
       // );

       // expect(tokenStateAfterChangeAccessModeToAllow.address, equals(tokenAddress));
      //  expect(tokenStateAfterChangeAccessModeToAllow.accessPolicy, isNotNull);
       // expect(
       //   tokenStateAfterChangeAccessModeToAllow.accessPolicy!.mode,
      //    equals('ALLOW_ACCESS_MODE'),
        //);
        //expect(
        //  tokenStateAfterChangeAccessModeToAllow.accessPolicy!.users,
        //  isEmpty,
        //);

        // ------------------
        // ACCESS CONTROL
        // ------------------
        // Ajuste estes nomes se o backend estiver retornando logs específicos
        const allowedUsersAddedLogType = 'Token_AllowedUsersAdded';
        const allowedUsersRemovedLogType = 'Token_AllowedUsersRemoved';
        const blockedUsersAddedLogType = 'Token_BlockedUsersAdded';
        const blockedUsersRemovedLogType = 'Token_BlockedUsersRemoved';

        // ------------------
        //    ALLOW USERS
        // ------------------
        final allowUserKp = await validKeyPair();
        final allowUser = allowUserKp.publicKey;

        final outAllowUsers = await c.allowUsers(
          tokenAddress,
          {allowUser: true},
        );

        expect(outAllowUsers, isA<ContractOutput>());
        expect(outAllowUsers.logs, isNotNull);
        expect(outAllowUsers.logs!, isNotEmpty);

        final allowLog = outAllowUsers.logs!.first;
        expect(allowLog.contractAddress, equals(tokenAddress));
        expect(allowLog.logType, equals(allowedUsersAddedLogType));

        final allowEvent = _decodeEvent(allowLog.event);
        expect(allowEvent['address'], equals(tokenAddress));

        final allowEventAllowedUsers = _asMap(allowEvent['allowed_users']);
        expect(allowEventAllowedUsers[allowUser], isTrue);

        final outGetAfterAllow = await c.getToken(tokenAddress: tokenAddress);
        expect(outGetAfterAllow.states, isNotNull);
        expect(outGetAfterAllow.states!, isNotEmpty);

        final tokenStateAfterAllow = unmarshalState(
          outGetAfterAllow.states!.first.object,
          (json) => TokenState.fromJson(json),
        );

        expect(tokenStateAfterAllow.address, equals(tokenAddress));
        expect(tokenStateAfterAllow.allowedUsers, isNotNull);
        expect(tokenStateAfterAllow.allowedUsers![allowUser], isTrue);

        // ------------------
        // REMOVE ALLOW USERS
        // ------------------
        final outRemoveAllowUsers = await c.disallowUsers(
          tokenAddress,
          {allowUser: true},
        );

        expect(outRemoveAllowUsers, isA<ContractOutput>());
        expect(outRemoveAllowUsers.logs, isNotNull);
        expect(outRemoveAllowUsers.logs!, isNotEmpty);

        final removeAllowLog = outRemoveAllowUsers.logs!.first;
        expect(removeAllowLog.contractAddress, equals(tokenAddress));
        expect(removeAllowLog.logType, equals(allowedUsersRemovedLogType));

        final removeAllowEvent = _decodeEvent(removeAllowLog.event);
        expect(removeAllowEvent['address'], equals(tokenAddress));

        final removeAllowEventAllowedUsers = _asMap(removeAllowEvent['allowed_users']);
        expect(removeAllowEventAllowedUsers.containsKey(allowUser), isTrue);
        expect(removeAllowEventAllowedUsers[allowUser], isTrue);

        final outGetAfterRemoveAllow = await c.getToken(tokenAddress: tokenAddress);
        expect(outGetAfterRemoveAllow.states, isNotNull);
        expect(outGetAfterRemoveAllow.states!, isNotEmpty);

        final tokenStateAfterRemoveAllow = unmarshalState(
          outGetAfterRemoveAllow.states!.first.object,
          (json) => TokenState.fromJson(json),
        );

        expect(tokenStateAfterRemoveAllow.address, equals(tokenAddress));
        expect(
          tokenStateAfterRemoveAllow.allowedUsers?.containsKey(allowUser) ?? false,
          isFalse,
        );

        // ------------------
        //    BLOCK USERS
        // ------------------
        final outBlockUsers = await c.blockUsers(
          tokenAddress,
          {receiverTransfer: true},
        );

        expect(outBlockUsers, isA<ContractOutput>());
        expect(outBlockUsers.logs, isNotNull);
        expect(outBlockUsers.logs!, isNotEmpty);

        final blockLog = outBlockUsers.logs!.first;
        expect(blockLog.contractAddress, equals(tokenAddress));
        expect(blockLog.logType, equals(blockedUsersAddedLogType));

        final blockEvent = _decodeEvent(blockLog.event);
        expect(blockEvent['address'], equals(tokenAddress));

        final blockEventBlockedUsers = _asMap(blockEvent['blocked_users']);
        expect(blockEventBlockedUsers[receiverTransfer], isTrue);

        final outGetAfterBlock = await c.getToken(tokenAddress: tokenAddress);
        expect(outGetAfterBlock.states, isNotNull);
        expect(outGetAfterBlock.states!, isNotEmpty);

        final tokenStateAfterBlock = unmarshalState(
          outGetAfterBlock.states!.first.object,
          (json) => TokenState.fromJson(json),
        );

        expect(tokenStateAfterBlock.address, equals(tokenAddress));
        expect(tokenStateAfterBlock.blockedUsers, isNotNull);
        expect(tokenStateAfterBlock.blockedUsers![receiverTransfer], isTrue);

        // ------------------
        // REMOVE BLOCK USERS
        // ------------------
        final outUnblockUsers = await c.unblockUsers(
          tokenAddress,
          {receiverTransfer: true},
        );

        expect(outUnblockUsers, isA<ContractOutput>());
        expect(outUnblockUsers.logs, isNotNull);
        expect(outUnblockUsers.logs!, isNotEmpty);

        final unblockLog = outUnblockUsers.logs!.first;
        expect(unblockLog.contractAddress, equals(tokenAddress));
        expect(unblockLog.logType, equals(blockedUsersRemovedLogType));

        final unblockEvent = _decodeEvent(unblockLog.event);
        expect(unblockEvent['address'], equals(tokenAddress));

        final unblockEventBlockedUsers = _asMap(unblockEvent['blocked_users']);
        expect(unblockEventBlockedUsers.containsKey(receiverTransfer), isTrue);
        expect(unblockEventBlockedUsers[receiverTransfer], isTrue);

        final outGetAfterUnblock = await c.getToken(tokenAddress: tokenAddress);
        expect(outGetAfterUnblock.states, isNotNull);
        expect(outGetAfterUnblock.states!, isNotEmpty);

        final tokenStateAfterUnblock = unmarshalState(
          outGetAfterUnblock.states!.first.object,
          (json) => TokenState.fromJson(json),
        );

        expect(tokenStateAfterUnblock.address, equals(tokenAddress));
        expect(
          tokenStateAfterUnblock.blockedUsers?.containsKey(receiverTransfer) ?? false,
          isFalse,
        );

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

        final feeTiersEventList = List<Map<String, dynamic>>.from(
        updateFeeTiersEvent['fee_tiers_list'] as List,
        );

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


        // ------------------
        //   UPDATE FEE ADDRESS
        // ------------------
        final newFeeKp = await validKeyPair();
        final newFeeAddress = newFeeKp.publicKey;

        final outUpdateFeeAddress = await c.updateFeeAddress(
          tokenAddress,
          newFeeAddress,
        );

        expect(outUpdateFeeAddress, isA<ContractOutput>());
        expect(outUpdateFeeAddress.logs, isNotNull);
        expect(outUpdateFeeAddress.logs!, isNotEmpty);

        final outGetUpdatedFeeAddress = await c.getToken(
          tokenAddress: tokenAddress,
        );

        expect(outGetUpdatedFeeAddress.states, isNotNull);
        expect(outGetUpdatedFeeAddress.states!, isNotEmpty);

        final updatedFeeAddressTokenState = unmarshalState(
          outGetUpdatedFeeAddress.states!.first.object,
          (json) => TokenState.fromJson(json),
        );

        expect(updatedFeeAddressTokenState.address, equals(tokenAddress));
        expect(
          updatedFeeAddressTokenState.feeAddress,
          equals(newFeeAddress),
        );


        // ------------------
        //   UPDATE METADATA
        // ------------------
        final newSymbol = "2FNEW_${generateRandomSuffix(4)}";

        final outUpdateMetadata = await c.updateMetadata(
          tokenAddress: tokenAddress,
          symbol: newSymbol,
          name: "2Finance New",
          decimals: 2,
          description: "Updated by tests",
          image: "https://example.com/img.png",
          website: "https://example.com",
          tagsSocialMedia: {"twitter": "https://x.com/2f"},
          tagsCategory: {"category": "DeFi"},
          tags: {"tag1": "e2e"},
          creator: "Name of creator",
          creatorWebsite: "https://creator",
          expiredAt: DateTime.now().toUtc().add(const Duration(days: 30)),
        );

        expect(outUpdateMetadata, isA<ContractOutput>());
        expect(outUpdateMetadata.logs, isNotNull);
        expect(outUpdateMetadata.logs!, isNotEmpty);

        final outGetUpdatedMetadata = await c.getToken(
          tokenAddress: tokenAddress,
        );

        expect(outGetUpdatedMetadata.states, isNotNull);
        expect(outGetUpdatedMetadata.states!, isNotEmpty);

        final updatedMetadataTokenState = unmarshalState(
          outGetUpdatedMetadata.states!.first.object,
          (json) => TokenState.fromJson(json),
        );

        expect(updatedMetadataTokenState.address, equals(tokenAddress));
        expect(updatedMetadataTokenState.symbol, equals(newSymbol));
        expect(updatedMetadataTokenState.name, equals("2Finance New"));
        expect(updatedMetadataTokenState.decimals, equals(2));
        expect(
          updatedMetadataTokenState.description,
          equals("Updated by tests"),
        );
        expect(
          updatedMetadataTokenState.image,
          equals("https://example.com/img.png"),
        );
        expect(
          updatedMetadataTokenState.website,
          equals("https://example.com"),
        );
        expect(
          updatedMetadataTokenState.tagsSocialMedia,
          equals({"twitter": "https://x.com/2f"}),
        );
        expect(
          updatedMetadataTokenState.tagsCategory,
          equals({"category": "DeFi"}),
        );
        expect(
          updatedMetadataTokenState.tags,
          equals({"tag1": "e2e"}),
        );
        expect(
          updatedMetadataTokenState.creator,
          equals("Name of creator"),
        );
        expect(
          updatedMetadataTokenState.creatorWebsite,
          equals("https://creator"),
        );



        // ------------------
        //      FREEZE
        // ------------------
        final outFreezeWallet = await c.freezeWallet(
          tokenAddress,
          owner,
        );

        expect(outFreezeWallet, isA<ContractOutput>());
        expect(outFreezeWallet.logs, isNotNull);
        expect(outFreezeWallet.logs!, isNotEmpty);

        final freezeLog = outFreezeWallet.logs!.first;
        expect(freezeLog.contractAddress, equals(tokenAddress));
        expect(freezeLog.logType, equals('Token_Freeze_Account'));

        final freezeEvent = jsonDecode(
          utf8.decode(base64Decode(freezeLog.event)),
        ) as Map<String, dynamic>;

        expect(freezeEvent['token_address'], equals(tokenAddress));

        final frozenAccountsEventMap = Map<String, dynamic>.from(
          freezeEvent['frozen_accounts'] as Map,
        );

        expect(frozenAccountsEventMap[owner], isTrue);

        final outGetAfterFreeze = await c.getToken(tokenAddress: tokenAddress);
        expect(outGetAfterFreeze.states, isNotNull);
        expect(outGetAfterFreeze.states!, isNotEmpty);

        final tokenStateAfterFreeze = unmarshalState(
          outGetAfterFreeze.states!.first.object,
          (json) => TokenState.fromJson(json),
        );

        expect(tokenStateAfterFreeze.address, equals(tokenAddress));
        expect(tokenStateAfterFreeze.frozenAccounts, isNotNull);
        expect(tokenStateAfterFreeze.frozenAccounts![owner], isTrue);

        // ------------------
        //      UNFREEZE
        // ------------------
        final outUnfreezeWallet = await c.unfreezeWallet(
          tokenAddress,
          owner,
        );

        expect(outUnfreezeWallet, isA<ContractOutput>());
        expect(outUnfreezeWallet.logs, isNotNull);
        expect(outUnfreezeWallet.logs!, isNotEmpty);

        final unfreezeLog = outUnfreezeWallet.logs!.first;
        expect(unfreezeLog.contractAddress, equals(tokenAddress));
        expect(unfreezeLog.logType, equals('Token_Unfreeze_Account'));

        final unfreezeEvent = jsonDecode(
          utf8.decode(base64Decode(unfreezeLog.event)),
        ) as Map<String, dynamic>;

        expect(unfreezeEvent['token_address'], equals(tokenAddress));

        final unfrozenAccountsEventMap = Map<String, dynamic>.from(
          unfreezeEvent['frozen_accounts'] as Map,
        );

        expect(unfrozenAccountsEventMap[owner], isFalse);

        final outGetAfterUnfreeze = await c.getToken(tokenAddress: tokenAddress);
        expect(outGetAfterUnfreeze.states, isNotNull);
        expect(outGetAfterUnfreeze.states!, isNotEmpty);

        final tokenStateAfterUnfreeze = unmarshalState(
          outGetAfterUnfreeze.states!.first.object,
          (json) => TokenState.fromJson(json),
        );

        expect(tokenStateAfterUnfreeze.address, equals(tokenAddress));
        expect(tokenStateAfterUnfreeze.frozenAccounts, isNotNull);
        expect(
          tokenStateAfterUnfreeze.frozenAccounts!.containsKey(owner),
          isFalse,
        );



        // ------------------
        //    UPDATE GLB FILE
        // ------------------
        final newGlbUri = "https://example.com/updated-asset.glb";

        final outUpdateGlbFile = await c.updateGlbFile(
          tokenAddress,
          newGlbUri,
        );

        expect(outUpdateGlbFile, isA<ContractOutput>());
        expect(outUpdateGlbFile.logs, isNotNull);
        expect(outUpdateGlbFile.logs!, isNotEmpty);

        final outGetUpdatedGlb = await c.getToken(
          tokenAddress: tokenAddress,
        );

        expect(outGetUpdatedGlb.states, isNotNull);
        expect(outGetUpdatedGlb.states!, isNotEmpty);

        final updatedGlbTokenState = unmarshalState(
          outGetUpdatedGlb.states!.first.object,
          (json) => TokenState.fromJson(json),
        );

        expect(updatedGlbTokenState.address, equals(tokenAddress));
        expect(updatedGlbTokenState.assetGlbUri, equals(newGlbUri));

        // ------------------
        // REVOKE AUTHORITY
        // ------------------

        // Revoke freeze authority
        final outRevokeFreezeAuthority = await c.revokeFreezeAuthority(
          tokenAddress,
          true,
        );

        expect(outRevokeFreezeAuthority, isA<ContractOutput>());
        expect(outRevokeFreezeAuthority.logs, isNotNull);
        expect(outRevokeFreezeAuthority.logs!, isNotEmpty);

        final revokeFreezeLog = outRevokeFreezeAuthority.logs!.first;
        
        expect(revokeFreezeLog.logType, equals('Token_FreezeAuthorityRevoked'));
        expect(revokeFreezeLog.contractAddress, equals(tokenAddress));

        final revokeFreezeEvent = jsonDecode(
          utf8.decode(base64Decode(revokeFreezeLog.event)),
        ) as Map<String, dynamic>;

        expect(revokeFreezeEvent['address'], equals(tokenAddress));
        expect(revokeFreezeEvent['freeze_authority_revoked'], isTrue);

        final outGetAfterRevokeFreeze = await c.getToken(
          tokenAddress: tokenAddress,
        );

        expect(outGetAfterRevokeFreeze.states, isNotNull);
        expect(outGetAfterRevokeFreeze.states!, isNotEmpty);

        final tokenStateAfterRevokeFreeze = unmarshalState(
          outGetAfterRevokeFreeze.states!.first.object,
          (json) => TokenState.fromJson(json),
        );

        expect(tokenStateAfterRevokeFreeze.address, equals(tokenAddress));
        expect(tokenStateAfterRevokeFreeze.freezeAuthorityRevoked, isTrue);

        // Revoke mint authority
        final outRevokeMintAuthority = await c.revokeMintAuthority(
          tokenAddress,
          true,
        );

        expect(outRevokeMintAuthority, isA<ContractOutput>());
        expect(outRevokeMintAuthority.logs, isNotNull);
        expect(outRevokeMintAuthority.logs!, isNotEmpty);

        final revokeMintLog = outRevokeMintAuthority.logs!.first;
        expect(revokeMintLog.logType, equals('Token_MintAuthorityRevoked'));
        expect(revokeMintLog.contractAddress, equals(tokenAddress));

        final revokeMintEvent = jsonDecode(
          utf8.decode(base64Decode(revokeMintLog.event)),
        ) as Map<String, dynamic>;

        expect(revokeMintEvent['address'], equals(tokenAddress));
        expect(revokeMintEvent['mint_authority_revoked'], isTrue);

        final outGetAfterRevokeMint = await c.getToken(
          tokenAddress: tokenAddress,
        );

        expect(outGetAfterRevokeMint.states, isNotNull);
        expect(outGetAfterRevokeMint.states!, isNotEmpty);

        final tokenStateAfterRevokeMint = unmarshalState(
          outGetAfterRevokeMint.states!.first.object,
          (json) => TokenState.fromJson(json),
        );

        expect(tokenStateAfterRevokeMint.address, equals(tokenAddress));
        expect(tokenStateAfterRevokeMint.mintAuthorityRevoked, isTrue);

        // Revoke update authority
        final outRevokeUpdateAuthority = await c.revokeUpdateAuthority(
          tokenAddress,
          true,
        );

        expect(outRevokeUpdateAuthority, isA<ContractOutput>());
        expect(outRevokeUpdateAuthority.logs, isNotNull);
        expect(outRevokeUpdateAuthority.logs!, isNotEmpty);

        final revokeUpdateLog = outRevokeUpdateAuthority.logs!.first;
        expect(revokeUpdateLog.logType, equals('Token_UpdateAuthorityRevoked'));
        expect(revokeUpdateLog.contractAddress, equals(tokenAddress));

        final revokeUpdateEvent = jsonDecode(
          utf8.decode(base64Decode(revokeUpdateLog.event)),
        ) as Map<String, dynamic>;

        expect(revokeUpdateEvent['address'], equals(tokenAddress));
        expect(revokeUpdateEvent['update_authority_revoked'], isTrue);

        final outGetAfterRevokeUpdate = await c.getToken(
          tokenAddress: tokenAddress,
        );

        expect(outGetAfterRevokeUpdate.states, isNotNull);
        expect(outGetAfterRevokeUpdate.states!, isNotEmpty);

        final tokenStateAfterRevokeUpdate = unmarshalState(
          outGetAfterRevokeUpdate.states!.first.object,
          (json) => TokenState.fromJson(json),
        );

        expect(tokenStateAfterRevokeUpdate.address, equals(tokenAddress));
        expect(tokenStateAfterRevokeUpdate.updateAuthorityRevoked, isTrue);

     });


    
    test('rescaleDecimalString converts amount correctly', () {
      expect(rescaleDecimalString("1", 0, 2), equals("100"));
      expect(rescaleDecimalString("1.5", 2, 2), equals("150"));
      expect(rescaleDecimalString("1.50", 2, 2), equals("150"));
      expect(rescaleDecimalString("0.01", 2, 2), equals("1"));
    });
  });
}
    Map<String, dynamic> _decodeEvent(String eventBase64) {
      return jsonDecode(
        utf8.decode(base64Decode(eventBase64)),
      ) as Map<String, dynamic>;
    }

    Map<String, dynamic> _asMap(dynamic value) {
      if (value == null) return <String, dynamic>{};
      return Map<String, dynamic>.from(value as Map);
    }