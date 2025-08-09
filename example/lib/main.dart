import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:two_finance_blockchain/two_finance_blockchain.dart';
import 'package:two_finance_blockchain/infra/mqtt/mqtt.dart';
import 'package:two_finance_blockchain/config/config.dart';
import 'package:mqtt_client/mqtt_client.dart' show MqttClient, MqttConnectionState, MqttPublishMessage, MqttPublishPayload;
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:two_finance_blockchain/blockchain/keys/keys.dart';
import 'package:two_finance_blockchain/blockchain/transaction/transaction.dart';
import 'package:two_finance_blockchain/blockchain/types/types.dart';
import 'package:two_finance_blockchain/blockchain/contract/walletV1/constants.dart';
import 'package:two_finance_blockchain/blockchain/contract/tokenV1/domain/token.dart' as domain;

import 'package:two_finance_blockchain/blockchain/contract/walletV1/domain/wallet.dart' as domain;


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
  late MqttClientWrapper mqttClient;
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

  Future<void> testMqttClient() async {
  try {

    print('🔌 Connecting...');
    await mqttClient.connect();

    print('📡 Subscribing...');
    await mqttClient.subscribe('test/topic', handler: (mqttClient, message) {
      final mqttMessage = message.payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(mqttMessage.payload.message);
      print('📥 Message received on ${message.topic}: $payload');
    });

    print('📤 Publishing...');
    await mqttClient.publish('test/topic', 'Hello from Flutter MQTT!');

    //await Future.delayed(const Duration(seconds: 3));

    print('🚫 Unsubscribing...');
    await mqttClient.unsubscribe('test/topic');

    print('🔌 Disconnecting...');
    await mqttClient.disconnect();
    print('✅ MQTT Client test completed successfully.');
    } catch (e) {
      print('❌ Error: $e');
      rethrow; // throws the error up to the caller
    }
  }

  String generateRandomSuffix(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<TwoFinanceBlockchain> initBlockchain() async {
    try {

      await Config.loadConfig(env: 'prod', path: 'packages/two_finance_blockchain/assets/.env');
      
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
      
      // ✅ Correct assignment to class-level field
      final plugin = TwoFinanceBlockchain(
        keyManager: keyManager,
        mqttClient: mqttClient,
      );

      return plugin;
    } catch (e) {
      print('⚠️ Error initializing TwoFinanceBlockchain: $e');
      rethrow;
    }
  }

  Future<void> testBlockchain() async {
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
    
    // --- WALLET EXAMPLE ---
    final contractOutput = await _twoFinanceBlockchainPlugin.addWallet(publicKey1);
    print(contractOutput.states);


    final json = contractOutput.toJson();
    print('Contract Output JSON: $json');
    final walletJson = (json['states'] as List)
    .map((e) => e as Map<String, dynamic>)
    .firstWhere((s) => s['type'] == 'wallet')['object'] as Map<String, dynamic>;
    print('Wallet JSON: $walletJson');

    // Parse into your Wallet model
    final wallet = domain.Wallet.fromJson(walletJson);
    print('✅ Parsed wallet: $wallet');
    // Parse into your Wallet model
    //final wallet = models.Wallet.fromJson(walletJson);
    //print('✅ Parsed wallet: $wallet');

    //final wallet1 = wallet.Wallet.fromJson(contractOutput.toJson());
    //print("✅ Wallet created: $wallet1");

    final getWalletOutput = await _twoFinanceBlockchainPlugin.getWallet(publicKey1);
    final fetchedWallet = domain.Wallet.fromJson(getWalletOutput.toJson());
    print("📥 Wallet fetched: $fetchedWallet");


    final String baseSymbol = "2F";
    final String suffix = generateRandomSuffix(4); // Implemented below
    final String symbol = "$baseSymbol$suffix";

    final String name = "2Finance";
    final int decimals = 3;
    final String totalSupply = "10";
    final String description =
        "2Finance is a decentralized finance platform that offers a range of financial services, including lending, borrowing, and trading.";

    final String owner = publicKey1; // Replace with your actual variable
    final String image = "https://example.com/image.png";
    final String website = "https://example.com";

    final Map<String, String> tagsSocialMedia = {
      "twitter": "https://twitter.com/2finance",
    };

    final Map<String, String> tagsCategory = {
      "category": "DeFi",
    };

    final Map<String, String> tags = {
      "tag1": "DeFi",
      "tag2": "Blockchain",
    };

    final String creator = "2Finance Creator";
    final String creatorWebsite = "https://creator.com";

    final Map<String, bool> allowUsers = {
      "43b23ffdd134ff73eda6cad0a5bd0d97877dd63ab8ba21ffe49d80fe51fd5dec": true,
    };

    final Map<String, bool> blockUsers = {
      "e8ef1e9a97c08ce9ba388b5df7f43964ce19317c3a77338d39d80898cbe22914": true,
    };

    final List<Map<String, dynamic>> feeTiersList = [
      // {
      //   "fee_bps": 50,
      //   "max_amount": "1000000000000000000",
      //   "min_amount": "0",
      //   "max_volume": "10000000000000000000",
      //   "min_volume": "0",
      // },
      // {
      //   "fee_bps": 25,
      //   "max_amount": "10000000000000000000",
      //   "min_amount": "1000000000000000001",
      //   "max_volume": "50000000000000000000",
      //   "min_volume": "10000000000000000001",
        
      // },
    ];

    final String feeAddress = "fe1b01a9861bb265b141c00517d7697c8a0d8286492a14d776ca33ffdded43c1";

    final bool freezeAuthorityRevoked = false;
    final bool mintAuthorityRevoked = false;
    final bool updateAuthorityRevoked = false;
    final bool paused = false;

    final DateTime expiredAt = DateTime.now().toUtc().add(const Duration(days: 30));

    final contractOutputToken = await _twoFinanceBlockchainPlugin.addToken(
      symbol: symbol,
      name: name,
      decimals: decimals,
      totalSupply: totalSupply,
      description: description,
      owner: owner,
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
      freezeAuthorityRevoked: freezeAuthorityRevoked,
      mintAuthorityRevoked: mintAuthorityRevoked,
      updateAuthorityRevoked: updateAuthorityRevoked,
      paused: paused,
      expiredAt: expiredAt,
    );

    // Parse into the Token model
    final token1 = domain.Token.fromJson(contractOutputToken.toJson());
    print("✅ Token created successfully: $token1");
    
    final String to = "43b23ffdd134ff73eda6cad0a5bd0d97877dd63ab8ba21ffe49d80fe51fd5dec";
    final String amount = "1000000"; // 1 token with 3 decimals

    final getTokenOutput = await _twoFinanceBlockchainPlugin.mintToken(
      to: to,
      mintTo: publicKey2,
      amount: amount,
      decimals: decimals,
    );
  
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
