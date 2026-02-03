import 'package:two_finance_blockchain/blockchain/keys/keys.dart';

class Raffle {
  final String? raffleAddress;
  final String tokenAddress;
  final String title;
  final String description;
  final String imageUrl;
  final String payTokenAddress;
  final String startAmount;
  final int maxTickets;
  final int maxTicketsPerWallet;
  final DateTime endTime;
  final bool paused;

  Raffle({
    this.raffleAddress,
    required this.tokenAddress,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.payTokenAddress,
    required this.startAmount,
    required this.maxTickets,
    required this.maxTicketsPerWallet,
    required this.endTime,
    this.paused = false,
  }) {
    _validateAddress(tokenAddress, "token_address");
    _validateAddress(payTokenAddress, "pay_token_address");
    if (raffleAddress != null) {
      _validateAddress(raffleAddress!, "raffle_address");
    }
  }

  /// Valida se o endereço é uma chave EdDSA válida
  static void _validateAddress(String addr, String label) {
    try {
      KeyManager.validateEDDSAPublicKeyHex(addr.trim());
    } catch (e) {
      throw ArgumentError("Invalid $label '$addr': $e");
    }
  }

  factory Raffle.fromJson(Map<String, dynamic> json) {
    return Raffle(
      raffleAddress: json['raffle_address'] as String?,
      tokenAddress: json['token_address'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String,
      payTokenAddress: json['pay_token_address'] as String,
      startAmount: json['start_amount'] as String,
      maxTickets: json['max_tickets'] as int,
      maxTicketsPerWallet: json['max_tickets_per_wallet'] as int,
      endTime: DateTime.parse(json['end_time'] as String),
      paused: json['paused'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'raffle_address': raffleAddress,
      'token_address': tokenAddress,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'pay_token_address': payTokenAddress,
      'start_amount': startAmount,
      'max_tickets': maxTickets,
      'max_tickets_per_wallet': maxTicketsPerWallet,
      'end_time': endTime.toIso8601String(),
      'paused': paused,
    };
  }

  @override
  String toString() =>
      'Raffle(title: $title, token: $tokenAddress, endTime: $endTime, paused: $paused)';
}
