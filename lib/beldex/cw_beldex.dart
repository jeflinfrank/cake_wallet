part of 'beldex.dart';

class CWBeldexAccountList extends BeldexAccountList {
  CWBeldexAccountList(this._wallet);

  final Object _wallet;

  @override
  @computed
  ObservableList<Account> get accounts {
    final beldexWallet = _wallet as BeldexWallet;
    final accounts = beldexWallet.walletAddresses.accountList.accounts
        .map((acc) => Account(id: acc.id, label: acc.label, balance: acc.balance))
        .toList();
    return ObservableList<Account>.of(accounts);
  }

  @override
  void update(Object wallet) {
    final beldexWallet = wallet as BeldexWallet;
    beldexWallet.walletAddresses.accountList.update();
  }

  @override
  void refresh(Object wallet) {
    final beldexWallet = wallet as BeldexWallet;
    beldexWallet.walletAddresses.accountList.refresh();
  }

  @override
  List<Account> getAll(Object wallet) {
    final beldexWallet = wallet as BeldexWallet;
    return beldexWallet.walletAddresses.accountList
        .getAll()
        .map((acc) => Account(id: acc.id, label: acc.label, balance: acc.balance))
        .toList();
  }

  @override
  Future<void> addAccount(Object wallet, {required String label}) async {
    final beldexWallet = wallet as BeldexWallet;
    beldexWallet.walletAddresses.accountList.addAccount(label: label);
  }

  @override
  Future<void> setLabelAccount(Object wallet,
      {required int accountIndex, required String label}) async {
    final beldexWallet = wallet as BeldexWallet;
    beldexWallet.walletAddresses.accountList
        .setLabelAccount(accountIndex: accountIndex, label: label);
  }
}

class CWBeldexSubaddressList extends BeldexSubaddressList {
  CWBeldexSubaddressList(this._wallet);

  final Object _wallet;

  @override
  @computed
  ObservableList<Subaddress> get subaddresses {
    final beldexWallet = _wallet as BeldexWallet;
    final subAddresses = beldexWallet.walletAddresses.subaddressList.subaddresses
        .map((sub) => Subaddress(
          id: sub.id,
          address: sub.address,
          label: sub.label,
          received: sub.balance??"unknown",
          txCount: sub.txCount??0,
        ))
        .toList();
    return ObservableList<Subaddress>.of(subAddresses);
  }

  @override
  void update(Object wallet, {required int accountIndex}) {
    final beldexWallet = wallet as BeldexWallet;
    beldexWallet.walletAddresses.subaddressList.update(accountIndex: accountIndex);
  }

  @override
  void refresh(Object wallet, {required int accountIndex}) {
    final beldexWallet = wallet as BeldexWallet;
    beldexWallet.walletAddresses.subaddressList.refresh(accountIndex: accountIndex);
  }

  @override
  List<Subaddress> getAll(Object wallet) {
    final beldexWallet = wallet as BeldexWallet;
    return beldexWallet.walletAddresses.subaddressList
        .getAll()
        .map((sub) => Subaddress(
          id: sub.id,
          label: sub.label,
          address: sub.address,
          txCount: sub.txCount??0,
          received: sub.balance??'unknown'))
        .toList();
  }

  @override
  Future<void> addSubaddress(Object wallet,
      {required int accountIndex, required String label}) async {
    final beldexWallet = wallet as BeldexWallet;
    return await beldexWallet.walletAddresses.subaddressList
        .addSubaddress(accountIndex: accountIndex, label: label);
  }

  @override
  Future<void> setLabelSubaddress(Object wallet,
      {required int accountIndex, required int addressIndex, required String label}) async {
    final beldexWallet = wallet as BeldexWallet;
    await beldexWallet.walletAddresses.subaddressList
        .setLabelSubaddress(accountIndex: accountIndex, addressIndex: addressIndex, label: label);
  }
}

class CWBeldexWalletDetails extends BeldexWalletDetails {
  CWBeldexWalletDetails(this._wallet);

  final Object _wallet;

  @computed
  @override
  Account get account {
    final beldexWallet = _wallet as BeldexWallet;
    final acc = beldexWallet.walletAddresses.account;
    return Account(id: acc!.id, label: acc.label, balance: acc.balance);
  }

  @computed
  @override
  BeldexBalance get balance {
    throw Exception('Unimplemented');
    // return BeldexBalance();
    //return BeldexBalance(
    //	fullBalance: balance.fullBalance,
    //	unlockedBalance: balance.unlockedBalance);
  }
}

class CWBeldex extends Beldex {
  @override
  BeldexAccountList getAccountList(Object wallet) => CWBeldexAccountList(wallet);

  @override
  BeldexSubaddressList getSubaddressList(Object wallet) => CWBeldexSubaddressList(wallet);

  @override
  TransactionHistoryBase getTransactionHistory(Object wallet) {
    final beldexWallet = wallet as BeldexWallet;
    return beldexWallet.transactionHistory;
  }

  @override
  BeldexWalletDetails getBeldexWalletDetails(Object wallet) => CWBeldexWalletDetails(wallet);

  @override
  int getHeightByDate({required DateTime date}) => getBeldexHeigthByDate(date: date);

  @override
  TransactionPriority getDefaultTransactionPriority() => BeldexTransactionPriority.automatic;

  @override
  TransactionPriority getBeldexTransactionPrioritySlow() => BeldexTransactionPriority.slow;

  @override
  TransactionPriority getBeldexTransactionPriorityAutomatic() =>
      BeldexTransactionPriority.automatic;

  @override
  TransactionPriority deserializeBeldexTransactionPriority({required int raw}) =>
      BeldexTransactionPriority.deserialize(raw: raw);

  @override
  List<TransactionPriority> getTransactionPriorities() => BeldexTransactionPriority.all;

  @override
  List<String> getBeldexWordList(String language) {
    if (language.startsWith("POLYSEED_")) {
      final lang = language.replaceAll("POLYSEED_", "");
      return PolyseedLang.getByEnglishName(lang).words;
    }
    switch (language.toLowerCase()) {
      case 'english':
        return EnglishMnemonics.words;
      case 'chinese (simplified)':
        return ChineseSimplifiedMnemonics.words;
      case 'dutch':
        return DutchMnemonics.words;
      case 'german':
        return GermanMnemonics.words;
      case 'japanese':
        return JapaneseMnemonics.words;
      case 'portuguese':
        return PortugueseMnemonics.words;
      case 'russian':
        return RussianMnemonics.words;
      case 'spanish':
        return SpanishMnemonics.words;
      case 'french':
        return FrenchMnemonics.words;
      case 'italian':
        return ItalianMnemonics.words;
      default:
        return EnglishMnemonics.words;
    }
  }

  @override
  WalletCredentials createBeldexRestoreWalletFromKeysCredentials(
          {required String name,
          required String spendKey,
          required String viewKey,
          required String address,
          required String password,
          required String language,
          required int height}) =>
      BeldexRestoreWalletFromKeysCredentials(
          name: name,
          spendKey: spendKey,
          viewKey: viewKey,
          address: address,
          password: password,
          language: language,
          height: height);

  @override
  WalletCredentials createBeldexRestoreWalletFromHardwareCredentials({
    required String name,
    required String password,
    required int height,
    required ledger.LedgerConnection ledgerConnection,
  }) =>
      BeldexRestoreWalletFromHardwareCredentials(
          name: name,
          password: password,
          height: height,
          ledgerConnection: ledgerConnection);

  @override
  WalletCredentials createBeldexRestoreWalletFromSeedCredentials(
          {required String name,
          required String password,
          required String passphrase,
          required int height,
          required String mnemonic}) =>
      BeldexRestoreWalletFromSeedCredentials(
          name: name, password: password, passphrase: passphrase, height: height, mnemonic: mnemonic);

  @override
  WalletCredentials createBeldexNewWalletCredentials({
    required String name,
    required String language,
    required int seedType,
    required String? passphrase,
    String? password,
    String? mnemonic,
  }) =>
      BeldexNewWalletCredentials(
        name: name,
        password: password,
        language: language,
        seedType: seedType == 1
            ? BeldexSeedType.polyseed
            : (seedType == 3 ? BeldexSeedType.bip39 : BeldexSeedType.legacy),
        passphrase: passphrase,
        mnemonic: mnemonic,
      );

  @override
  Map<String, String> getKeys(Object wallet) {
    final beldexWallet = wallet as BeldexWallet;
    final keys = beldexWallet.keys;
    return <String, String>{
      'primaryAddress': keys.primaryAddress,
      'privateSpendKey': keys.privateSpendKey,
      'privateViewKey': keys.privateViewKey,
      'publicSpendKey': keys.publicSpendKey,
      'publicViewKey': keys.publicViewKey,
      'passphrase': keys.passphrase
    };
  }

  @override
  int? getRestoreHeight(Object wallet) {
    final beldexWallet = wallet as BeldexWallet;
    return beldexWallet.restoreHeight;
  }

  @override
  Object createBeldexTransactionCreationCredentials(
          {required List<Output> outputs, required TransactionPriority priority}) =>
      BeldexTransactionCreationCredentials(
          outputs: outputs
              .map((out) => OutputInfo(
                  fiatAmount: out.fiatAmount,
                  cryptoAmount: out.cryptoAmount,
                  address: out.address,
                  note: out.note,
                  sendAll: out.sendAll,
                  extractedAddress: out.extractedAddress,
                  isParsedAddress: out.isParsedAddress,
                  formattedCryptoAmount: out.formattedCryptoAmount))
              .toList(),
          priority: priority as BeldexTransactionPriority);

  @override
  Object createBeldexTransactionCreationCredentialsRaw(
          {required List<OutputInfo> outputs, required TransactionPriority priority}) =>
      BeldexTransactionCreationCredentials(
          outputs: outputs, priority: priority as BeldexTransactionPriority);

  @override
  String formatterBeldexAmountToString({required int amount}) =>
      beldexAmountToString(amount: amount);

  @override
  double formatterBeldexAmountToDouble({required int amount}) =>
      beldexAmountToDouble(amount: amount);

  @override
  int formatterBeldexParseAmount({required String amount}) => beldexParseAmount(amount: amount);

  @override
  Account getCurrentAccount(Object wallet) {
    final beldexWallet = wallet as BeldexWallet;
    final acc = beldexWallet.walletAddresses.account;
    return Account(id: acc!.id, label: acc.label, balance: acc.balance);
  }

  @override
  void setCurrentAccount(Object wallet, int id, String label, String? balance) {
    final beldexWallet = wallet as BeldexWallet;
    beldexWallet.walletAddresses.account =
        beldex_account.Account(id: id, label: label, balance: balance);
  }

  @override
  void onStartup() => beldex_wallet_api.onStartup();

  @override
  int getTransactionInfoAccountId(TransactionInfo tx) {
    final beldexTransactionInfo = tx as BeldexTransactionInfo;
    return beldexTransactionInfo.accountIndex;
  }

  @override
  WalletService createBeldexWalletService(Box<UnspentCoinsInfo> unspentCoinSource) =>
      BeldexWalletService(unspentCoinSource);

  @override
  String getTransactionAddress(Object wallet, int accountIndex, int addressIndex) {
    final beldexWallet = wallet as BeldexWallet;
    return beldexWallet.getTransactionAddress(accountIndex, addressIndex);
  }

  @override
  String getSubaddressLabel(Object wallet, int accountIndex, int addressIndex) {
    final beldexWallet = wallet as BeldexWallet;
    return beldexWallet.getSubaddressLabel(accountIndex, addressIndex);
  }

  @override
  Map<String, String> pendingTransactionInfo(Object transaction) {
    final ptx = transaction as PendingBeldexTransaction;
    return {'id': ptx.id, 'hex': ptx.hex};
  }

  @override
  List<Unspent> getUnspents(Object wallet) {
    final beldexWallet = wallet as BeldexWallet;
    return beldexWallet.unspentCoins;
  }

  @override
  Future<void> updateUnspents(Object wallet) async {
    final beldexWallet = wallet as BeldexWallet;
    await beldexWallet.updateUnspent();
  }

  @override
  Future<int> getCurrentHeight() async {
    return beldex_wallet_api.getCurrentHeight();
  }
  
  @override
  bool importKeyImagesUR(Object wallet, String ur) {
    final beldexWallet = wallet as BeldexWallet;
    return beldexWallet.importKeyImagesUR(ur);
  }


  @override
  Future<bool> commitTransactionUR(Object wallet, String ur) {
    final beldexWallet = wallet as BeldexWallet;
    return beldexWallet.submitTransactionUR(ur);
  }

  @override
  Map<String, String> exportOutputsUR(Object wallet) {
    final beldexWallet = wallet as BeldexWallet;
    return beldexWallet.exportOutputsUR();
  }

  @override
  bool needExportOutputs(Object wallet, int amount) {
    final beldexWallet = wallet as BeldexWallet;
    return beldexWallet.needExportOutputs(amount);
  }

  @override
  void beldexcCheck() {
    checkIfMoneroCIsFine();
  }

  @override
  Future<void> setLedgerConnection(Object wallet, ledger.LedgerConnection connection) async {
    final beldexWallet = wallet as BeldexWallet;
    await beldexWallet.setLedgerConnection(connection);
  }

  @override
  void resetLedgerConnection() {
    disableLedgerExchange();
  }

  @override
  void setGlobalLedgerConnection(ledger.LedgerConnection connection) {
    gLedger = connection;
  }

  @override
  String? getLastLedgerCommand() => latestLedgerCommand;

  bool isViewOnly() {
    return isViewOnlyBySpendKey(null);
  }

  @override
  Map<String, List<int>> debugCallLength() {
    return beldex_wallet_api.debugCallLength();
  }

  @override
  Map<String, dynamic> getWalletCacheDebug() {
    return beldex_wallet_api.getWalletCacheDebug();
  }
}
