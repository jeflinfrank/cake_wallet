import 'package:cw_core/wallet_base.dart';
import 'package:cw_core/wallet_type.dart';
import 'package:mobx/mobx.dart';
import 'package:cake_wallet/core/execution_state.dart';
import 'package:cake_wallet/beldex/beldex.dart';
import 'package:cake_wallet/view_model/monero_account_list/account_list_item.dart';

part 'beldex_account_edit_or_create_view_model.g.dart';

class BeldexAccountEditOrCreateViewModel = BeldexAccountEditOrCreateViewModelBase
    with _$BeldexAccountEditOrCreateViewModel;

abstract class BeldexAccountEditOrCreateViewModelBase with Store {
  BeldexAccountEditOrCreateViewModelBase(this._beldexAccountList,
      {required WalletBase wallet, AccountListItem? accountListItem})
      : state = InitialExecutionState(),
        isEdit = accountListItem != null,
        label = accountListItem?.label??'',
        _accountListItem = accountListItem,
        _wallet = wallet;

  final bool isEdit;

  @observable
  ExecutionState state;

  @observable
  String label;

  final BeldexAccountList _beldexAccountList;

  final AccountListItem? _accountListItem;
  final WalletBase _wallet;

  Future<void> save() async {
    if (_wallet.type == WalletType.beldex) {
      await saveBeldex();
    }
  }

  Future<void> saveBeldex() async {
    try {
      state = IsExecutingState();

      if (_accountListItem != null) {
        await _beldexAccountList.setLabelAccount(
            _wallet,
            accountIndex: _accountListItem.id,
            label: label);
      } else {
        await _beldexAccountList.addAccount(
          _wallet,
          label: label);
      }

      await _wallet.save();
      state = ExecutedSuccessfullyState();
    } catch (e) {
      state = FailureState(e.toString());
    }
  }

}
