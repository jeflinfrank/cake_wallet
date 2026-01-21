import 'dart:core';
import 'package:mobx/mobx.dart';
import 'package:cw_core/transaction_history.dart';
import 'package:cw_beldex/beldex_transaction_info.dart';

part 'beldex_transaction_history.g.dart';

class BeldexTransactionHistory = BeldexTransactionHistoryBase
    with _$BeldexTransactionHistory;

abstract class BeldexTransactionHistoryBase
    extends TransactionHistoryBase<BeldexTransactionInfo>
    with Store {
  BeldexTransactionHistoryBase() {
    transactions = ObservableMap<String, BeldexTransactionInfo>();
  }

  @override
  Future<void> save() async {}

  @override
  void addOne(BeldexTransactionInfo transaction) =>
      transactions[transaction.id] = transaction;

  @override
  void addMany(Map<String, BeldexTransactionInfo> transactions) =>
      this.transactions.addAll(transactions);
}
