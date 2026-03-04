import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart'; // se precisar
import 'package:two_finance_blockchain/blockchain/keys/keys.dart';
import 'package:two_finance_blockchain/config/config.dart';
import 'package:two_finance_blockchain/infra/mqtt/mqtt.dart';
import 'package:two_finance_blockchain/two_finance_blockchain.dart';
import 'package:two_finance_blockchain/blockchain/utils/json.dart';
import 'package:crypto/crypto.dart'; // dart pub add crypto
import 'package:two_finance_blockchain/blockchain/keys/keys.dart';

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

String sha256Hex(String input) {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.bytes
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join();
}


Future<TwoFinanceBlockchain> setupClient() async {

    try {
      await Config.loadConfig(env: 'dev', path: 'packages/two_finance_blockchain/assets/.env');
      KeyManager keyManager;
      MqttClientWrapper mqttClient;
      final uniqueClientId = "${Config.emqxClientId}-${DateTime.now().millisecondsSinceEpoch}";

      mqttClient = MqttClientWrapper(
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
      
      keyManager = KeyManager();
      int chainID = 1;

      final plugin = TwoFinanceBlockchain(
        keyManager: keyManager,
        mqttClient: mqttClient,
        chainID: chainID,
      );
      await plugin.initialize(); // ✅ isso seta _isInitialized = true

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
  final StringBuffer buffer = StringBuffer();
  for (final b in bytes) {
    buffer.write(b.toRadixString(16).padLeft(2, '0'));
  }
  return buffer.toString();
}



// amt builds integer string respecting decimals (unscaled * 10^decimals)
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
      completer.completeError(TimeoutException("timeout waiting for condition"));
    }
  });

  return completer.future;
}