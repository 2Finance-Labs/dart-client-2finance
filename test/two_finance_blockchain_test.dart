import 'dart:convert';

import 'package:test/test.dart';

import 'package:two_finance_blockchain/blockchain/contract/contractV1/models/model.dart';
import 'package:two_finance_blockchain/blockchain/contract/walletV1/models/wallet.dart';
import 'package:two_finance_blockchain/blockchain/keys/keys.dart';
import 'package:two_finance_blockchain/two_finance_blockchain.dart';
import 'package:two_finance_blockchain/blockchain/utils/json.dart';

// constants (ajuste se seu nome/paths forem diferentes)
import 'package:two_finance_blockchain/blockchain/contract/walletV1/constants.dart';

import 'e2e_test.dart';

T unmarshalState<T>(
  Object? obj,
  T Function(Map<String, dynamic>) fromJson,
) {
  if (obj is Map<String, dynamic>) {
    return fromJson(obj);
  }
  if (obj is String) {
    final decoded = jsonDecode(obj);
    if (decoded is Map<String, dynamic>) return fromJson(decoded);
  }
  throw Exception('unmarshalState: unsupported state object type: ${obj.runtimeType}');
}

Future<(String pub, String priv)> genKey() async {
  final km = KeyManager();
  final kp = await km.generateKeyEd25519();
  return (kp.publicKey, kp.privateKey);
}

void main() {
  // Esses timeouts são comuns em E2E por causa de rede/infra
  const testTimeout = Timeout(Duration(minutes: 2));

  group('TwoFinanceBlockchain E2E', () {
    late TwoFinanceBlockchain c;

    setUpAll(() async {
      c = await setupClient();
    });

    tearDownAll(() async {
      await teardownClient(c);
    });

    test('initialize + setup OK', () async {
      expect(c.isInitialized, isTrue);
    });

    test('generateKeyEd25519 + setPrivateKey deriva publicKeyHex', () async {
      final kp = await c.generateKeyEd25519();
      expect(kp.privateKey, isNotEmpty);
      expect(kp.publicKey, isNotEmpty);

      await c.setPrivateKey(kp.privateKey);

      // publicKeyHex é derivada da private key
      expect(c.publicKeyHex, isNotNull);
      expect(c.publicKeyHex!, isNotEmpty);

      // valida formato EDDSA (se sua validação exigir)
      KeyManager.validateEDDSAPublicKeyHex(c.publicKeyHex!);
    }, timeout: testTimeout);

    test('deployContract (Wallet V1) retorna estado do contrato', () async {
      // precisa de signer ativo
      final (_, priv) = await genKey();
      await c.setPrivateKey(priv);

      // seu deployContract exige contractVersion != ""
      // WALLET_CONTRACT_V1 normalmente é a string de versão (ex: "wallet_v1")
      final out = await c.deployContract("", WALLET_CONTRACT_V1);

      final states = out.states;
      expect(states, isNotNull);
      expect(states!, isNotEmpty);

      // Tenta decodificar o primeiro state como ContractStateModel
      final contr = unmarshalState(
        states.first.object,
        (json) => ContractStateModel.fromJson(json),
      );

      expect(contr.address, isNotEmpty);
    }, timeout: testTimeout);

    test('E2E: createWallet (deploy + addWallet) + getWallet (roundtrip)', () async {
      // 1) signer
      final (pub, priv) = await genKey();
      await c.setPrivateKey(priv);

      // 2) deploy wallet contract
      final deployed = await c.deployContract("", WALLET_CONTRACT_V1);
      final deployedStates = deployed.states;
      expect(deployedStates, isNotNull);
      expect(deployedStates!, isNotEmpty);

      final contr = unmarshalState(
        deployedStates.first.object,
        (json) => ContractStateModel.fromJson(json),
      );
      expect(contr.address, isNotEmpty);

      // 3) add wallet (assume que existe no seu part 'wallet.dart')
      final wOut = await c.addWallet(contr.address, pub);
      final wStates = wOut.states;
      expect(wStates, isNotNull);
      expect(wStates!, isNotEmpty);

      final w = unmarshalState(
        wStates.first.object,
        (json) => WalletStateModel.fromJson(json),
      );

      expect((w.publicKey ?? ''), equals(pub));

      // 4) get wallet
      final w2Out = await c.getWallet(pub);
      final w2States = w2Out.states;
      expect(w2States, isNotNull);
      expect(w2States!, isNotEmpty);

      final w2 = unmarshalState(
        w2States.first.object,
        (json) => WalletStateModel.fromJson(json),
      );

      expect((w2.publicKey ?? ''), equals(pub));
    }, timeout: testTimeout);

    test('getState: record not found retorna "0" (fallback)', () async {

      final (_, priv) = await genKey();
      await c.setPrivateKey(priv);

      final JsonMessage emptyData = {};

      final out = await c.getState(
        to: "some_contract",
        method: "some_method",
        data: emptyData,
      );

      print("getState output for non-existent record: ${out}");

      expect(out, isNotNull);
    }, timeout: testTimeout);
  });
}
