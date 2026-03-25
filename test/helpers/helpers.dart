import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:test/test.dart';
import 'package:two_finance_blockchain/blockchain/contract/tokenV1/constants.dart';
import 'package:two_finance_blockchain/blockchain/contract/tokenV1/models/balance.dart';
import 'package:two_finance_blockchain/blockchain/keys/keys.dart';
import 'package:two_finance_blockchain/blockchain/types/types.dart';
import 'package:two_finance_blockchain/blockchain/utils/marshal.dart';
import 'package:two_finance_blockchain/config/config.dart';
import 'package:two_finance_blockchain/infra/mqtt/mqtt.dart';
import 'package:two_finance_blockchain/two_finance_blockchain.dart';

class TestUser {
  final String name;
  final String publicKey;
  final String privateKey;

  const TestUser({
    required this.name,
    required this.publicKey,
    required this.privateKey,
  });
}

String repeatHex(String hexChar, int len) => List.filled(len, hexChar).join();

Future<String> validPublicKeyHex() async {
  final km = KeyManager();
  final keyPair = await km.generateKeyEd25519();
  return keyPair.publicKey;
}

Future<KeyPair2Finance> validKeyPair() async {
  final km = KeyManager();
  return km.generateKeyEd25519();
}

Future<TestUser> newTestUser(String name) async {
  final kp = await validKeyPair();

  return TestUser(
    name: name,
    publicKey: kp.publicKey,
    privateKey: kp.privateKey,
  );
}

String sha256Hex(String input) {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.bytes
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join();
}

Future<TwoFinanceBlockchain> setupClient() async {
  try {
    await Config.loadConfig(
      env: 'dev',
      path: 'packages/two_finance_blockchain/assets/.env',
    );

    final uniqueClientId =
        "${Config.emqxClientId}-${DateTime.now().millisecondsSinceEpoch}";

    final mqttClient = MqttClientWrapper(
      host: Config.emqxHost,
      port: Config.emqxPort,
      clientId: uniqueClientId,
      useSSL: Config.emqxSSL,
      username: Config.emqxUsername,
      password: Config.emqxPassword,
      caCertPath: Config.emqxCaCertPath,
    );

    await mqttClient.connect();
    print('Initializing TwoFinanceBlockchain plugin...');

    final keyManager = KeyManager();
    const chainID = 1;

    final plugin = TwoFinanceBlockchain(
      keyManager: keyManager,
      mqttClient: mqttClient,
      chainID: chainID,
    );

    await plugin.initialize();
    return plugin;
  } catch (e) {
    print('⚠️ Error initializing TwoFinanceBlockchain: $e');
    rethrow;
  }
}

Future<void> teardownClient(TwoFinanceBlockchain c) async {
  try {
    final mc = (c as dynamic)._mqttClient;
    if (mc != null) {
      if ((mc as dynamic).disconnect != null) {
        await (mc as dynamic).disconnect();
      }
    }
  } catch (_) {
    // ignore
  }
}

String randSuffix(int n) {
  final random = Random.secure();
  final values = List<int>.generate(n, (_) => random.nextInt(256));
  return hexEncode(Uint8List.fromList(values)).substring(0, n);
}

String hexEncode(Uint8List bytes) {
  final buffer = StringBuffer();
  for (final b in bytes) {
    buffer.write(b.toRadixString(16).padLeft(2, '0'));
  }
  return buffer.toString();
}

String amt(int unscaled, int decimals) {
  final p = BigInt.from(10).pow(decimals);
  final v = BigInt.from(unscaled) * p;
  return v.toString();
}

Future<void> waitUntil(Duration d, bool Function() pred) async {
  final completer = Completer<void>();
  final end = DateTime.now().add(d);

  Timer.periodic(const Duration(milliseconds: 20), (timer) {
    if (pred()) {
      timer.cancel();
      completer.complete();
    } else if (DateTime.now().isAfter(end)) {
      timer.cancel();
      completer.completeError(
        TimeoutException("timeout waiting for condition"),
      );
    }
  });

  return completer.future;
}

Future<void> expectFtBalance(
  TwoFinanceBlockchain c, {
  required String tokenAddress,
  required String ownerAddress,
  required String expectedAmount,
}) async {
  final out = await c.getTokenBalance(
    tokenAddress: tokenAddress,
    ownerAddress: ownerAddress,
  );

  expect(out.states, isNotNull);
  expect(out.states!, isNotEmpty);

  final balance = unmarshalState(
    out.states!.first.object,
    (json) => BalanceState.fromJson(json),
  );

  expect(balance.ownerAddress, equals(ownerAddress));
  expect(balance.tokenAddress, equals(tokenAddress));
  expect(balance.amount, equals(expectedAmount));
}

Future<void> allowAndMintFtUsers(
  TwoFinanceBlockchain c, {
  required String tokenAddress,
  required List<TestUser> users,
  required String amount,
  required int decimals,
}) async {
  final outAllow = await c.allowUsers(
    tokenAddress,
    {for (final user in users) user.publicKey: true},
  );

  expect(outAllow, isA<ContractOutput>());
  expect(outAllow.logs, isNotNull);
  expect(outAllow.logs!, isNotEmpty);
  expect(outAllow.logs!.first.logType, equals('Token_AllowedUsersAdded'));
  expect(outAllow.logs!.first.contractAddress, equals(tokenAddress));

  final expectedAmount =
      (BigInt.parse(amount) * BigInt.from(10).pow(decimals)).toString();

  for (final user in users) {
    final outMint = await c.mintToken(
      tokenAddress: tokenAddress,
      mintTo: user.publicKey,
      amount: amount,
      decimals: decimals,
      tokenType: TOKEN_TYPE_FUNGIBLE,
    );

    expect(outMint, isA<ContractOutput>());
    expect(outMint.logs, isNotNull);
    expect(outMint.logs!, isNotEmpty);
    expect(outMint.logs!.length, equals(3));
    expect(outMint.logs![0].logType, equals('Token_Minted_FT'));
    expect(outMint.logs![1].logType, equals('Token_TotalSupplyIncreased'));
    expect(outMint.logs![2].logType, equals('Token_BalanceIncreased_FT'));

    await expectFtBalance(
      c,
      tokenAddress: tokenAddress,
      ownerAddress: user.publicKey,
      expectedAmount: expectedAmount,
    );
  }
}

Future<String> createBasicToken(
  TwoFinanceBlockchain c, {
  required String ownerPrivateKey,
  required String ownerPublicKey,
  required int decimals,
  required bool requireFee,
  required String tokenType,
  required bool stablecoin,
}) async {
  await c.setPrivateKey(ownerPrivateKey);

  final deployedToken = await c.deployContract1(TOKEN_CONTRACT_V1);
  expect(deployedToken.logs, isNotNull);
  expect(deployedToken.logs!, isNotEmpty);

  final tokenAddress = deployedToken.logs!.first.contractAddress;
  expect(tokenAddress, isNotEmpty);

  final symbol = '2F${randSuffix(4)}';
  final totalSupply =
      tokenType == TOKEN_TYPE_FUNGIBLE ? amt(1000000, decimals) : '1';

  final feeTiersList = requireFee
      ? <Map<String, dynamic>>[
          {
            'min_amount': '0',
            'max_amount': amt(10000, decimals),
            'min_volume': '0',
            'max_volume': amt(100000, decimals),
            'fee_bps': 50,
          },
        ]
      : <Map<String, dynamic>>[];

  final outAddToken = await c.addToken(
    address: tokenAddress,
    symbol: symbol,
    name: '2Finance',
    decimals: decimals,
    totalSupply: totalSupply,
    description: 'e2e token created by tests',
    owner: ownerPublicKey,
    image: 'https://example.com/image.png',
    website: 'https://example.com',
    tagsSocialMedia: {'twitter': 'https://twitter.com/2finance'},
    tagsCategory: {'category': 'DeFi'},
    tags: {'tag1': 'DeFi', 'tag2': 'Blockchain'},
    creator: '2Finance Test',
    creatorWebsite: 'https://creator.example',
    allowedUsers: {},
    blockedUsers: {},
    frozenAccounts: {},
    feeTiersList: feeTiersList,
    feeAddress: ownerPublicKey,
    freezeAuthorityRevoked: false,
    mintAuthorityRevoked: false,
    updateAuthorityRevoked: false,
    paused: false,
    expiredAt: DateTime.now().toUtc().add(const Duration(days: 365)),
    assetGlbUri: 'https://example.com/asset.glb',
    tokenType: tokenType,
    transferable: true,
    stablecoin: stablecoin,
  );

  expect(outAddToken, isA<ContractOutput>());
  expect(outAddToken.logs, isNotNull);
  expect(outAddToken.logs!, isNotEmpty);
  expect(outAddToken.logs!.first.contractAddress, equals(tokenAddress));

  return tokenAddress;
}