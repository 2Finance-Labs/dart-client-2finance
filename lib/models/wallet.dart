import 'package:json_annotation/json_annotation.dart';

// Necessário para que o gerador de código saiba onde encontrar a classe
// Execute 'flutter pub run build_runner build' no terminal para gerar o arquivo .g.dart
part 'wallet.g.dart';

@JsonSerializable()
class Wallet {
  @JsonKey(name: 'public_key')
  final String publicKey;

  @JsonKey(name: 'amount')
  final String amount;

  // Use DateTime? para nullable e fromJson/toJson para customizar a serialização/desserialização
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  Wallet({
    required this.publicKey,
    required this.amount,
    this.createdAt,
    this.updatedAt,
  });

  /// Construtor de fábrica para criar uma instância de Wallet a partir de um JSON.
  /// O `_$WalletFromJson` será gerado automaticamente pelo `json_serializable`.
  factory Wallet.fromJson(Map<String, dynamic> json) => _$WalletFromJson(json);

  /// Método para converter uma instância de Wallet em um mapa JSON.
  /// O `_$WalletToJson` será gerado automaticamente pelo `json_serializable`.
  Map<String, dynamic> toJson() => _$WalletToJson(this);

  // Opcional: Métodos "Get" como no Go, mas geralmente em Dart, acessamos diretamente as propriedades.
  String getPublicKey() => publicKey;
  String getAmount() => amount;
  DateTime? getCreatedAt() => createdAt;
  DateTime? getUpdatedAt() => updatedAt;

  // Opcional: Para facilitar a depuração
  @override
  String toString() {
    return 'Wallet(publicKey: $publicKey, amount: $amount, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

