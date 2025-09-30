import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:two_finance_blockchain/blockchain/contract/contractV1/models/model.dart';
import 'package:two_finance_blockchain/blockchain/contract/walletV1/constants.dart';
import 'package:two_finance_blockchain/blockchain/keys/keys.dart';
import 'package:two_finance_blockchain/blockchain/types/types.dart';
import 'package:two_finance_blockchain/models/wallet.dart';
import 'package:two_finance_blockchain/models/wallet.dart' as domainwallet;
import 'package:two_finance_blockchain/two_finance_blockchain.dart';

import 'e2e_test.dart';

void main() {
  

 test("Teste genKey", () async {
    final keyManager = KeyManager();
    final (pub, priv) = await genKey(keyManager);
    expect(pub.isNotEmpty, true);
    expect(priv.isNotEmpty, true);
  });
 test("Teste createWallet", () async {  
    final c = await setupClient();
    expect(c, isA<TwoFinanceBlockchain>());
    
    final (w, priv) = await createWallet(c);
    expect(w.publicKey.isNotEmpty, true);
    expect(priv.isNotEmpty, true);
  });



  // Add wallet tests here
}

Future<(domainwallet.Wallet, String)> createWallet(TwoFinanceBlockchain c) async {
  // Gera par de chaves
  final (pub, priv) = await genKey(KeyManager());
  await c.setPrivateKey(priv);
  
  final contrModel = ContractStateModel(address: pub, contractVersion: WALLET_CONTRACT_V1, createdAt: DateTime.now());
  
  // Deploy do contrato
  final deployedContract = await c.deployContract(WALLET_CONTRACT_V1, "");
  if (deployedContract.states == null) {
    throw Exception("DeployContract failed: no states returned");
  }

  // Desserializa o estado do contrato
  unmarshalState(
    deployedContract.states![0].object,
    (json) => ContractStateModel.fromJson(json),
  );
  unmarshalState(contrModel, (json) => ContractStateModel.fromJson(json));

  // Adiciona a wallet
  final wOut = await c.addWallet(contrModel.address, pub);
  if (wOut.states == null || wOut.states!.isEmpty) {
    throw Exception("AddWallet failed: no states returned");
  }

  final w = unmarshalState(
    wOut.states![0].object,
    (json) => domainwallet.Wallet.fromJson(json),
  );

  if (w.publicKey.isEmpty) {
    throw Exception("wallet public key empty");
  }

  return (w, priv);
}

