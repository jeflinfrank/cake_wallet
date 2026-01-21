import 'package:cw_core/transaction_priority.dart';

class BeldexTransactionPriority extends TransactionPriority {
  const BeldexTransactionPriority({required String title, required int raw})
      : super(title: title, raw: raw);

  static const all = [
    BeldexTransactionPriority.slow,
    BeldexTransactionPriority.automatic,
    BeldexTransactionPriority.medium,
    BeldexTransactionPriority.fast,
    BeldexTransactionPriority.fastest,
  ];
  static const automatic = BeldexTransactionPriority(title: 'Automatic', raw: 0);
  static const slow = BeldexTransactionPriority(title: 'Slow', raw: 1);
  static const medium = BeldexTransactionPriority(title: 'Medium', raw: 2);
  static const fast = BeldexTransactionPriority(title: 'Fast', raw: 3);
  static const fastest = BeldexTransactionPriority(title: 'Fastest', raw: 4);

  static BeldexTransactionPriority deserialize({required int raw}) {
    switch (raw) {
      case 0:
        return automatic;
      case 1:
        return slow;
      case 2:
        return medium;
      case 3:
        return fast;
      case 4:
        return fastest;
      default:
        throw Exception('Unexpected token: $raw for BeldexTransactionPriority deserialize');
    }
  }

  @override
  String toString() {
    switch (this) {
      case BeldexTransactionPriority.slow:
        return 'Slow'; // S.current.transaction_priority_slow;
      case BeldexTransactionPriority.automatic:
        return 'Automatic'; // S.current.transaction_priority_regular;
      case BeldexTransactionPriority.medium:
        return 'Medium'; // S.current.transaction_priority_medium;
      case BeldexTransactionPriority.fast:
        return 'Fast'; // S.current.transaction_priority_fast;
      case BeldexTransactionPriority.fastest:
        return 'Fastest'; // S.current.transaction_priority_fastest;
      default:
        return '';
    }
  }
}
