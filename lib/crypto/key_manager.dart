import 'dart:typed_data';
import 'package:pointycastle/api.dart'; // Contém ParametersWithRandom e KeyParameter
import 'package:pointycastle/ecc/api.dart'; // Contém ECKeyGenerator, ECPublicKey, ECPrivateKey, ECDomainParameters
import 'package:pointycastle/key_generators/ec_key_generator.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:convert/convert.dart'; // Para conversão para hexadecimal

// Classe auxiliar para o par de chaves, como você deve ter definido
class KeyPair {
  final String publicKey;
  final String privateKey;

  KeyPair({required this.publicKey, required this.privateKey});

  @override
  String toString() {
    return 'KeyPair(publicKey: $publicKey, privateKey: $privateKey)';
  }
}

// Implementação do gerador de números aleatórios seguro
FortunaRandom _secureRandom() {
  final FortunaRandom random = FortunaRandom();
  // Para produção, use uma fonte de entropia real e segura!
  final List<int> seed = List<int>.generate(32, (i) => i);
  random.seed(KeyParameter(Uint8List.fromList(seed)));
  return random;
}

class KeyManager {
  /// Gera um novo par de chaves Ed25519.
  /// Retorna um objeto KeyPair contendo a chave pública e privada em formato hexadecimal.
  static KeyPair generateEd25519KeyPair() {
    final keyGen = ECKeyGenerator();

    // Importante: Para Ed25519, o pointycastle usa um objeto ECDomainParameters
    // que representa a curva. Você não importa diretamente 'ECCurve_Ed25519' de 'curves/ed25519.dart'
    // mas sim a obtém através de um mecanismo de registro ou a cria via ECDomainParameters.fromCurve.
    // A maneira mais comum e robusta é usar a instância pré-definida para Ed25519:
    final ECDomainParameters ed25519Params = ECCurve_Ed25519(); // Isso vem de 'package:pointycastle/ecc/api.dart' ou 'package:pointycastle/ecc/curves/ed25519.dart' (depende da versão exata)

    keyGen.init(
      ParametersWithRandom(
        ed25519Params, // Use a instância dos parâmetros da curva
        _secureRandom(),
      ),
    );

    final AsymmetricKeyPair<PublicKey, PrivateKey> keyPair = keyGen.generateKeyPair();

    final ECPublicKey publicKey = keyPair.publicKey as ECPublicKey;
    final ECPrivateKey privateKey = keyPair.privateKey as ECPrivateKey;

    // Chave pública: getEncoded(false) para Ed25519 deve retornar os 32 bytes brutos.
    final Uint8List pubBytes = publicKey.Q!.getEncoded(false);

    // Chave privada: Converter BigInt para Uint8List de 32 bytes.
    final Uint8List privBytes = _bigIntToBytes(privateKey.d!, 32);

    return KeyPair(
      publicKey: hex.encode(pubBytes),
      privateKey: hex.encode(privBytes),
    );
  }

  // Função auxiliar para converter BigInt para Uint8List com tamanho fixo
  static Uint8List _bigIntToBytes(BigInt number, int length) {
    final Uint8List result = Uint8List(length);
    for (int i = 0; i < length; i++) {
      result[length - 1 - i] = (number & BigInt.from(0xFF)).toInt();
      number = number >> 8;
    }
    return result;
  }
}