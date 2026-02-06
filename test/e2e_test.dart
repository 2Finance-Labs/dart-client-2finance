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
import 'package:test/test.dart';

// ----------------------------------------------------------------------------
// Helpers
// ----------------------------------------------------------------------------

void main() {
  test('SetupClient', () async{
    expect(await setupClient(), isA<TwoFinanceBlockchain>());
  });

  test("Teste randSuffix", () {
    final s1 = randSuffix(4);
    final s2 = randSuffix(4);
    expect(s1.length, 4);
    expect(s2.length, 4);
    expect(s1 != s2, true);
  });

  test("Teste hexEncode", () {
    final bytes = Uint8List.fromList([0, 15, 255]);
    final hex = hexEncode(bytes);
    expect(hex, "000fff");
  });

  test("Teste unmarshalState", () {
    final obj = {"key": "value"};
    final result = unmarshalState<Map<String, String>>(obj, (json) => Map<String, String>.from(json));
    expect(result["key"], "value");
  });

  test("Teste amt", () {
    expect(amt(1, 6), "1000000");
    expect(amt(123, 2), "12300");
  });

  test("Teste waitUntil", () async {
    var count = 0;
    final future = waitUntil(Duration(seconds: 1), () => count >= 3);
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      count++;
      if (count >= 3) timer.cancel();
    });
    await future;
    expect(count, 3);
  });

  test("Teste genKey", () async {
    final keyManager = KeyManager();
    final (pub, priv) = await genKey(keyManager);
    expect(pub.isNotEmpty, true);
    expect(priv.isNotEmpty, true);
  });
}

 Future<TwoFinanceBlockchain> setupClient() async {
    try {
      await Config.loadConfig(env: 'dev', path: 'packages/two_finance_blockchain/assets/.env');
      KeyManager keyManager;
      MqttClientWrapper mqttClient;
      mqttClient = MqttClientWrapper(
        host: Config.emqxHost,
        port: Config.emqxPort,
        clientId: Config.emqxClientId,
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

      return plugin;
    } catch (e) {
      print('⚠️ Error initializing TwoFinanceBlockchain: $e');
      rethrow;
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

// unmarshalState decodes an arbitrary state object into a typed struct.
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

Future<(String, String)> genKey(KeyManager c) async {
  final result = await c.generateKeyEd25519();
  // assumindo que seu método retorna (pub, priv)
  return (result.publicKey, result.privateKey);
}

// ----------------------------------------------------------------------------
// Stub Client (substitua pelo real)
// ----------------------------------------------------------------------------


