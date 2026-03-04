import 'dart:convert';

import 'package:two_finance_blockchain/blockchain/contract/contractV1/models/model.dart' as models;
import 'package:two_finance_blockchain/blockchain/contract/contractV1/domain/contract.dart' as domain;
import 'package:two_finance_blockchain/blockchain/contract/walletV1/constants.dart';
import 'package:two_finance_blockchain/blockchain/contract/walletV1/models/wallet.dart' as walletModels;
import 'package:two_finance_blockchain/blockchain/contract/walletV1/domain/wallet.dart' as walletDomain;
import 'package:two_finance_blockchain/blockchain/keys/keys.dart';
import 'package:two_finance_blockchain/blockchain/types/types.dart';
import 'package:two_finance_blockchain/blockchain/utils/json.dart';
import 'package:two_finance_blockchain/two_finance_blockchain.dart';
import 'package:two_finance_blockchain/blockchain/utils/marshal.dart';
import 'package:test/test.dart';
import '../../../helpers/helpers.dart';

void main() async {

    group('TwoFinanceBlockchain E2E - wallet', () {

        late TwoFinanceBlockchain c;

        setUpAll(() async {
            c = await setupClient();
        });

        tearDownAll(() async {
            await teardownClient(c);
        });

        test('generateKeyEd25519 + setPrivateKey deriva publicKeyHex', () async {
            final kp = await validKeyPair();

            // chaves geradas
            expect(kp.privateKey, isNotEmpty);
            expect(kp.publicKey, isNotEmpty);

            await c.setPrivateKey(kp.privateKey);

            // publicKeyHex derivada da private key
            expect(c.publicKeyHex, isNotNull);
            expect(c.publicKeyHex!, isNotEmpty);

            // validação oficial do seu pacote
            KeyManager.validateEDDSAPublicKeyHex(c.publicKeyHex!);

            // e deve bater com a pub gerada pelo helper (se seu validKeyPair for consistente)
            expect(c.publicKeyHex!, equals(kp.publicKey));
        });

        test('E2E: createWallet (deploy + addWallet) + getWallet (roundtrip)', () async {
            // 1) signer
            final kp = await validKeyPair();
            await c.setPrivateKey(kp.privateKey);

            // 2) deploy wallet contract
            final deployedContract = await c.deployContract1(WALLET_CONTRACT_V1);

            final contractLogs = deployedContract.logs;
            expect(contractLogs, isNotNull);
            expect(contractLogs!, isNotEmpty);
            
            // pega o primeiro log
            final firstLog = contractLogs.first;

            // agora decodifica o event (base64 -> bytes) e faz unmarshalEvent
            final deployed = unmarshalEvent<domain.Contract>(
                firstLog.event,
                domain.Contract.fromJson,
            );

            expect(deployed.address, isNotEmpty);
            expect(deployed.contractVersion, equals(WALLET_CONTRACT_V1));
        });
        
    });

}

