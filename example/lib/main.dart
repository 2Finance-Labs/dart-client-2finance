import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:two_finance_blockchain/two_finance_blockchain.dart';
import 'package:two_finance_blockchain/infra/mqtt/mqtt.dart';
import 'package:two_finance_blockchain/config/config.dart';
import 'package:mqtt_client/mqtt_client.dart' show MqttClient, MqttConnectionState, MqttPublishMessage, MqttPublishPayload;
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:two_finance_blockchain/blockchain/keys/keys.dart';
import 'package:two_finance_blockchain/blockchain/transaction/transaction.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  // Instância do plugin TwoFinanceBlockchain
  late MqttClientWrapper client;
  late TwoFinanceBlockchain _twoFinanceBlockchainPlugin;
  late KeyManager keyManager;
  

  @override
  void initState() {
    super.initState();
    initPlatformState();

  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;

    _twoFinanceBlockchainPlugin = await initBlockchain();
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _twoFinanceBlockchainPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<MqttClientWrapper> testMqttClient() async {
  try {
    await Config.loadConfig(env: 'prod', path: 'packages/two_finance_blockchain/assets/.env');

    final client = MqttClientWrapper(
      host: Config.emqxHost,
      port: Config.emqxPort,
      clientId: Config.emqxClientId,
      useSSL: Config.emqxSSL,
      username: Config.emqxUsername,
      password: Config.emqxPassword,
      caCertPath: Config.emqxCaCertPath,
    );

    print('🔌 Connecting...');
    await client.connect();

    print('📡 Subscribing...');
    await client.subscribe('test/topic', handler: (mqttClient, message) {
      final mqttMessage = message.payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(mqttMessage.payload.message);
      print('📥 Message received on ${message.topic}: $payload');
    });

    print('📤 Publishing...');
    await client.publish('test/topic', 'Hello from Flutter MQTT!');

    await Future.delayed(const Duration(seconds: 3));

    print('🚫 Unsubscribing...');
    await client.unsubscribe('test/topic');

    print('🔌 Disconnecting...');
    await client.disconnect();

    print('✅ Test complete');
    return client;
    } catch (e) {
      print('❌ Error: $e');
      rethrow; // throws the error up to the caller
    }
  }


  Future<TwoFinanceBlockchain> initBlockchain() async {
    try {

      await Config.loadConfig(env: 'prod', path: 'packages/two_finance_blockchain/assets/.env');
      
      client = MqttClientWrapper(
        host: Config.emqxHost,
        port: Config.emqxPort,
        clientId: Config.emqxClientId,
        useSSL: Config.emqxSSL,
        username: Config.emqxUsername,
        password: Config.emqxPassword,
        caCertPath: Config.emqxCaCertPath,
      );

      print('Initializing TwoFinanceBlockchain plugin...');
      
      keyManager = KeyManager();
      
      // ✅ Correct assignment to class-level field
      final plugin = TwoFinanceBlockchain(
        keyManager: keyManager,
        mqttClient: client,
      );

      return plugin;
    } catch (e) {
      print('⚠️ Error initializing TwoFinanceBlockchain: $e');
      rethrow;
    }
  }

  Future<void> testBlockchain() async {

    try {

      print('Plugin initialized successfully.');
      await _twoFinanceBlockchainPlugin.initialize();
      final keyPair1 = await _twoFinanceBlockchainPlugin.generateKeyEd25519();
      final keyPair2 = await _twoFinanceBlockchainPlugin.generateKeyEd25519();

      await _twoFinanceBlockchainPlugin.setPrivateKey(keyPair1.privateKey);
      final publicKey1 = keyPair1.publicKey;
      final publicKey2 = keyPair2.publicKey;
      print('Private Key: ${keyPair1.privateKey}');
      print('Public Key: $publicKey1');
      print('Receiver Public Key: $publicKey2');

      final tx = Transaction.create(
          from: publicKey1,
          to: publicKey2,
          timestamp: DateTime.now().toUtc(),
          contractVersion: '1.0',
          method: 'transfer',
          data: {'amount': 100},
          nonce: 1,
        );

      await signTransaction(keyPair1.privateKey, tx);
      await tx.validate();
      print(tx);

      print('Transaction validated successfully: $tx');
  

    } catch (e) {
      print('Error: $e');
    }
  }

 @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Running on: $_platformVersion\n'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: testBlockchain,
                child: const Text('Run Blockchain Test'),
              ),
            ],
          ),
        ),
      ),
    );
}


  
}
