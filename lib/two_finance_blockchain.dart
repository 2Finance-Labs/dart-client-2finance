
// lib/main_blockchain.dart

import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart' show Uint8List;

import 'package:cryptography/cryptography.dart';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart' show dotenv; // Para encodar as chaves em base64 ou hex, se necessário.

/// Representa um par de chaves pública e privada geradas.
class KeyPair2Finance {
  final String publicKey;
  final String privateKey;

  KeyPair2Finance({required this.publicKey, required this.privateKey});

  @override
  String toString() {
    return 'Public Key: $publicKey\nPrivate Key: $privateKey';
  }
}

/// Um plugin Flutter para interagir com a 2Finance Blockchain.
/// Este plugin lida com operações criptográficas e futuras interações de rede.
class TwoFinanceBlockchain {

  // Variáveis para armazenar as configurações EMQX e Keycloak
  // Elas serão inicializadas após o carregamento do .env
  String _emqxScheme = '';
  String _emqxHost = '';
  String _emqxPort = '';
  String _emqxUsername = '';
  String _emqxPassword = '';
  String _emqxCaCertPath = '';
  String _emqxClientId = '';

  // Variáveis internas para armazenar o par de chaves ativo
  String? _activePrivateKey;
  String? _activePublicKey;

  // Propriedade para verificar se o plugin foi inicializado
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Método de inicialização que carrega as configurações do .env.
  /// Deve ser chamado uma vez antes de usar outras funcionalidades do plugin
  /// que dependam dessas configurações.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await dotenv.load(fileName: "packages/two_finance_blockchain/assets/.env");

      _emqxScheme = dotenv.env['EMQX_SCHEME'] ?? 'tcp';
      _emqxHost = dotenv.env['EMQX_HOST'] ?? 'localhost';
      _emqxPort = dotenv.env['EMQX_PORT'] ?? '1883';
      _emqxUsername = dotenv.env['EMQX_USERNAME'] ?? '';
      _emqxPassword = dotenv.env['EMQX_PASSWORD'] ?? '';
      _emqxCaCertPath = dotenv.env['EMQX_CA_CERT_PATH'] ?? '';
      _emqxClientId = dotenv.env['EMQX_CLIENT_ID'] ?? 'flutter_plugin_client';

      _isInitialized = true;
    } catch (e) {
      // Em caso de erro ao carregar o .env, lançamos uma exceção
      throw Exception('Failed to load plugin configurations: $e');
    }
  }

  /// Retorna as configurações EMQX carregadas.
  Map<String, String> getEmqxConfig() {
    if (!_isInitialized) {
      throw Exception("TwoFinanceBlockchain plugin not initialized. Call 'initialize()' first.");
    }
    return {
      'scheme': _emqxScheme,
      'host': _emqxHost,
      'port': _emqxPort,
      'username': _emqxUsername,
      'password': _emqxPassword,
      'caCertPath': _emqxCaCertPath,
      'clientId': _emqxClientId,
    };
  }

  /// Gera um par de chaves Ed25519 (chave pública e privada) de forma assíncrona.
  ///
  /// Retorna um [KeyPair2Finance] contendo as chaves geradas.
  /// Lança uma exceção se a geração da chave falhar.
  Future<KeyPair2Finance> generateKeyEd25519() async {
    final algorithm = Ed25519();
    final keyPair = await algorithm.newKeyPair();
    final publicKeyBytes = (await keyPair.extractPublicKey()).bytes;
    final privateKeyBytes = (await keyPair.extractPrivateKeyBytes());

    // Convertendo as chaves para Strings (e.g., hexadecimal ou base64)
    // O código Go usa strings, então vamos seguir essa prática.
    // Usaremos hexadecimal por ser comum para chaves.
    final String publicKeyHex = _bytesToHex(publicKeyBytes);
    final String privateKeyHex = _bytesToHex(privateKeyBytes);

    // Opcionalmente, define as chaves geradas como as ativas
    _activePublicKey = publicKeyHex;
    _activePrivateKey = privateKeyHex;

    return KeyPair2Finance(
      publicKey: publicKeyHex,
      privateKey: privateKeyHex,
    );
  }

  /// Define a chave privada ativa e deriva a chave pública correspondente.
  ///
  /// Equivalente a `client.SetPrivateKey` no Go.
  /// [privateKeyHex] A chave privada no formato hexadecimal.
  /// Lança uma [FormatException] se a chave privada hexadecimal for inválida.
  /// Lança um [Exception] se não for possível derivar a chave pública.
  Future<void> setPrivateKey(String privateKeyHex) async {
    // A validação do comprimento deve ser feita depois de obter a lista de bytes,
    // pois a `Uint8List` pode ser criada com 0 elementos e teríamos um erro de "length" antes.

    try {
      final algorithm = Ed25519();
      // Converte a string hexadecimal da chave privada em bytes
      final Uint8List privateKeyBytes = _hexToBytes(privateKeyHex);

      // Verifique o comprimento APÓS a conversão.
      // Se a `Uint8List` não tem a propriedade 'length', teremos que usar um truque.
      // A forma mais básica de obter o comprimento de uma List é iterar sobre ela.
      // No entanto, isso é altamente improvável. Todas as Listas (e Uint8List é uma)
      // têm a propriedade 'length'. Se ela não está na assinatura que você vê,
      // provavelmente está em uma interface que ela implementa ou é um getter oculto.

      // Vamos ASSUMIR que privateKeyBytes pode ser tratada como uma List<int>
      // para acessar o método length. Se isso falhar, então o ambiente é EXTREMAMENTE
      // restrito e precisaremos de detalhes da sua versão do SDK.

      privateKeyBytes.

      // VERIFICAÇÃO DO COMPRIMENTO:
      if (privateKeyBytes.length < 32) { // <- ESTA LINHA DEVE FUNCIONAR. Se não, é um problema de ambiente.
        throw Exception("Chave privada muito curta para derivar a semente (precisa de pelo menos 32 bytes).");
      }

      // EXTRAÇÃO DA SEMENTE:
      // Convertemos para List<int> para ter acesso garantido ao método `sublist`,
      // pois `List` *sempre* tem `sublist`.
      final List<int> tempBytesAsList = privateKeyBytes.toList(); // <- Esta linha *deve* funcionar.
      final Uint8List seedBytes = Uint8List.fromList(tempBytesAsList.sublist(0, 32));


      final keyPair = await algorithm.newKeyPairFromSeed(
        seedBytes, // Usar a semente extraída de forma segura
      );

      final publicKeyBytes = (await keyPair.extractPublicKey()).bytes;

      _activePrivateKey = privateKeyHex;
      _activePublicKey = _bytesToHex(publicKeyBytes);

      print('Chave privada definida e chave pública derivada com sucesso!');
      print('Chave Pública Ativa: $_activePublicKey');

    } on FormatException catch (e) {
      throw FormatException('Erro de formato na chave privada: ${e.message}');
    } catch (e) {
      throw Exception('Erro ao definir chave privada e derivar chave pública: $e');
    }
  }

  /// Converte uma lista de bytes para uma string hexadecimal.
  String _bytesToHex(List<int> bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Converte uma string hexadecimal para uma lista de bytes.
  Uint8List _hexToBytes(String hex) {
    if (hex.length % 2 != 0) {
      throw FormatException('String hexadecimal inválida. O comprimento deve ser par.');
    }
    final List<int> bytes = [];
    for (int i = 0; i < hex.length; i += 2) {
      bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return Uint8List.fromList(bytes);
  }

  /// Retorna a chave privada ativa.
  String? get activePrivateKey => _activePrivateKey;

  /// Retorna a chave pública ativa.
  String? get activePublicKey => _activePublicKey;

// Futuramente, adicionaremos métodos para:
// - Conectar ao EMQX
// - Enviar e receber transações
// - Carregar configurações de .env (embora o Flutter não acesse .env diretamente como Go)
//   Para .env em Flutter, geralmente usamos pacotes como `flutter_dotenv` ou
//   passamos configurações durante o build/compilação.

}