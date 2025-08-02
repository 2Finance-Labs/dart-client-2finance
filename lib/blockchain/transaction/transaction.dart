import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:web3dart/crypto.dart'; // for keccak256
import 'package:two_finance_blockchain/blockchain/keys/keys.dart';
import 'package:two_finance_blockchain/blockchain/types/types.dart';

typedef JSONB = Map<String, dynamic>;

abstract class ITransaction {
  Future<void> validateTransaction();
  Future<void> validate();
  Future<void> validateTimestamp();
  Future<void> validateHash();
  Future<void> validateSignature();
  Future<String> calculateHash();
  BigInt calculateFeeGas(int gasLimit, BigInt gasPriceWei);
  Transaction get();
}

class Transaction implements ITransaction {
  String from;
  String to;
  DateTime timestamp;
  String contractVersion;
  String method;
  JSONB data;
  int nonce;
  String hash;
  String signature;
  BigInt? gasFeeTotalWei;

  Transaction({
    required this.from,
    required this.to,
    required this.timestamp,
    required this.contractVersion,
    required this.method,
    required this.data,
    required this.nonce,
    this.hash = '',
    this.signature = '',
    this.gasFeeTotalWei,
  });

  @override
  String toString() {
    return '''
  Transaction(
    from: $from,
    to: $to,
    timestamp: $timestamp,
    contractVersion: $contractVersion,
    method: $method,
    data: $data,
    nonce: $nonce,
    hash: $hash,
    signature: $signature,
    gasFeeTotalWei: $gasFeeTotalWei
  )
  ''';
  }

  static Transaction create({
    required String from,
    required String to,
    required DateTime timestamp,
    required String contractVersion,
    required String method,
    required JSONB data,
    required int nonce,
  }) {
    return Transaction(
      from: from,
      to: to,
      timestamp: timestamp.toUtc(),
      contractVersion: contractVersion,
      method: method,
      data: data,
      nonce: nonce,
    );
  }

  @override
  Future<void> validateTransaction() async {
    if (from.isEmpty) throw Exception("sender address is required");
    if (to.isEmpty) throw Exception("recipient address is required");
    if (method.isEmpty) throw Exception("method is required");
    if (data.isEmpty) throw Exception("data cannot be empty");
    if (nonce == 0) throw Exception("nonce must be greater than zero");
    if (hash.length != 64) throw Exception("hash must be 64 characters long");
    if (signature.isEmpty) throw Exception("signature cannot be empty");
  }

  @override
  Future<void> validate() async {
    if (from == to) throw Exception("sender and recipient cannot be the same");

    KeyManager.validateEdDSAPublicKey(from);
    if (to != '' && to != deployContractAddress) {
      KeyManager.validateEdDSAPublicKey(to);
    }

    await validateHash();
    await validateSignature();
  }

  @override
  Future<void> validateTimestamp() async {
    final now = DateTime.now().toUtc();
    final diff = timestamp.difference(now);
    if (diff.inSeconds.abs() > 10) {
      throw Exception("timestamp is out of valid ±10s UTC range");
    }
  }

  @override
  Future<void> validateHash() async {
    final computed = await calculateHash();
    if (computed != hash) {
      throw Exception("invalid hash: expected $computed, got $hash");
    }
  }

  @override
  Future<void> validateSignature() async {
    final algorithm = Ed25519();
    final hashBytes = KeyManager.hexToBytes(await calculateHash());
    final pubKey = SimplePublicKey(KeyManager.hexToBytes(from), type: KeyPairType.ed25519);
    final sigBytes = KeyManager.hexToBytes(signature);

    if (sigBytes.length != 64) {
      throw Exception("invalid signature length: expected 64 bytes (Ed25519)");
    }

    final isValid = await algorithm.verify(hashBytes, signature: Signature(sigBytes, publicKey: pubKey));
    if (!isValid) {
      throw Exception("signature verification failed");
    }
  }

  @override
  Future<String> calculateHash() async {
    final temp = toJson();
    temp.remove('hash');
    temp.remove('signature');

    final encoded = utf8.encode(jsonEncode(temp));
    final hash = keccak256(Uint8List.fromList(encoded));
    return KeyManager.bytesToHex(hash);
  }

  @override
  BigInt calculateFeeGas(int gasLimit, BigInt gasPriceWei) {
    final fee = gasPriceWei * BigInt.from(gasLimit);
    gasFeeTotalWei = fee;
    return fee;
  }

  @override
  Transaction get() => this;

  Map<String, dynamic> toJson() => {
        'from': from,
        'to': to,
        'timestamp': timestamp.toIso8601String(),
        'contract_version': contractVersion,
        'method': method,
        'data': data,
        'nonce': nonce,
        'hash': hash,
        'signature': signature,
        'gas_fee_total_wei': gasFeeTotalWei?.toString(),
      };

  static Transaction fromJson(Map<String, dynamic> json) => Transaction(
        from: json['from'],
        to: json['to'],
        timestamp: DateTime.parse(json['timestamp']),
        contractVersion: json['contract_version'],
        method: json['method'],
        data: Map<String, dynamic>.from(json['data']),
        nonce: json['nonce'],
        hash: json['hash'],
        signature: json['signature'],
        gasFeeTotalWei: json['gas_fee_total_wei'] != null
            ? BigInt.parse(json['gas_fee_total_wei'])
            : null,
      );
}

/// Signs a transaction using a hex-encoded Ed25519 private key
Future<Transaction> signTransaction(String privateKeyHex, Transaction tx) async {
  final privateKeyBytes = KeyManager.hexToBytes(privateKeyHex);
  if (privateKeyBytes.length < 32) {
    throw Exception("private key must be at least 32 bytes (64 hex chars)");
  }

  final seed = privateKeyBytes.sublist(0, 32);
  final algorithm = Ed25519();
  final keyPair = await algorithm.newKeyPairFromSeed(seed);

  final txHash = await tx.calculateHash();
  final hashBytes = KeyManager.hexToBytes(txHash);
  final signature = await algorithm.sign(hashBytes, keyPair: keyPair);

  tx.hash = txHash;
  tx.signature = KeyManager.bytesToHex(signature.bytes);
  return tx;
}
