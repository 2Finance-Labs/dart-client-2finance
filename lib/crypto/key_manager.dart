import 'dart:typed_data';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/ecc/api.dart';
import 'package:pointycastle/key_generators/api.dart' show ECKeyGeneratorParameters;
import 'package:pointycastle/key_generators/ec_key_generator.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:convert/convert.dart';
import 'package:pointycastle/src/registry/registry.dart';

class KeyPair {
  final String publicKey;
  final String privateKey;

  KeyPair({required this.publicKey, required this.privateKey});

  @override
  String toString() {
    return 'KeyPair(publicKey: $publicKey, privateKey: $privateKey)';
  }
}

FortunaRandom _secureRandom() {
  final FortunaRandom random = FortunaRandom();
  final List<int> seed = List<int>.generate(32, (i) => i);
  random.seed(KeyParameter(Uint8List.fromList(seed)));
  return random;
}

class KeyManager {
  static KeyPair generateEd25519KeyPair() {
    final keyGen = ECKeyGenerator();

    final ECDomainParameters ed25519Params = registry.create<ECDomainParameters>('Ed25519')!;

    // --- LÓGICA FINAL APLICADA AQUI ---
    // 1. Crie os parâmetros de geração da chave, que aceita somente a curva.
    final ecKeyGenParameters = ECKeyGeneratorParameters(ed25519Params);

    // 2. Combine os parâmetros de geração com o gerador de números aleatórios.
    final ecParams = ParametersWithRandom(
      ecKeyGenParameters,
      _secureRandom(),
    );

    keyGen.init(ecParams);

    final AsymmetricKeyPair<PublicKey, PrivateKey> keyPair = keyGen.generateKeyPair();

    final ECPublicKey publicKey = keyPair.publicKey as ECPublicKey;
    final ECPrivateKey privateKey = keyPair.privateKey as ECPrivateKey;

    final Uint8List pubBytes = publicKey.Q!.getEncoded(false);
    final Uint8List privBytes = _bigIntToBytes(privateKey.d!, 32);

    return KeyPair(
      publicKey: hex.encode(pubBytes),
      privateKey: hex.encode(privBytes),
    );
  }

  static Uint8List _bigIntToBytes(BigInt number, int length) {
    final Uint8List result = Uint8List(length);
    for (int i = 0; i < length; i++) {
      result[length - 1 - i] = (number & BigInt.from(0xFF)).toInt();
      number = number >> 8;
    }
    return result;
  }
}