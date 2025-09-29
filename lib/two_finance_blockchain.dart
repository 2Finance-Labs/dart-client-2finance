library two_finance_blockchain;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' show dotenv; // Para encodar as chaves em base64 ou hex, se necessário.
import 'package:mqtt_client/mqtt_client.dart' show MqttClient, MqttConnectionState, MqttPublishMessage, MqttPublishPayload;
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:two_finance_blockchain/blockchain/types/types.dart' as types;
import 'package:uuid/uuid.dart';

import 'package:two_finance_blockchain/blockchain/contract/constants.dart';
import 'package:two_finance_blockchain/blockchain/contract/tokenV1/constants.dart';
import 'package:two_finance_blockchain/blockchain/contract/tokenV1/domain/token.dart';
import 'package:two_finance_blockchain/blockchain/contract/walletV1/constants.dart';
import 'package:two_finance_blockchain/blockchain/keys/keys.dart';
import 'package:two_finance_blockchain/blockchain/transaction/transaction.dart';
import 'package:two_finance_blockchain/blockchain/types/types.dart';
import 'package:two_finance_blockchain/blockchain/utils/decimals.dart';
import 'package:two_finance_blockchain/infra/event/request_response.dart';
import 'package:two_finance_blockchain/infra/mqtt/mqtt.dart';

import 'blockchain/contract/raffleV1/constants.dart';
import 'blockchain/contract/reviewV1/constants.dart';
import 'blockchain/contract/cashbackV1/constants.dart';
import 'blockchain/contract/paymentV1/constants.dart';
import 'blockchain/contract/faucetV1/constants.dart';
import 'blockchain/contract/couponsV1/constants.dart';
import 'blockchain/contract/member_get_memberV1/constants.dart';
import 'blockchain/contract/contractV1/constants.dart';
part 'review.dart';
part 'token.dart';
part 'wallet.dart';
part 'raffle.dart';
part 'cashback.dart';
part 'payment.dart';
part 'faucet.dart';
part ' coupons.dart';
part 'member_get_member.dart';


class TwoFinanceBlockchain {
  
  static const MethodChannel _channel = MethodChannel('two_finance_blockchain');
  
  String? _activePrivateKey;
  String? _activePublicKey;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  late String _replyTo;

  Future<void> initialize() async {
    if (_isInitialized) return;
   // initState();
    _isInitialized = true;
  }

  void _initState() {
    //super.initState();
    final uuid = Uuid();
    _replyTo = uuid.v4();

  }

  

  final KeyManager _keyManager;
  final MqttClientWrapper _mqttClient;

  TwoFinanceBlockchain({required KeyManager keyManager, required MqttClientWrapper mqttClient})
      : _keyManager = keyManager,
        _mqttClient = mqttClient {
          _initState();
        }

  Future<String?> getPlatformVersion() async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  Future<void> setPrivateKey(String privateKeyHex) async {
    try {
      final algorithm = Ed25519();

      // Usa a função utilitária da própria classe
      final Uint8List privateKeyBytes = KeyManager.hexToBytes(privateKeyHex);

      if (privateKeyBytes.length < 32) {
        throw Exception(
          "Chave privada muito curta para derivar a semente (precisa de pelo menos 32 bytes = 64 hex). "
          "Recebido: ${privateKeyBytes.length} bytes.",
        );
      }

      // Usa apenas os primeiros 32 bytes como semente
      final seedBytes = Uint8List.fromList(privateKeyBytes.sublist(0, 32));

      final keyPair = await algorithm.newKeyPairFromSeed(seedBytes);
      final publicKeyBytes = (await keyPair.extractPublicKey()).bytes;

      // Armazena as chaves ativas usando os métodos auxiliares
      _activePrivateKey = privateKeyHex;
      _activePublicKey = KeyManager.bytesToHex(publicKeyBytes);

      print('✅ Chave privada definida e chave pública derivada com sucesso!');
      print('🔑 Chave Pública Ativa: $_activePublicKey');
    } on FormatException catch (e) {
      throw FormatException('Erro de formato na chave privada: ${e.message}');
    } catch (e) {
      throw Exception('Erro ao definir chave privada e derivar chave pública: $e');
    }
  }

  Future<KeyPair2Finance> generateKeyEd25519() async {
    return await _keyManager.generateKeyEd25519();
  }

  Future<int> getNonce(String publicKey) async {
    if (publicKey.isEmpty) {
      throw Exception("public key not set");
    }

    KeyManager.validateEdDSAPublicKey(publicKey);

    final transactionInput = {'from': publicKey};

    final outputBytes = await sendTransaction(
      REQUEST_METHOD_GET_NONCE,
      transactionInput,
      _replyTo,
    );

    final decoded = json.decode(utf8.decode(outputBytes));
    if (decoded is int) {
      return decoded;
    } else if (decoded is String) {
      return int.parse(decoded);
    } else {
      throw Exception("failed to decode nonce: unexpected format");
    }
  }

  Future<Uint8List> sendTransaction(String method, dynamic tx, String replyTo) async {
    final topicBase = TRANSACTIONS_REQUEST_TOPIC.replaceAll('/+', '');
    final requestTopic = "$topicBase/$replyTo";
    final responseTopic = "$TRANSACTIONS_RESPONSE_TOPIC/$replyTo";

    final responseCompleter = Completer<String>();

    await _mqttClient.subscribe(responseTopic, handler: (client, msg) {
      final publishMessage = msg.payload as MqttPublishMessage;
      final payloadStr = MqttPublishPayload.bytesToStringAsString(publishMessage.payload.message);
      // Complete only the first time
      if (!responseCompleter.isCompleted) {
        responseCompleter.complete(payloadStr);
      }
    });

    final payload = RequestPayload(method: method, params: tx);
    final encodedJson = json.encode(payload.toJson());

    await _mqttClient.publish(requestTopic, encodedJson); // Assuming publish expects String

    final responseBytes = await responseCompleter.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception("timeout waiting for response on topic $responseTopic"),
    );
    final decoded = json.decode(responseBytes);
    final resp = ResponsePayload.fromJson(decoded);

    if (resp.status == RESPONSE_STATUS_ERROR) {
      if (resp.message?.contains("record not found") == true && method == "get_nonce") {
        return Uint8List.fromList(utf8.encode("0")); // Return zero as fallback
      }
      throw Exception("error in response: ${resp.message}");
    }
    final encodedData = json.encode(resp.data);
    return Uint8List.fromList(utf8.encode(encodedData));
  }


  Future<ContractOutput> signAndSendTransaction({
    required String from,
    required String to,
    required String contractVersion,
    required String method,
    required Map<String, dynamic> data,
  }) async {
    KeyManager.validateEdDSAPublicKey(from);
    // Get current nonce and handle "record not found"
    int nonce;
    try {
      nonce = await getNonce(from);
    } catch (e) {
      if (e.toString().contains('record not found')) {
        nonce = 0;
      } else {
        throw Exception('failed to get nonce: $e');
      }
    }

    nonce++; // Increment nonce

    
    final tx = Transaction.create(
      from: from,
      to: to,
      contractVersion: contractVersion,
      method: method,
      data: data,
      nonce: nonce,
    );

    final privateKey = _activePrivateKey;
    if (privateKey == null) {
      throw Exception("Active private key is not initialized");
    }

    await signTransaction(privateKey, tx);
    print('Transaction signed successfully: ${tx}');
    
    // Send to network
    final responseBytes = await sendTransaction(
      REQUEST_METHOD_SEND_TRANSACTION,
      tx,
      _replyTo!,
    );

    // Decode response
    final decoded = json.decode(utf8.decode(responseBytes));
    return ContractOutput.fromJson(decoded);
  }

  Future<ContractOutput> getState({
    required String contractVersion,
    required String method,
    required Map<String, dynamic> data,
  }) async {
    try {
      // Build a transaction input without signature and hash
      final txInput = {
        'contract_version': contractVersion,
        'method': method,
        'data': data, // assuming Map<String, dynamic>
      };

      // Make the request (this uses your existing MQTT plugin or handler)
      final responseBytes = await sendTransaction(
        REQUEST_METHOD_GET_STATE,
        txInput,
        _replyTo!,
      );

      // Decode JSON response
      final Map<String, dynamic> contractOutputJson = json.decode(utf8.decode(responseBytes));

      return ContractOutput.fromJson(contractOutputJson);
    } catch (e) {
      throw Exception('failed to get state: $e');
    }
  }


 Future<ContractOutput> deployContract(
      String contractVersion, String contractAddress) async {
    final from = _activePublicKey!;
    if (from.isEmpty) {
      throw Exception('from address is required');
    }
    
    KeyManager.validateEdDSAPublicKey(from);
    if (contractVersion.isEmpty) {
      throw Exception('contract version is required');
    }
    
    String to = DEPLOY_CONTRACT_ADDRESS;
    if (contractAddress.isNotEmpty) {
      to = contractAddress;
    }
    
    final method = METHOD_DEPLOY_CONTRACT;
    final data = <String, dynamic>{
      'contract_version': contractVersion,
    };
    
    try {
      final contractOutput = await signAndSendTransaction(
          from: from, to: to, contractVersion: contractVersion, method: method, data: data);
      return contractOutput;
    } catch (e) {
      throw Exception('failed to deploy contract: $e');
    }
  }

/*
Future<ContractOutput> deployContract(
    String contractVersion,
    String contractAddress,
  ) async {
    final from = _activePublicKey!;
    print('DEPLOYCONTRACT ADRESS: $from');
    if (from.isEmpty) {
      throw Exception("from address is required");
    } 
    KeyManager.validateEdDSAPublicKey(from);

    if (contractVersion.isEmpty) {
      throw Exception("contract version is required");
    }

    var to = DEPLOY_CONTRACT_ADDRESS;
    if (contractAddress.isNotEmpty) {
      to = contractAddress;
    }

    const method = METHOD_DEPLOY_CONTRACT;

    final data = {
      "contract_version": contractVersion,
    };

    try {
      return await signAndSendTransaction(
        from: from,
        to: to,
        contractVersion: contractVersion,
        method: method,
        data: data,
      );
    } catch (e) {
      throw Exception("failed to deploy contract: $e");
    }
  }
  
  */
  /// Retorna a chave privada ativa.
  String? get activePrivateKey => _activePrivateKey;

  /// Retorna a chave pública ativa.
  String? get activePublicKey => _activePublicKey;

}
