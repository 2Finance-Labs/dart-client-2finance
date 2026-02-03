import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:two_finance_blockchain/blockchain/contract/contractV1/models/model.dart';
import 'package:two_finance_blockchain/blockchain/contract/walletV1/constants.dart';
import 'package:two_finance_blockchain/blockchain/contract/walletV1/models/wallet.dart';
import 'package:two_finance_blockchain/blockchain/keys/keys.dart';
import 'package:two_finance_blockchain/blockchain/types/types.dart';
import 'package:two_finance_blockchain/two_finance_blockchain.dart';

import 'e2e_test.dart';

void main() async {

//  final c = await setupClient();

//  test("Teste genKey", () async {
//     final keyManager = KeyManager();
//     final (pub, priv) = await genKey(keyManager);
//     expect(pub.isNotEmpty, true);
//     expect(priv.isNotEmpty, true);
//   });
//  test("Teste createWallet", () async {  
//     expect(c, isA<TwoFinanceBlockchain>());
    
//     final (w, priv) = await createWallet(c);
//     expect(w.publicKey.isNotEmpty, true);
//     expect(priv.isNotEmpty, true);
//   });

//   test("Test get wallet", () async {
//     expect(c, isA<TwoFinanceBlockchain>());

//     final (w, priv) = await createWallet(c);
//     expect(w.publicKey.isNotEmpty, true);
//     expect(priv.isNotEmpty, true);

//     final w2Out = await c.getWallet(w.publicKey ?? '');
//     final w2States = w2Out.states;
//     if (w2States == null || w2States.isEmpty) {
//       throw Exception("GetWallet failed: no states returned");
//     }

//     // Decode wallet domain state
//     final w2 = unmarshalState(
//       w2States[0].object,
//       (json) => WalletStateModel.fromJson(json),
//     );
//     expect(w2.publicKey, w.publicKey);
//   });


//   // Add wallet tests here
// }

// Future<(WalletStateModel, String)> createWallet(TwoFinanceBlockchain c) async {
//   // 1) Generate keys & set signer
//   final (pub, priv) = await genKey(KeyManager());
//   await c.setPrivateKey(priv);

//   // 2) Deploy contract
//   final deployed = await c.deployContract(WALLET_CONTRACT_V1, "");
//   final states = deployed.states;
//   if (states == null || states.isEmpty) {
//     throw Exception("DeployContract failed: no states returned");
//   }

//   // 3) Decode contract state and keep it in a variable
//   final contrModel = unmarshalState(
//     states[0].object,
//     (json) => ContractStateModel.fromJson(json),
//   );
//   if (contrModel.address.isEmpty) {
//     throw Exception("DeployContract failed: empty contract address in state");
//   }

//   // 4) Add wallet to that deployed contract
//   final wOut = await c.addWallet(contrModel.address, pub);
//   final wStates = wOut.states;
//   if (wStates == null || wStates.isEmpty) {
//     throw Exception("AddWallet failed: no states returned");
//   }

//   // 5) Decode wallet domain state
//   final w = unmarshalState(
//     wStates[0].object,
//     (json) => WalletStateModel.fromJson(json),
//   );

//   if ((w.publicKey ?? '').isEmpty) {
//     throw Exception("Wallet public key is empty");
//   }

//   return (w, priv);
}

