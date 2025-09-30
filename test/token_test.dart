// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:two_finance_blockchain/blockchain/contract/contractV1/models/model.dart';
// import 'package:two_finance_blockchain/blockchain/contract/tokenV1/domain/token.dart' as domaintoken;
// import 'package:two_finance_blockchain/blockchain/contract/tokenV1/domain/burn.dart' as domainburn;
// import 'package:two_finance_blockchain/blockchain/contract/tokenV1/domain/mint.dart' as domainmint;
// import 'package:two_finance_blockchain/blockchain/contract/walletV1/domain/transfer.dart';
// import 'package:two_finance_blockchain/two_finance_blockchain.dart';

// import 'e2e_test.dart';
// import 'wallet_test.dart';

// void main() {
//  test('TokenFlow', () async {
//     final c = await setupClient();
//     expect(c, isA<TwoFinanceBlockchain>());
//     await testTokenFlow(c);
//   });

//   test("Create Basic Token", () async {
//     final c = await setupClient();
//     expect(c, isA<TwoFinanceBlockchain>());
//     final (owner, ownerPriv) = await createWallet(c);
//     c.setPrivateKey(ownerPriv);
//     final tok = await createBasicToken(c, owner.publicKey, 6, true);
//     expect(tok.address!.isNotEmpty, true);
//   });
// }



// /*TOKEN TEST FLOW*/
// Future<void> testTokenFlow(TwoFinanceBlockchain c) async {
  
//   // Setup e criação do wallet owner
//   final (owner, ownerPriv) = await createWallet(c);
//   c.setPrivateKey(ownerPriv);

//   // Criar token básico
//   final dec = 6;
//   final tok = await createBasicToken(c, owner.publicKey, dec, true);

//   // Mint & Burn
//   await createMint(c, tok, owner.publicKey, amt(35, dec), dec);
//   await createBurn(c, tok, amt(12, dec), dec);

//   // Transfer para nova wallet permitida
//   final (receiver, _) = await createWallet(c);
//   c.setPrivateKey(ownerPriv);

//   await c.allowUsers(tokenAddress: tok.address!, users: {receiver.publicKey: true});
//   //await c.allowUsers(tok.address, {receiver.publicKey: true}, tokenAddress: tok.address, users: {receiver.publicKey: true});
//   final trOut = await c.transferToken(tokenAddress: tok.address!, transferTo: receiver.publicKey, amount: amt(1, dec), decimals: dec);
//  // final trOut = await c.transferToken(tok.address!, receiver.publicKey, amt(1, dec), dec);
//   final tr = unmarshalState(trOut.states?[0].object, (json) => Transfer.fromJson(json));
//   if (tr.to != receiver.publicKey) {
//     throw Exception("transfer to mismatch: ${tr.to} != ${receiver.publicKey}");
//   }

//   c.setPrivateKey(ownerPriv);

//   // Fee tiers & address
//   await c.updateFeeTiers(tokenAddress: tok.address!, feeTiersList: [{
//       "min_amount": "0",
//       "max_amount": amt(10000, dec),
//       "min_volume": "0",
//       "max_volume": amt(100000, dec),
//       "fee_bps": 25
//     }]);
//   await c.updateFeeAddress(tokenAddress: tok.address!, feeAddress: owner.publicKey);

//   await c.updateMetadata(
//     owner.publicKey,
//     tok.address!,
//     "2F-OLD${randSuffix(4)}",
//     "2Finance Old",
//     dec,
//     "Old description",
//     "https://example.com/old-img.png",
//     "https://old.example.com",
//     {"twitter": "https://x.com/2finance_old"},
//     {"category": "Old"},
//     {"tag": "e2e_old"},
//     "old_creator",
//     "https://old_creator",
//     DateTime.now().add(Duration(days: 15)),
//   );

//   await c.revokeMintAuthority(tokenAddress: tok.address!, revoke: true);
//   await c.revokeUpdateAuthority(tokenAddress: tok.address!, revoke: true);
//   await c.pauseToken(tokenAddress: tok.address!, paused: true);
//   await c.unpauseToken(tokenAddress: tok.address!, paused: false);

//   // Balances / Listings
//   await c.getTokenBalance(tokenAddress: tok.address!, ownerAddress: owner.publicKey);
//   await c.listTokenBalances(tokenAddress: tok.address!, page: 1, limit: 10, ascending: true);
//   c.getToken(tokenAddress: tok.address!, symbol: "", name: "");
//   //await c.getToken(tok.address, "", "");
//   await c.listTokens(ownerAddress: '', symbol: '', name: '', page: 1, limit: 10, ascending: true);
// }


// Future<domaintoken.Token> createBasicToken(
//     TwoFinanceBlockchain c, String ownerPub, int decimals, bool requireFee) async {
//   final symbol = "2F${randSuffix(4)}";
//   final name = "2Finance";
//   final totalSupply = amt(1000000, decimals);
//   final description = "e2e token created by tests";
//   final image = "https://example.com/image.png";
//   final website = "https://example.com";
//   final tagsSocial = {"twitter": "https://twitter.com/2finance"};
//   final tagsCat = {"category": "DeFi"};
//   final tags = {"tag1": "DeFi", "tag2": "Blockchain"};
//   final creator = "2Finance Test";
//   final creatorWebsite = "https://creator.example";
//   final allowUsers = <String, bool>{};
//   final blockUsers = <String, bool>{};
//   var feeTiers = <Map<String, dynamic>>[];
//   if (requireFee) {
//     feeTiers = [
//       {
//         "min_amount": "0",
//         "max_amount": amt(10000, decimals),
//         "min_volume": "0",
//         "max_volume": amt(100000, decimals),
//         "fee_bps": 50
//       }
//     ];
//   }

//   final feeAddress = ownerPub;
//   final freezeAuthorityRevoked = false;
//   final mintAuthorityRevoked = false;
//   final updateAuthorityRevoked = false;
//   final paused = false;
//   final expiredAt = DateTime.now();

//   final deployedContract = await c.deployContract("TOKEN_CONTRACT_V1", "");
//   final contractState = unmarshalState(
//       deployedContract.states?[0].object, (json) => ContractStateModel.fromJson(json));

//   final out = await c.addToken(symbol: symbol, name: name, decimals: decimals, totalSupply: totalSupply, description: description, owner: ownerPub, image: image, website: website, tagsSocialMedia: tagsSocial, tagsCategory: tagsCat, tags: tags, creator: creator, creatorWebsite: creatorWebsite, allowUsers: allowUsers, blockUsers: blockUsers, feeTiersList: feeTiers, feeAddress: feeAddress, expiredAt: expiredAt);
  

//   final tok = unmarshalState(
//       out.states?[0].object, (json) => domaintoken.Token.fromJson(json));

//   if (tok.address == "") throw Exception("token address empty");

//   return tok;
// }

// Future<domainmint.Mint> createMint(
//     TwoFinanceBlockchain c, domaintoken.Token token, String to, String amount, int decimals) async {
//  // final out = await c.MintToken(token.address, to, amount, decimals);
//    final out = await c.mintToken(to: token.address!, mintTo: to, amount: amount, decimals: decimals);
//   final m = unmarshalState(out.states?[0].object, (json) => domainmint.Mint.fromJson(json));
//   if (m.tokenAddress != token.address) throw Exception("mint token mismatch");
//   return m;
// }

// Future<domainburn.Burn> createBurn(
//     TwoFinanceBlockchain c, domaintoken.Token token, String amount, int decimals) async {
//   final out = await c.burnToken(to: token.address!, amount: amount, decimals: decimals);
//   //final out = await c.BurnToken(token.address, amount, decimals);
//   final b = unmarshalState(out.states?[0].object, (json) => domainburn.Burn.fromJson(json));
//   if (b.tokenAddress != token.address) throw Exception("burn token mismatch");
//   return b;
// }

// Future<Transfer> createTransfer(
//     TwoFinanceBlockchain c, domaintoken.Token token, String to, String amount, int decimals) async {
//   //final out = await c.TransferToken(token.address, to, amount, decimals);
//   final out = await c.transferToken(tokenAddress: token.address!, transferTo: to, amount: amount, decimals: decimals);
//   //final tr = unmarshalState(out.states?[0].object, (json) => Transfer(toAddress: json['toAddress'] ?? ''));
//   final tr = unmarshalState(out.states?[0].object, (json) => Transfer.fromJson(json));
//   if (tr.to != to) throw Exception("transfer to mismatch");
//   return tr;
// }

