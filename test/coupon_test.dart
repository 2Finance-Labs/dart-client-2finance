import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_finance_blockchain/blockchain/contract/contractV1/models/model.dart';
import 'package:two_finance_blockchain/blockchain/contract/couponsV1/constants.dart';
import 'package:two_finance_blockchain/blockchain/contract/couponsV1/models/coupons.dart';
import 'package:two_finance_blockchain/blockchain/keys/keys.dart';
import 'package:two_finance_blockchain/two_finance_blockchain.dart';

import 'e2e_test.dart';
import 'token_test.dart';
import 'wallet_test.dart';

String amt(int human, int decimals) {
  final factor = BigInt.from(10).pow(decimals);
  return (BigInt.from(human) * factor).toString();
}

void main() async {

  //final c = await setupClient();

   test("Teste genKey", () async {
    final keyManager = KeyManager();
    final (pub, priv) = await genKey(keyManager);
    expect(pub.isNotEmpty, true);
    expect(priv.isNotEmpty, true);
  });
  test("Teste CouponFlow", () async {
    await testCouponFlow();
  });
}

Future<void> testCouponFlow() async {
  final c = await setupClient();

  // cria o dono e chave privada
  final (owner, ownerPriv) = await createWallet(c);
  c.setPrivateKey(ownerPriv);

  final dec = 6;
  final (tok, _, _) = await createToken(c); // ajusta de acordo com seu createToken

  // datas
  final start = DateTime.now().add(const Duration(seconds: 2));
  final exp = DateTime.now().add(const Duration(minutes: 25));

  // passcode hash
  final raw = sha256.convert(utf8.encode("e2e-passcode"));
  final pcHash = raw.toString();

  // deploy do contrato
  final deployedContract = await c.deployContract(COUPON_CONTRACT_V1, "");
  final contractState = unmarshalState(
    deployedContract.states![0].object,
    (json) => ContractStateModel.fromJson(json),
  );
  final address = contractState.address;

  // cria o cupom
  final out = await c.addCoupon(
    address,
    tok.address!,
    DISCOUNT_TYPE_PERCENTAGE,
    "1000",
    "",
    "",
    start,
    exp,
    false,
    true,
    100,
    5,
    pcHash,
  );

  final cp = unmarshalState(
    out.states![0].object,
    (json) => CouponStateModel.fromJson(json),
  );

  expect(cp.address.isNotEmpty, true);

  // permite cupom gastar
  await c.allowUsers(tokenAddress: tok.address!, users: {cp.address:true});

  // atualiza cupom para valor fixo
  final start2 = DateTime.now().add(const Duration(seconds: 1));
  final exp2 = DateTime.now().add(const Duration(minutes: 10));
  final raw2 = sha256.convert(utf8.encode("e2e-passcode-2"));
  final pcHash2 = raw2.toString();

  await c.updateCoupon(
    cp.address,
    tok.address!,
    DISCOUNT_TYPE_FIXED,
    "",
    amt(2, dec),
    amt(10, dec),
    start2,
    exp2,
    false,
    10,
    2,
    pcHash2,
  );

  // aguarda para resgatar
  await Future.delayed(const Duration(seconds: 20));
  try {
    await c.redeemCoupon(cp.address, amt(20, dec), "e2e-passcode-2");
  } catch (e) {
    print("RedeemCoupon warning: $e");
  }

  // pause/unpause & getters
  await c.pauseCoupon(cp.address, true);
  await c.unpauseCoupon(cp.address, false);

  await c.getCoupon(cp.address);
  await c.listCoupons("", tok.address!, "", null, 1, 10, true);
}

// import 'dart:async';
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:crypto/crypto.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:two_finance_blockchain/blockchain/contract/contractV1/models/model.dart';
// import 'package:two_finance_blockchain/blockchain/contract/couponsV1/models/coupons.dart';
// import 'package:two_finance_blockchain/two_finance_blockchain.dart';
// import 'package:two_finance_blockchain/blockchain/contract/contractV1/models.dart';
// import 'package:two_finance_blockchain/blockchain/contract/couponV1/domain/coupon.dart';

// import 'e2e_test.dart';
// import 'token_test.dart';
// import 'wallet_test.dart';


// void main() {
//   test("Teste CouponFlow", () async {
//     await testCouponFlow();
//   });
// }

// Future<void> testCouponFlow() async {
//   final c = await setupClient();

//   // cria o dono e chave privada
//   final (owner, ownerPriv) = await createWallet(c);
//   c.setPrivateKey(ownerPriv);

//   final dec = 6;
//   final tok = await createToken(c);
//   expect(actual, matcher)

//   // datas
//   final start = DateTime.now().add(const Duration(seconds: 2));
//   final exp = DateTime.now().add(const Duration(minutes: 25));

//   // passcode hash
//   final raw = sha256.convert(utf8.encode("e2e-passcode"));
//   final pcHash = raw.toString();

//   // deploy do contrato
//   final deployedContract = await c.deployContract("COUPON_CONTRACT_V1", "");
//   final contractState = unmarshalState(
//     deployedContract.states![0].object,
//     (json) => ContractStateModel.fromJson(json),
//   );
//   final address = contractState.address;

//   // cria o cupom
//   final out = await c.addCoupon(
//     address,
//     tok.address,
//     "PERCENTAGE", // couponV1Domain.DISCOUNT_TYPE_PERCENTAGE
//     "1000",
//     "",
//     "",
//     start,
//     exp,
//     false,
//     true,
//     100,
//     5,
//     pcHash,
//   );

//   final cp = unmarshalState(
//     out.states![0].object,
//     (json) => CouponStateModel.fromJson(json),
//   );

//   if (cp.address.isEmpty) {
//     throw Exception("coupon addr empty");
//   }

//   // permite cupom gastar
//   await c.allowUsers(tok.address, {cp.address: true});

//   // atualiza cupom para valor fixo
//   final start2 = DateTime.now().add(const Duration(seconds: 1));
//   final exp2 = DateTime.now().add(const Duration(minutes: 10));
//   final raw2 = sha256.convert(utf8.encode("e2e-passcode-2"));
//   final pcHash2 = raw2.toString();

//   await c.UpdateCoupon(cp.address, tok, programType, percentageBPS, fixedAmount, minOrder, startAt, expiredAt, stackable, maxRedemptions, perUserLimit, passcodeHash)
//   // updateCoupon(
//   //   cp.address,
//   //   tok.address,
//   //   "FIXED", // couponV1Domain.DISCOUNT_TYPE_FIXED
//   //   "",
//   //   amt(2, dec),
//   //   amt(10, dec),
//   //   start2,
//   //   exp2,
//   //   false,
//   //   10,
//   //   2,
//   //   pcHash2,
//   // );

//   // aguarda para resgatar
//   await Future.delayed(const Duration(seconds: 20));
//   try {
//     await c.redeemCoupon(cp.address, amt(20, dec), "e2e-passcode-2");
//   } catch (e) {
//     print("RedeemCoupon warning: $e");
//   }

//   // pause/unpause & getters
//   await c.pauseCoupon(cp.address, true);
//   await c.unpauseCoupon(cp.address, false);

//   await c.getCoupon(cp.address);
//   await c.listCoupons("", tok.address, "", null, 1, 10, true);
// }
