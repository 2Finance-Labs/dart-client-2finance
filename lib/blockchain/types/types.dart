
import 'package:two_finance_blockchain/blockchain/log/log.dart';

const String DEPLOY_CONTRACT_ADDRESS = "0x000000000000000000000000000000000000000000000000000000000000";

class StateType {
  final String? type;
  final Map<String, dynamic>? object;

  StateType({this.type, this.object});

  factory StateType.fromJson(Map<String, dynamic> json) {
    return StateType(
      type: json['type'] as String?,
      object: json['object'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (type != null) 'type': type,
      if (object != null) 'object': object,
    };
  }
}

class ContractOutput {
  final List<StateType>? states;
  final List<Log>? logs;
  final List<ContractOutput>? delegatedCall;

  ContractOutput({this.states, this.logs, this.delegatedCall});

  factory ContractOutput.fromJson(Map<String, dynamic> json) {
    return ContractOutput(
      states: (json['states'] as List<dynamic>?)
          ?.map((e) => StateType.fromJson(e as Map<String, dynamic>))
          .toList(),
      logs: (json['logs'] as List<dynamic>?)
          ?.map((e) => Log.fromJson(e as Map<String, dynamic>))
          .toList(),
      delegatedCall: (json['delegated_call'] as List<dynamic>?)
          ?.map((e) => ContractOutput.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (states != null) 'states': states!.map((s) => s.toJson()).toList(),
      if (logs != null) 'logs': logs!.map((l) => l.toJson()).toList(),
      if (delegatedCall != null)
        'delegated_call': delegatedCall!.map((c) => c.toJson()).toList(),
    };
  }
}
