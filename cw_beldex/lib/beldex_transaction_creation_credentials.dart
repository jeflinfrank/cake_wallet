import 'package:cw_core/beldex_transaction_priority.dart';
import 'package:cw_core/output_info.dart';

class BeldexTransactionCreationCredentials {
  BeldexTransactionCreationCredentials({
    required this.outputs,
    required this.priority,
  });
  final List<OutputInfo> outputs;
  final BeldexTransactionPriority priority;
}
