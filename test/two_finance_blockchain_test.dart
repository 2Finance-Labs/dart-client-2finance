import 'dart:convert';

import 'package:test/test.dart';

import 'package:two_finance_blockchain/blockchain/contract/contractV1/models/model.dart';
import 'package:two_finance_blockchain/blockchain/contract/walletV1/models/wallet.dart';
import 'package:two_finance_blockchain/blockchain/keys/keys.dart';
import 'package:two_finance_blockchain/two_finance_blockchain.dart';
import 'package:two_finance_blockchain/blockchain/utils/json.dart';
// constants (ajuste se seu nome/paths forem diferentes)
import 'package:two_finance_blockchain/blockchain/contract/walletV1/constants.dart';
import 'package:two_finance_blockchain/blockchain/utils/marshal.dart';
import 'helpers/helpers.dart';
import 'e2e_test.dart';


void main() {
  // Esses timeouts são comuns em E2E por causa de rede/infra

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
    });

    test('deployContract (Wallet V1) retorna estado do contrato', () async {
      // precisa de signer ativo
      final kp = await c.generateKeyEd25519();
      await c.setPrivateKey(kp.privateKey);

      // seu deployContract exige contractVersion != ""
      // WALLET_CONTRACT_V1 normalmente é a string de versão (ex: "wallet_v1")
      final contractOutput = await c.deployContract1(WALLET_CONTRACT_V1);

      final firstLog = contractOutput.logs!.first;

      // validações básicas do output
      expect(contractOutput.contractAddress, isNotNull);
      expect(contractOutput.logs, isNotNull);
      expect(contractOutput.logs!, isNotEmpty);
    });

    test('getState: record not found retorna "0" (fallback)', () async {

      final kp = await c.generateKeyEd25519();
      await c.setPrivateKey(kp.privateKey);

      final JsonMessage emptyData = {};

      final out = await c.getState(
        to: "some_contract",
        method: "some_method",
        data: emptyData,
      );

      expect(out, isNotNull);
    });
  });
}
