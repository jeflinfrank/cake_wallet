import 'dart:async';

import 'package:cw_beldex/api/account_list.dart';
import 'package:cw_beldex/api/structs/pending_transaction.dart';
import 'package:cw_beldex/api/transaction_history.dart'
    as beldex_transaction_history;
import 'package:cw_core/crypto_currency.dart';
import 'package:cw_core/amount_converter.dart';

import 'package:cw_core/pending_transaction.dart';
import 'package:cw_beldex/api/wallet.dart';
import 'package:cw_beldex/beldex_wallet.dart';

class DoubleSpendException implements Exception {
  DoubleSpendException();

  @override
  String toString() =>
      'This transaction cannot be committed. This can be due to many reasons including the wallet not being synced, there is not enough BDX in your available balance, or previous transactions are not yet fully processed.';
}

class PendingBeldexTransaction with PendingTransaction {
  PendingBeldexTransaction(this.pendingTransactionDescription, this.wallet);

  final PendingTransactionDescription pendingTransactionDescription;
  final BeldexWalletBase wallet;

  @override
  String get id => pendingTransactionDescription.hash;

  @override
  String get hex => pendingTransactionDescription.hex;

  @override
  String get amountFormatted => AmountConverter.amountIntToString(
    CryptoCurrency.bdx,
    pendingTransactionDescription.amount,
  );

  @override
  String get feeFormatted => "$feeFormattedValue BDX";

  @override
  String get feeFormattedValue => AmountConverter.amountIntToString(
    CryptoCurrency.bdx,
    pendingTransactionDescription.fee,
  );
  @override
  bool shouldCommitUR() => isViewOnly;

  @override
  Future<void> commit() async {
    try {
      await beldex_transaction_history.commitTransactionFromPointerAddress(
        address: pendingTransactionDescription.pointerAddress,
        useUR: false,
      );
    } catch (e) {
      final message = e.toString();

      if (message.contains('Reason: double spend')) {
        throw DoubleSpendException();
      }

      rethrow;
    }
    storeSync(force: true);
    unawaited(() async {
      await Future.delayed(const Duration(milliseconds: 250));
      await wallet.fetchTransactions();
    }());
  }

  @override
  Future<Map<String, String>> commitUR() async {
    try {
      final ret = await beldex_transaction_history
          .commitTransactionFromPointerAddress(
            address: pendingTransactionDescription.pointerAddress,
            useUR: true,
          );
      storeSync(force: true);
      unawaited(() async {
        await Future.delayed(const Duration(milliseconds: 250));
        await wallet.fetchTransactions();
      }());
      if (ret == null) return {};
      return {"bdx-txsigned": ret};
    } catch (e) {
      final message = e.toString();

      if (message.contains('Reason: double spend')) {
        throw DoubleSpendException();
      }

      rethrow;
    }
  }
}
