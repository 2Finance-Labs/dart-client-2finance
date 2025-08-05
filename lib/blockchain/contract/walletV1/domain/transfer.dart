//transfer.go

import 'package:two_finance_blockchain/blockchain/contract/walletV1/domain/wallet.dart' show Wallet;

class Transfer {
  final String amount;
  final String from;
  final String to;
  final Wallet walletSender;
  final Wallet walletReceiver;
  // final BigInt? gasFeeTotalWei; // Para representar *big.Int do Go, se precisar

  Transfer({
    required this.amount,
    required this.from,
    required this.to,
    required this.walletSender,
    required this.walletReceiver,
    // this.gasFeeTotalWei, // Inclua se o campo for usado
  });

  factory Transfer.fromJson(Map<String, dynamic> json) {
    return Transfer(
      amount: json['amount'] as String,
      from: json['from'] as String,
      to: json['to'] as String,
      walletSender: Wallet.fromJson(json['walletSender'] as Map<String, dynamic>),
      walletReceiver: Wallet.fromJson(json['walletReceiver'] as Map<String, dynamic>),
      // gasFeeTotalWei: json['gas_fee_total_wei'] != null
      //     ? BigInt.parse(json['gas_fee_total_wei'] as String) // Exemplo: se vier como string
      //     : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'from': from,
      'to': to,
      'walletSender': walletSender.toJson(),
      'walletReceiver': walletReceiver.toJson(),
      // 'gas_fee_total_wei': gasFeeTotalWei?.toString(), // Converte BigInt para string, se necessário
    };
  }

  @override
  String toString() =>
      'Transfer(amount: $amount, from: $from, to: $to, walletSender: $walletSender, walletReceiver: $walletReceiver)';

}