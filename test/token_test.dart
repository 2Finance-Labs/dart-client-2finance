import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:two_finance_blockchain/blockchain/keys/keys.dart';
import 'package:two_finance_blockchain/two_finance_blockchain.dart';
import 'package:two_finance_blockchain/blockchain/contract/tokenV1/constants.dart';
// ajuste este import conforme seu projeto:
import 'package:two_finance_blockchain/blockchain/contract/tokenV1/models/token.dart';
import 'package:two_finance_blockchain/blockchain/contract/contractV1/models/model.dart';
import 'package:two_finance_blockchain/blockchain/utils/decimals.dart';
import 'package:two_finance_blockchain/blockchain/contract/tokenV1/models/balance.dart';

import 'e2e_test.dart';


void main() async {
  final c = await setupClient();

    test('Test createToken', () async {
        final (tkn, priv, pub) = await createToken(c);
        expect(tkn.address?.isNotEmpty, true);
        expect(priv.isNotEmpty, true);

        // opcional: buscar o token por address para confirmar persistência
        final got = await c.getToken(tokenAddress: tkn.address ?? '');
        final st = got.states;
        expect(st != null && st.isNotEmpty, true);

        final t2 = unmarshalState(
            st![0].object,
            (json) => TokenStateModel.fromJson(json),
        );
        expect(t2.address, tkn.address);
        expect(t2.symbol, tkn.symbol);
    });

    test('Token flow (mint → balance → transfer → burn → metadata/acl → pause/unpause → fees → revoke* → list)', () async {
        // ========== setup ==========
        final (tkn, ownerPriv, ownerPub) = await createToken(c);
        final tokenAddr = tkn.address ?? '';
        final decimals = tkn.decimals ?? 6;

        // userA (vai receber mint e depois transferir/burn)
        final (userAPub, userAPriv) = await genKey(KeyManager());
        // userB (vai receber via transfer)
        final (userBPub, userBPriv) = await genKey(KeyManager());

        expect([tokenAddr, ownerPriv, ownerPub, userAPub, userAPriv, userBPub, userBPriv]
            .every((e) => e.isNotEmpty), true);

        // ========== mint by owner ==========
        await c.setPrivateKey(ownerPriv);

        // vamos mintar 10 tokens para o userA (human "10" vira base 10*10^decimals)
        const amountMint = '10';

        final mintOut = await c.mintToken(
            tokenAddress: tokenAddr,
            mintTo: userAPub,
            amount: amountMint,
            decimals: decimals,
        );
        expect(mintOut.states != null && mintOut.states!.isNotEmpty, true);

        // ========== balance userA ==========
        final balA1Out = await c.getTokenBalance(
            tokenAddress: tokenAddr,
            ownerAddress: userAPub,
        );
        final balA1 = unmarshalState(
            balA1Out.states![0].object,
            (json) => BalanceStateModel.fromJson(json),
        );

        String toBase(String human) =>
            DecimalRescaler.rescaleString(human, 0, decimals);

        // mint amount (human -> base)
        final mintBase = toBase(amountMint);

        expect(balA1.amount, mintBase); // 10 com 6 decimais = 10000000 em base

        // ========== transfer (userA -> userB) ==========
        await c.setPrivateKey(userAPriv);
        const transferAmount = '3';

        final txOut = await c.transferToken(
            tokenAddress: tokenAddr,
            transferTo: userBPub,
            amount: transferAmount,
            decimals: decimals,
        );
        expect(txOut.states != null && txOut.states!.isNotEmpty, true);

        // Apos transfer: A = 10-3, B = 3
        final expectedAAfterTransfer =
            (BigInt.parse(amountMint) - BigInt.parse(transferAmount)).toString();
        final balA2 = unmarshalState(
        (await c.getTokenBalance(tokenAddress: tokenAddr, ownerAddress: userAPub))
            .states![0]
            .object,
        (json) => BalanceStateModel.fromJson(json),
        );
        expect(balA2.amount, expectedAAfterTransfer + '000000'); // em base

        final balB1 = unmarshalState(
        (await c.getTokenBalance(tokenAddress: tokenAddr, ownerAddress: userBPub))
            .states![0]
            .object,
        (json) => BalanceStateModel.fromJson(json),
        );
        //OBS IT HAS FEES OF 0.25% ON TRANSFER
        expect(balB1.amount, "2992500"); // em base

        // ========== burn (userB queimar 2) ==========
        await c.setPrivateKey(userBPriv);
        const burnAmount = '2';

        // se renomeou o parâmetro p/ tokenAddress, ajuste aqui:
        final burnOut = await c.burnToken(
            tokenAddress: tokenAddr, // <- se renomeou: tokenAddress: tokenAddr,
            amount: burnAmount,
            decimals: decimals,
        );
        expect(burnOut.states != null && burnOut.states!.isNotEmpty, true);
        final transferBase = toBase(transferAmount);
        final burnBase = toBase(burnAmount);
        final expectedBAfterBurn =
            (BigInt.parse(transferBase) - BigInt.parse(burnBase)).toString();
        final balB2 = unmarshalState(
        (await c.getTokenBalance(tokenAddress: tokenAddr, ownerAddress: userBPub))
            .states![0]
            .object,
        (json) => BalanceStateModel.fromJson(json),
        );
        expect(balB2.amount, "992500");

        // A deveria continuar 7 tokens
        final balA3 = unmarshalState(
        (await c.getTokenBalance(tokenAddress: tokenAddr, ownerAddress: userAPub))
            .states![0]
            .object,
        (json) => BalanceStateModel.fromJson(json),
        );
        expect(balA3.amount, expectedAAfterTransfer + '000000'); // em base
        
        // ========== update metadata (owner) ==========
        await c.setPrivateKey(ownerPriv);
        final updOut = await c.updateMetadata(
            ownerPub,
            tokenAddr,
            tkn.symbol! + ' v2',
            'Test Token v2',
            decimals,
            'Desc atualizada',
            'https://example.com/img2.png',
            'https://example.com/v2',
            {'twitter': 'https://x.com/2finance'},
            {'vertical': 'loyalty'},
            {'env': 'tests', 'suite': 'e2e'},
            '2Finance QA v2',
            'https://2finance.io/v2',
            DateTime.now().toUtc().add(const Duration(days: 365)),
        );
        expect(updOut.states != null && updOut.states!.isNotEmpty, true);

        // ========== ACL: allow / disallow / unblock ==========
        final allowOut = await c.allowUsers(
            tokenAddress: tokenAddr,
            users: {userAPub: true},
        );
        expect(allowOut.states != null && allowOut.states!.isNotEmpty, true);

        final disallowOut = await c.disallowUsers(
        tokenAddress: tokenAddr,
        users: {userAPub: true},
        );
        expect(disallowOut.states != null && disallowOut.states!.isNotEmpty, true);

        final blockOut = await c.blockUsers(
        tokenAddress: tokenAddr,
        users: {userBPub: true},
        );
        expect(blockOut.states != null && blockOut.states!.isNotEmpty, true);

        final unblockOut = await c.unblockUsers(
        tokenAddress: tokenAddr,
        users: {userBPub: true},
        );
        expect(unblockOut.states != null && unblockOut.states!.isNotEmpty, true);

        // ========== pause / unpause ==========
        final pauseOut = await c.pauseToken(tokenAddress: tokenAddr, paused: true);
        expect(pauseOut.states != null && pauseOut.states!.isNotEmpty, true);

        final unpauseOut = await c.unpauseToken(tokenAddress: tokenAddr, paused: false);
        expect(unpauseOut.states != null && unpauseOut.states!.isNotEmpty, true);

        // ========== fees: update address / tiers ==========
        final feeAddr2 = ownerPub; // pode ser outro pub, se quiser
        final feeAddrOut = await c.updateFeeAddress(
            tokenAddress: tokenAddr,
            feeAddress: feeAddr2,
        );
        expect(feeAddrOut.states != null && feeAddrOut.states!.isNotEmpty, true);

        final feeTiersList = <Map<String, dynamic>>[
            {
            'fee_bps': 25, // 0.25%
            'max_amount': '100000000', // 100k em base-0; contrato pode normalizar
            "max_volume": '1000000000', // 1M em base-0; contrato pode normalizar
            'min_amount': '0',
            'min_volume': '0',
            },
        ];
        // TODO FIX
        // final tiersOut = await c.updateFeeTiers(
        //     tokenAddress: tokenAddr,
        //     feeTiersList: feeTiersList,
        // );
        // expect(tiersOut.states != null && tiersOut.states!.isNotEmpty, true);

        // ========== revoke authorities ==========
        final revokeFreeze = await c.revokeFreezeAuthority(
            tokenAddress: tokenAddr,
            revoke: true,
        );
        expect(revokeFreeze.states != null && revokeFreeze.states!.isNotEmpty, true);

        final revokeUpdate = await c.revokeUpdateAuthority(
            tokenAddress: tokenAddr,
            revoke: true,
        );
        expect(revokeUpdate.states != null && revokeUpdate.states!.isNotEmpty, true);

        final revokeMint = await c.revokeMintAuthority(
            tokenAddress: tokenAddr,
            revoke: true,
        );
        expect(revokeMint.states != null && revokeMint.states!.isNotEmpty, true);

        // ========== get / list ==========
        final getOut = await c.getToken(tokenAddress: tokenAddr);
        expect(getOut.states != null && getOut.states!.isNotEmpty, true);

        //TOOD FIX
        // final listOut = await c.listTokens(ownerAddress: ownerPub, page: 1, limit: 10);
        // expect(listOut.states != null && listOut.states!.isNotEmpty, true);

        // balances finais: A=7, B=1 (em base)
        final expectedAFinal = (BigInt.parse(expectedAAfterTransfer)).toString(); // 7 tokens
        final expectedBFinal = (BigInt.parse(expectedBAfterBurn)).toString();     // 1 token

        final balAFinal = unmarshalState(
        (await c.getTokenBalance(tokenAddress: tokenAddr, ownerAddress: userAPub))
            .states![0]
            .object,
        (json) => BalanceStateModel.fromJson(json),
        );
        final balBFinal = unmarshalState(
        (await c.getTokenBalance(tokenAddress: tokenAddr, ownerAddress: userBPub))
            .states![0]
            .object,
        (json) => BalanceStateModel.fromJson(json),
        );

        // como expected* já estão em base, só comparar:
        expect(balAFinal.amount, '7000000');
        expect(balBFinal.amount, '992500');

        // opcional: listar balances
        //TODO FIX
        // final listBalByToken =
        //     await c.listTokenBalances(tokenAddress: tokenAddr, page: 1, limit: 50);
        // expect(listBalByToken.states != null && listBalByToken.states!.isNotEmpty, true);
    });


}

/// Cria um token completo e retorna (estadoDoToken, privateKeyDoDono).
Future<(TokenStateModel, String, String)> createToken(TwoFinanceBlockchain c) async {
  // 1) Gera chaves do "owner" e configura o signer
  final (ownerPub, ownerPriv) = await genKey(KeyManager());
  await c.setPrivateKey(ownerPriv);

  // 2) Deploy contract
  final deployed = await c.deployContract(TOKEN_CONTRACT_V1, "");
  final states = deployed.states;
  if (states == null || states.isEmpty) {
    throw Exception("DeployContract failed: no states returned");
  }

  // 3) Decode contract state and keep it in a variable
  final contrModel = unmarshalState(
    states[0].object,
    (json) => ContractStateModel.fromJson(json),
  );
  if (contrModel.address.isEmpty) {
    throw Exception("DeployContract failed: empty contract address in state");
  }


  final address = contrModel.address!;
  // Você pode usar o mesmo endereço como feeAddress para testes
  final feeAddress = ownerPub;
 
  // 2) Monta dados mínimos válidos
  final suffix = randSuffix(6); // só pra garantir aleatoriedade
  final symbol = 'TST' + suffix; // símbolo único para testes
  final name = 'Test Token';
  final decimals = 6;
  final totalSupply = '1000000'; // 1,000,000 (antes de aplicar decimals)
  final description = 'Token de teste gerado pelos testes automatizados';
  final image = 'https://example.com/token.png';
  final website = 'https://example.com';
  final creator = '2Finance QA';
  final creatorWebsite = 'https://2finance.io';

  final tagsSocialMedia = <String, String>{
    'instagram': 'https://instagram.com/2finance',
    'twitter': 'https://x.com/2finance',
  };

  final tagsCategory = <String, String>{
    'region': 'BR',
    'vertical': 'loyalty',
  };

  final tags = <String, String>{
    'env': 'tests',
    'suite': 'e2e',
  };

  // autorizações/bloqueios iniciais — vazios para testes simples
  final allowUsers = <String, bool>{};
  final blockUsers = <String, bool>{};

  // exemplo simples de tier de fee (ajuste conforme seu contrato espera)
  final feeTiersList = <Map<String, dynamic>>[
    {
      'fee_bps': 25, // 0.25%
      'max_amount': '100000000', // 100k em base-0; contrato pode normalizar
      "max_volume": '1000000000', // 1M em base-0; contrato pode normalizar
      'min_amount': '0',
      'min_volume': '0',
    },
  ];

  final expiredAt = DateTime.now().toUtc().add(const Duration(days: 365));

  // 3) Chama o método que faz o "deploy" do token (via DEPLOY_CONTRACT_ADDRESS)
  final out = await c.addToken(
    address: address,
    symbol: symbol,
    name: name,
    decimals: decimals,
    totalSupply: totalSupply,
    description: description,
    owner: ownerPub,
    image: image,
    website: website,
    tagsSocialMedia: tagsSocialMedia,
    tagsCategory: tagsCategory,
    tags: tags,
    creator: creator,
    creatorWebsite: creatorWebsite,
    allowUsers: allowUsers,
    blockUsers: blockUsers,
    feeTiersList: feeTiersList,
    feeAddress: feeAddress,
    freezeAuthorityRevoked: false,
    mintAuthorityRevoked: false,
    updateAuthorityRevoked: false,
    paused: false,
    expiredAt: expiredAt,
  );

  final statesAdded = out.states;
  if (statesAdded == null || statesAdded.isEmpty) {
    throw Exception('AddToken failed: no states returned');
  }

  // 4) Desserializa o primeiro estado como TokenStateModel
  final token = unmarshalState(
    statesAdded[0].object,
    (json) => TokenStateModel.fromJson(json),
  );

  // Validações básicas — ajuste conforme os campos do seu modelo
  if ((token.address ?? '').isEmpty) {
    throw Exception('Token address vazio');
  }
  if ((token.symbol ?? '').isEmpty) {
    throw Exception('Token symbol vazio');
  }

  return (token, ownerPriv, ownerPub);
}
