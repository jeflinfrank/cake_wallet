import 'package:cw_core/unspent_transaction_output.dart';
import 'package:cw_core/unspent_coins_info.dart';
import 'package:mobx/mobx.dart';
import 'package:cw_core/wallet_credentials.dart';
import 'package:cw_core/wallet_info.dart';
import 'package:cw_core/transaction_priority.dart';
import 'package:cw_core/transaction_history.dart';
import 'package:cw_core/transaction_info.dart';
import 'package:cw_core/balance.dart';
import 'package:cw_core/output_info.dart';
import 'package:cake_wallet/view_model/send/output.dart';
import 'package:cw_core/wallet_service.dart';
import 'package:hive/hive.dart';
import 'package:ledger_flutter_plus/ledger_flutter_plus.dart' as ledger;
import 'package:polyseed/polyseed.dart';


Beldex? beldex;

class Account {
  Account({required this.id, required this.label, this.balance});
  final int id;
  final String label;
  final String? balance;
}

class Subaddress {
  Subaddress({
    required this.id,
    required this.label,
    required this.address,
    required this.received,
    required this.txCount});
  final int id;
  final String label;
  final String address;
  final String? received;
  final int txCount;
}

class BeldexBalance extends Balance {
  BeldexBalance({required this.fullBalance, required this.unlockedBalance})
      : formattedFullBalance = beldex!.formatterBeldexAmountToString(amount: fullBalance),
        formattedUnlockedBalance =
            beldex!.formatterBeldexAmountToString(amount: unlockedBalance),
        super(unlockedBalance, fullBalance);

  BeldexBalance.fromString(
      {required this.formattedFullBalance,
      required this.formattedUnlockedBalance})
      : fullBalance = beldex!.formatterBeldexParseAmount(amount: formattedFullBalance),
        unlockedBalance = beldex!.formatterBeldexParseAmount(amount: formattedUnlockedBalance),
        super(beldex!.formatterBeldexParseAmount(amount: formattedUnlockedBalance),
            beldex!.formatterBeldexParseAmount(amount: formattedFullBalance));

  final int fullBalance;
  final int unlockedBalance;
  final String formattedFullBalance;
  final String formattedUnlockedBalance;

  @override
  String get formattedAvailableBalance => formattedUnlockedBalance;

  @override
  String get formattedAdditionalBalance => formattedFullBalance;
}

abstract class BeldexWalletDetails {
  @observable
  late Account account;

  @observable
  late BeldexBalance balance;
}

abstract class Beldex {
  BeldexAccountList getAccountList(Object wallet);

  BeldexSubaddressList getSubaddressList(Object wallet);

  TransactionHistoryBase getTransactionHistory(Object wallet);

  BeldexWalletDetails getBeldexWalletDetails(Object wallet);
  String getTransactionAddress(Object wallet, int accountIndex, int addressIndex);

  String getSubaddressLabel(Object wallet, int accountIndex, int addressIndex);

  int getHeightByDate({required DateTime date});
  TransactionPriority getDefaultTransactionPriority();
  TransactionPriority getBeldexTransactionPrioritySlow();
  TransactionPriority getBeldexTransactionPriorityAutomatic();
  TransactionPriority deserializeBeldexTransactionPriority({required int raw});
  List<TransactionPriority> getTransactionPriorities();
  List<String> getBeldexWordList(String language);
  
  List<Unspent> getUnspents(Object wallet);
  Future<void> updateUnspents(Object wallet);

  Future<int> getCurrentHeight();

  Future<bool> commitTransactionUR(Object wallet, String ur);

  Map<String, String> exportOutputsUR(Object wallet);

  bool needExportOutputs(Object wallet, int amount);

  bool importKeyImagesUR(Object wallet, String ur);

  WalletCredentials createBeldexRestoreWalletFromKeysCredentials({
    required String name,
    required String spendKey,
    required String viewKey,
    required String address,
    required String password,
    required String language,
    required int height});
  WalletCredentials createBeldexRestoreWalletFromSeedCredentials({required String name, required String password, required String passphrase, required int height, required String mnemonic});
  WalletCredentials createBeldexRestoreWalletFromHardwareCredentials({required String name, required String password, required int height, required ledger.LedgerConnection ledgerConnection});
WalletCredentials createBeldexNewWalletCredentials({required String name, required String language, required int seedType, required String? passphrase, String? password, String? mnemonic});
  Map<String, String> getKeys(Object wallet);
  int? getRestoreHeight(Object wallet);
  Object createBeldexTransactionCreationCredentials({required List<Output> outputs, required TransactionPriority priority});
  Object createBeldexTransactionCreationCredentialsRaw({required List<OutputInfo> outputs, required TransactionPriority priority});
  String formatterBeldexAmountToString({required int amount});
  double formatterBeldexAmountToDouble({required int amount});
  int formatterBeldexParseAmount({required String amount});
  Account getCurrentAccount(Object wallet);
  void monerocCheck();
  bool isViewOnly();
  void setCurrentAccount(Object wallet, int id, String label, String? balance);
  void onStartup();
  int getTransactionInfoAccountId(TransactionInfo tx);
  WalletService createBeldexWalletService(Box<UnspentCoinsInfo> unspentCoinSource);
  Map<String, String> pendingTransactionInfo(Object transaction);
  Future<void> setLedgerConnection(Object wallet, ledger.LedgerConnection connection);
  void resetLedgerConnection();
  void setGlobalLedgerConnection(ledger.LedgerConnection connection);
  String? getLastLedgerCommand();
  Map<String, List<int>> debugCallLength();
  Map<String, dynamic> getWalletCacheDebug();
}

abstract class BeldexSubaddressList {
  ObservableList<Subaddress> get subaddresses;
  void update(Object wallet, {required int accountIndex});
  void refresh(Object wallet, {required int accountIndex});
  List<Subaddress> getAll(Object wallet);
  Future<void> addSubaddress(Object wallet, {required int accountIndex, required String label});
  Future<void> setLabelSubaddress(Object wallet,
      {required int accountIndex, required int addressIndex, required String label});
}

abstract class BeldexAccountList {
  ObservableList<Account> get accounts;
  void update(Object wallet);
  void refresh(Object wallet);
  List<Account> getAll(Object wallet);
  Future<void> addAccount(Object wallet, {required String label});
  Future<void> setLabelAccount(Object wallet, {required int accountIndex, required String label});
}
  