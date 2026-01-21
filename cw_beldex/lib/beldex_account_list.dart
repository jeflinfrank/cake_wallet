import 'package:cw_core/beldex_amount_format.dart';
import 'package:cw_core/utils/print_verbose.dart';
import 'package:cw_beldex/api/wallet_manager.dart';
import 'package:mobx/mobx.dart';
import 'package:cw_core/account.dart';
import 'package:cw_beldex/api/account_list.dart' as account_list;
import 'package:monero/src/beldex.dart';

part 'beldex_account_list.g.dart';

class BeldexAccountList = BeldexAccountListBase with _$BeldexAccountList;

abstract class BeldexAccountListBase with Store {
  BeldexAccountListBase()
    : accounts = ObservableList<Account>(),
      _isRefreshing = false,
      _isUpdating = false {
    refresh();
  }

  @observable
  ObservableList<Account> accounts;
  bool _isRefreshing;
  bool _isUpdating;

  void update() async {
    if (_isUpdating) {
      return;
    }

    try {
      _isUpdating = true;
      refresh();
      final accounts = getAll();

      if (accounts.isNotEmpty) {
        this.accounts.clear();
        this.accounts.addAll(accounts);
      }

      _isUpdating = false;
    } catch (e) {
      _isUpdating = false;
      rethrow;
    }
  }

  static Map<int, List<Account>> cachedAccounts = {};

  List<Account> getAll() {
    final allAccounts = account_list.getAllAccount();
    final currentCount = allAccounts.length;
    cachedAccounts[account_list.currentWallet!.ffiAddress()] ??= [];

    if (cachedAccounts[account_list.currentWallet!.ffiAddress()]!.length ==
        currentCount) {
      return cachedAccounts[account_list.currentWallet!.ffiAddress()]!;
    }

    cachedAccounts[account_list.currentWallet!.ffiAddress()] =
        allAccounts.map((accountRow) {
          final balance = accountRow.getUnlockedBalance();

          return Account(
            id: accountRow.getRowId(),
            label: accountRow.getLabel(),
            balance: beldexAmountToString(
              amount: account_list.currentWallet!.amountFromString(balance),
            ),
          );
        }).toList();

    return cachedAccounts[account_list.currentWallet!.ffiAddress()]!;
  }

  void addAccount({required String label}) {
    account_list.addAccount(label: label);
    update();
  }

  void setLabelAccount({required int accountIndex, required String label}) {
    account_list.setLabelForAccount(accountIndex: accountIndex, label: label);
    update();
  }

  void refresh() {
    if (_isRefreshing) {
      return;
    }

    try {
      _isRefreshing = true;
      account_list.refreshAccounts();
      _isRefreshing = false;
    } catch (e) {
      _isRefreshing = false;
      printV(e);
      rethrow;
    }
  }
}
