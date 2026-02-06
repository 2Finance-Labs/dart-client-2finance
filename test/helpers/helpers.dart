import 'dart:convert';
import 'dart:typed_data';
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

