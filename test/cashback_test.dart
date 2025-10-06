// import 'dart:async';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:two_finance_blockchain/blockchain/contract/cashbackV1/constants.dart';
// import 'package:two_finance_blockchain/blockchain/contract/contractV1/models/model.dart';
// import 'package:two_finance_blockchain/blockchain/contract/tokenV1/models/token.dart';

// import 'package:two_finance_blockchain/blockchain/contract/walletV1/models/wallet.dart';
// import 'package:two_finance_blockchain/blockchain/contract/contractV1/models/contract_state.dart';
// import 'package:two_finance_blockchain/blockchain/contract/cashbackV1/domain/cashback.dart';
// import 'package:two_finance_blockchain/blockchain/keys/keys.dart';
// import 'package:two_finance_blockchain/two_finance_blockchain.dart';

// import 'e2e_test.dart';
// import 'token_test.dart';
// import 'wallet_test.dart';

// void main() {
//   test('Cashback Flow', () async {
//     await testCashbackFlow();
//   });
// }

// Future<void> testCashbackFlow() async {
//   final c = await setupClient();

//   // Criar owner
//   final (owner, ownerPriv) = await createWallet(c);
//   await c.setPrivateKey(ownerPriv);

//   final dec = 1;
//   final tok = await createToken(c);
//   await createMint(c, tok, owner.publicKey, "10000", dec);

//   // Criar merchant
//   final (merchant, _) = await createWallet(c);

//   await c.setPrivateKey(ownerPriv);
//   //await createTransfer(c, tok, merchant.publicKey, "50", dec);

//   final start = DateTime.now().add(const Duration(seconds: 2));
//   final exp = DateTime.now().add(const Duration(minutes: 30));

//   // Deploy cashback contract
//   final contractState = ContractStateModel(address: "", contractVersion: CASHBACK_CONTRACT_V1, createdAt: start);
//   final deployedContract =
//       await c.deployContract(CASHBACK_CONTRACT_V1, "");
//   // if (deployedContract == null) {
//   //   fail("DeployContract failed");
//   // }
//   unmarshalState(deployedContract.states?[0].object, contractState as Function(Map<String, dynamic> p1));
//   final address = contractState.address;

//   // Adicionar cashback
//   final out = await c.addCashback(address: address, owner: owner, tokenAddress: tokenAddress, programType: programType, percentage: percentage, startAt: startAt, expiredAt: expiredAt, paused: paused)

//   final cb = Cashback();
//   unmarshalState(out.states?[0].object, cb);

//   // Allow / Deposit / Update / Pause / Unpause
//   await c.allowUsers(tokenAddress: tok.$1.address!, users: {cb.address: true});
//   await c.depositCashbackFunds(cb.address, tok.$1.address!, amt(1000, dec));
//   await c.updateCashback();
//   await c.pauseCashback(cb.address, true);
//   await c.unpauseCashback(cb.address, false);

//   await Future.delayed(const Duration(seconds: 2));

//   // Claim as user
//   final (user, userPriv) = await createWallet(c);
//   await c.setPrivateKey(ownerPriv);
//   await c.allowUsers(tokenAddress: tok.address, users: {user.publicKey: true});

//   await c.setPrivateKey(userPriv);
//   try {
//     await c.claimCashback(cb.address, amt(100, dec));
//   } catch (e) {
//     print("ClaimCashback warning: $e");
//   }

//   // Getters
//   await c.getCashback(cb.address);
//   await c.listCashbacks(
//     merchant.publicKey,
//     tok.address,
//     "",
//     false,
//     1,
//     10,
//     true,
//   );
// }

// // // ---- Funções auxiliares ----

// Future<(WalletStateModel, String)> createWallet(TwoFinanceBlockchain c) async {
//   final (pub, priv) = await genKey(KeyManager());
//   await c.setPrivateKey(priv);
//   return (WalletStateModel(publicKey: pub, amount: ''), priv);
// }

// Future<TokenStateModel> createBasicToken(
//     TwoFinanceBlockchain c, String owner, int dec, bool pausable) async {
//   // Simulação de criação de token
//   return TokenStateModel(address: "token_address", decimals: dec);
// }

// Future<void> createMint(
//     TwoFinanceBlockchain c, TokenStateModel token, String owner, String amount, int dec) async {
//   // Chamada para mint no client
//   await c.mint(token.address, owner, amount);
// }

// Future<void> createTransfer(
//     TwoFinanceBlockchain c, TokenStateModel token, String to, String amount, int dec) async {
//   // Chamada para transfer no client
//   await c.transfer(token.address, to, amount);
// }

// String amt(int value, int decimals) {
//   // Converte para unidade mínima do token
//   return (value * (10 ^ decimals)).toString();
// }

// void unmarshalState(dynamic src, dynamic dst) {
//   // Converte JSON para modelo
//   dst.fromJson(src);
// }




// // import 'package:two_finance_blockchain/blockchain/contract/walletV1/models/wallet.dart';
// // import 'package:two_finance_blockchain/blockchain/keys/keys.dart';
// // import 'package:two_finance_blockchain/two_finance_blockchain.dart';

// // import 'e2e_test.dart';
// // import 'token_test.dart';

// // void main() {
// //   final c = await setupClient();
// // }

// // Future<(WalletStateModel, String)> testCashbackFlow(TwoFinanceBlockchain c) async {
// //   final (pub, priv) = await genKey(KeyManager());
// //   await c.setPrivateKey(priv);
// //   final dec = 1;
// //   final tok = createToken(c);
// //    c.addCashback(owner: '', tokenAddress: '', programType: '', percentage: '', startAt: null, expiredAt: null, paused: null);
// //   c.allowUsers(tokenAddress: '', users: {}, label: '');
// //   c.depositCashbackFunds(address: '', tokenAddress: '', amount: '');
// //   return (Wallet(), '');
// // }