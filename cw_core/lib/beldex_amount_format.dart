import 'package:intl/intl.dart';
import 'package:cw_core/crypto_amount_format.dart';

const beldexAmountLength = 9;
const beldexAmountDivider = 1000000000;
final beldexAmountFormat = NumberFormat()
  ..maximumFractionDigits = beldexAmountLength
  ..minimumFractionDigits = 1;

String beldexAmountToString({required int amount}) => beldexAmountFormat
    .format(cryptoAmountToDouble(amount: amount, divider: beldexAmountDivider))
    .replaceAll(',', '');

double beldexAmountToDouble({required int amount}) =>
    cryptoAmountToDouble(amount: amount, divider: beldexAmountDivider);
int beldexParseAmount({required String amount}) =>
    (double.parse(amount) * beldexAmountDivider).round();