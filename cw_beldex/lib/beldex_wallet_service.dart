import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:collection/collection.dart';
import 'package:cw_core/get_height_by_date.dart';
import 'package:cw_core/beldex_wallet_utils.dart';
import 'package:cw_core/pathForWallet.dart';
import 'package:cw_core/unspent_coins_info.dart';
import 'package:cw_core/utils/print_verbose.dart';
import 'package:cw_core/wallet_base.dart';
import 'package:cw_core/wallet_credentials.dart';
import 'package:cw_core/wallet_info.dart';
import 'package:cw_core/wallet_service.dart';
import 'package:cw_core/wallet_type.dart';
import 'package:cw_beldex/api/account_list.dart';
import 'package:cw_beldex/api/wallet_manager.dart' as beldex_wallet_manager;
import 'package:cw_beldex/api/wallet_manager.dart';
import 'package:cw_beldex/bip39_seed.dart';
import 'package:cw_beldex/ledger.dart';
import 'package:cw_beldex/beldex_wallet.dart';
import 'package:hive/hive.dart';
import 'package:ledger_flutter_plus/ledger_flutter_plus.dart';
import 'package:monero/beldex.dart' as beldex;
import 'package:polyseed/polyseed.dart';

enum BeldexSeedType { polyseed, legacy, bip39 }

class BeldexNewWalletCredentials extends WalletCredentials {
  BeldexNewWalletCredentials(
      {required String name,
      required this.language,
      required this.seedType,
      String? password,
      this.passphrase,
      this.mnemonic})
      : super(name: name, password: password);

  final String language;
  final BeldexSeedType seedType;
  final String? passphrase;
  final String? mnemonic;
}

class BeldexRestoreWalletFromHardwareCredentials extends WalletCredentials {
  BeldexRestoreWalletFromHardwareCredentials(
      {required String name,
      required this.ledgerConnection,
      int height = 0,
      String? password})
      : super(name: name, password: password, height: height);
  LedgerConnection ledgerConnection;
}

class BeldexRestoreWalletFromSeedCredentials extends WalletCredentials {
  BeldexRestoreWalletFromSeedCredentials(
      {required String name,
      required this.mnemonic,
      required this.passphrase,
      int height = 0,
      String? password})
      : super(name: name, password: password, height: height);

  final String mnemonic;
  final String passphrase;
}

class BeldexWalletLoadingException implements Exception {
  @override
  String toString() => 'Failure to load the wallet.';
}

class BeldexRestoreWalletFromKeysCredentials extends WalletCredentials {
  BeldexRestoreWalletFromKeysCredentials(
      {required String name,
      required String password,
      required this.language,
      required this.address,
      required this.viewKey,
      required this.spendKey,
      int height = 0})
      : super(name: name, password: password, height: height);

  final String language;
  final String address;
  final String viewKey;
  final String spendKey;
}

enum OpenWalletTry {
  initial,
  cacheRestored,
  cacheRemoved,
}

class BeldexWalletService extends WalletService<
    BeldexNewWalletCredentials,
    BeldexRestoreWalletFromSeedCredentials,
    BeldexRestoreWalletFromKeysCredentials,
    BeldexRestoreWalletFromHardwareCredentials> {
  BeldexWalletService(this.unspentCoinsInfoSource);

  final Box<UnspentCoinsInfo> unspentCoinsInfoSource;

  static bool walletFilesExist(String path) =>
      !File(path).existsSync() && !File('$path.keys').existsSync();

  @override
  WalletType getType() => WalletType.beldex;

  @override
  Future<BeldexWallet> create(BeldexNewWalletCredentials credentials,
      {bool? isTestnet}) async {
    try {
      final path = await pathForWallet(name: credentials.name, type: getType());

      if (credentials.seedType == BeldexSeedType.bip39) {
        return _restoreFromBip39(
          path: path,
          password: credentials.password!,
          mnemonic: credentials.mnemonic ?? getBip39Seed(),
          passphrase: credentials.passphrase,
          walletInfo: credentials.walletInfo!,
        );
      }

      if (credentials.seedType == BeldexSeedType.polyseed) {
        final polyseed = Polyseed.create();
        final lang = PolyseedLang.getByEnglishName(credentials.language);

        if (credentials.passphrase != null)
          polyseed.crypt(credentials.passphrase!);

        final heightOverride = getBeldexHeigthByDate(
            date: DateTime.now().subtract(Duration(days: 2)));

        return _restoreFromPolyseed(path, credentials.password!, polyseed,
            credentials.walletInfo!, lang,
            overrideHeight: heightOverride, passphrase: credentials.passphrase);
      }

      beldex_wallet_manager.createWallet(
          path: path,
          password: credentials.password!,
          language: credentials.language,
          passphrase: credentials.passphrase ?? "");
      final wallet = BeldexWallet(
          walletInfo: credentials.walletInfo!,
          derivationInfo: await credentials.walletInfo!.getDerivationInfo(),
          unspentCoinsInfo: unspentCoinsInfoSource,
          password: credentials.password!);
      await wallet.init();

      return wallet;
    } catch (e) {
      // TODO: Implement Exception for wallet list service.
      printV('BeldexWalletsManager Error: ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<bool> isWalletExit(String name) async {
    try {
      final path = await pathForWallet(name: name, type: getType());
      return beldex_wallet_manager.isWalletExist(path: path);
    } catch (e) {
      // TODO: Implement Exception for wallet list service.
      printV('BeldexWalletsManager Error: $e');
      rethrow;
    }
  }

  @override
  Future<BeldexWallet> openWallet(String name, String password,
      {OpenWalletTry openWalletTry = OpenWalletTry.initial}) async {
    try {
      final path = await pathForWallet(name: name, type: getType());

      if (walletFilesExist(path)) await repairOldAndroidWallet(name);

      await beldex_wallet_manager
          .openWallet(path: path, password: password);
      final walletInfo = await WalletInfo.get(name, getType());
      if (walletInfo == null) {
        throw Exception('Wallet not found');
      }
      final wallet = BeldexWallet(
          walletInfo: walletInfo,
          derivationInfo: await walletInfo.getDerivationInfo(),
          unspentCoinsInfo: unspentCoinsInfoSource,
          password: password);

      if (wallet.isHardwareWallet) {
        wallet.setLedgerConnection(gLedger!);
        gLedger = null;
      }

      await wallet.init();

      return wallet;
    } catch (e) {
      // TODO: Implement Exception for wallet list service.

      switch (openWalletTry) {
        case OpenWalletTry.initial:
          await restoreOrResetWalletFiles(name);
          return await openWallet(name, password, openWalletTry: OpenWalletTry.cacheRestored);
        case OpenWalletTry.cacheRestored:
          await removeCache(name);
          return await openWallet(name, password, openWalletTry: OpenWalletTry.cacheRemoved);
        case OpenWalletTry.cacheRemoved:
          rethrow;
      }
    }
  }

  @override
  Future<void> remove(String wallet) async {
    final path = await pathForWalletDir(name: wallet, type: getType());
    if (openedWalletsByPath["$path/$wallet"] != null) {
      // NOTE: this is realistically only required on windows.
      printV("closing wallet");
      final w = openedWalletsByPath["$path/$wallet"]!;
      final wmaddr = wmPtr.ffiAddress();
      final waddr = w.ffiAddress();
      openedWalletsByPath.remove("$path/$wallet");
      await closeWalletAwaitIfShould(wmaddr, waddr);
      printV("wallet closed");
    }

    final file = Directory(path);
    final isExist = file.existsSync();

    if (isExist) {
      await file.delete(recursive: true);
    }

    final walletInfo = await WalletInfo.get(wallet, getType());
    if (walletInfo == null) {
      throw Exception('Wallet not found');
    }
    await WalletInfo.delete(walletInfo);
  }

  @override
  Future<void> rename(String currentName, String password, String newName) async {
    final currentWalletInfo = await WalletInfo.get(currentName, getType());
    if (currentWalletInfo == null) {
      throw Exception('Wallet not found');
    }
    final currentWallet = BeldexWallet(
      walletInfo: currentWalletInfo,
      derivationInfo: await currentWalletInfo.getDerivationInfo(),
      unspentCoinsInfo: unspentCoinsInfoSource,
      password: password,
    );

    await currentWallet.renameWalletFiles(newName);

    final newWalletInfo = currentWalletInfo;
    newWalletInfo.id = WalletBase.idFor(newName, getType());
    newWalletInfo.name = newName;

    await newWalletInfo.save();
  }

  @override
  Future<BeldexWallet> restoreFromKeys(BeldexRestoreWalletFromKeysCredentials credentials,
      {bool? isTestnet}) async {
    try {
      final path = await pathForWallet(name: credentials.name, type: getType());
      beldex_wallet_manager.restoreWalletFromKeys(
          path: path,
          password: credentials.password!,
          language: credentials.language,
          restoreHeight: credentials.height!,
          address: credentials.address,
          viewKey: credentials.viewKey,
          spendKey: credentials.spendKey);
      final wallet = BeldexWallet(
          walletInfo: credentials.walletInfo!,
          derivationInfo: await credentials.walletInfo!.getDerivationInfo(),
          unspentCoinsInfo: unspentCoinsInfoSource,
          password: credentials.password!);
      await wallet.init();

      return wallet;
    } catch (e) {
      // TODO: Implement Exception for wallet list service.
      printV('BeldexWalletsManager Error: $e');
      rethrow;
    }
  }

  @override
  Future<BeldexWallet> restoreFromHardwareWallet(
      BeldexRestoreWalletFromHardwareCredentials credentials) async {
    try {
      final path = await pathForWallet(name: credentials.name, type: getType());
      final password = credentials.password;
      final height = credentials.height;

      enableLedgerExchange(credentials.ledgerConnection);

      await beldex_wallet_manager.restoreWalletFromHardwareWallet(
          path: path,
          password: password!,
          restoreHeight: height!,
          deviceName: 'Ledger');

      final wallet = BeldexWallet(
          walletInfo: credentials.walletInfo!,
          derivationInfo: await credentials.walletInfo!.getDerivationInfo(),
          unspentCoinsInfo: unspentCoinsInfoSource,
          password: credentials.password!);
      await wallet.init();

      return wallet;
    } catch (e) {
      // TODO: Implement Exception for wallet list service.
      printV('BeldexWalletsManager Error: $e');
      rethrow;
    }
  }

  @override
  Future<BeldexWallet> restoreFromSeed(
      BeldexRestoreWalletFromSeedCredentials credentials,
      {bool? isTestnet}) async {
    // Restore from Polyseed
    try {
      if (Polyseed.isValidSeed(credentials.mnemonic)) {
        return restoreFromPolyseed(credentials);
      }
    } catch (e) {
      printV("Polyseed restore failed: $e");
      rethrow;
    }

    try {
      if (isBip39Seed(credentials.mnemonic)) {
        final path =
            await pathForWallet(name: credentials.name, type: getType());

        return _restoreFromBip39(
          path: path,
          password: credentials.password!,
          mnemonic: credentials.mnemonic,
          walletInfo: credentials.walletInfo!,
          overrideHeight: credentials.height!,
          passphrase: credentials.passphrase,
        );
      }
    } catch (e) {
      printV("Bip39 restore failed: $e");
      rethrow;
    }

    try {
      final path = await pathForWallet(name: credentials.name, type: getType());

      beldex_wallet_manager.restoreWalletFromSeedSync(
          path: path,
          password: credentials.password!,
          passphrase: credentials.passphrase,
          seed: credentials.mnemonic,
          restoreHeight: credentials.height!);
      final wallet = BeldexWallet(
          walletInfo: credentials.walletInfo!,
          derivationInfo: await credentials.walletInfo!.getDerivationInfo(),
          unspentCoinsInfo: unspentCoinsInfoSource,
          password: credentials.password!);
      await wallet.init();

      return wallet;
    } catch (e) {
      // TODO: Implement Exception for wallet list service.
      printV('BeldexWalletsManager Error: $e');
      rethrow;
    }
  }

  Future<BeldexWallet> _restoreFromBip39({
    required String path,
    required String password,
    required String mnemonic,
    required WalletInfo walletInfo,
    String? passphrase,
    int? overrideHeight,
  }) async {
    final derivationInfo = await walletInfo.getDerivationInfo();
    derivationInfo.derivationType = DerivationType.bip39;
    derivationInfo.derivationPath = "m/44'/128'/0'/0/0";
    await derivationInfo.save();

    final legacyMnemonic =
        getLegacySeedFromBip39(mnemonic, passphrase: passphrase ?? "");
    final height =
        overrideHeight ?? getBeldexHeigthByDate(date: DateTime.now());

    walletInfo.isRecovery = true;
    walletInfo.restoreHeight = height;

    beldex_wallet_manager.restoreWalletFromSeedSync(
      path: path,
      password: password,
      passphrase: '',
      seed: legacyMnemonic,
      restoreHeight: height,
    );

    currentWallet!.setCacheAttribute(
        key: "cakewallet.seed.bip39", value: mnemonic);
    currentWallet!.setCacheAttribute(
        key: "cakewallet.passphrase", value: passphrase ?? '');

    currentWallet!.store();

    final wallet = BeldexWallet(
      walletInfo: walletInfo,
      derivationInfo: derivationInfo,
      unspentCoinsInfo: unspentCoinsInfoSource,
      password: password,
    );
    await wallet.init();

    return wallet;
  }

  Future<BeldexWallet> restoreFromPolyseed(
      BeldexRestoreWalletFromSeedCredentials credentials) async {
    try {
      final path = await pathForWallet(name: credentials.name, type: getType());
      final polyseedCoin = PolyseedCoin.POLYSEED_MONERO;
      final lang = PolyseedLang.getByPhrase(credentials.mnemonic);
      final polyseed =
          Polyseed.decode(credentials.mnemonic, lang, polyseedCoin);

      return _restoreFromPolyseed(
          path, credentials.password!, polyseed, credentials.walletInfo!, lang,
          passphrase: credentials.passphrase);
    } catch (e) {
      // TODO: Implement Exception for wallet list service.
      printV('BeldexWalletsManager Error: $e');
      rethrow;
    }
  }

  Future<BeldexWallet> _restoreFromPolyseed(String path, String password,
      Polyseed polyseed, WalletInfo walletInfo, PolyseedLang lang,
      {PolyseedCoin coin = PolyseedCoin.POLYSEED_MONERO,
      int? overrideHeight,
      String? passphrase}) async {
    if (polyseed.isEncrypted == false && (passphrase ?? '') != "") {
      // Fallback to the different passphrase offset method, when a passphrase
      // was provided but the polyseed is not encrypted.
      beldex_wallet_manager.restoreWalletFromPolyseedWithOffset(
          path: path,
          password: password,
          seed: polyseed.encode(lang, coin),
          seedOffset: passphrase ?? '',
          language: "English");

      final wallet = BeldexWallet(
        walletInfo: walletInfo,
        derivationInfo: await walletInfo.getDerivationInfo(),
        unspentCoinsInfo: unspentCoinsInfoSource,
        password: password,
      );
      await wallet.init();

      return wallet;
    }

    if (polyseed.isEncrypted) polyseed.crypt(passphrase ?? '');

    final height = overrideHeight ??
        getBeldexHeigthByDate(date: DateTime.fromMillisecondsSinceEpoch(polyseed.birthday * 1000));
    final spendKey = polyseed.generateKey(coin, 32).toHexString();
    final seed = polyseed.encode(lang, coin);

    walletInfo.isRecovery = true;
    walletInfo.restoreHeight = height;

    beldex_wallet_manager.restoreWalletFromSpendKeySync(
        path: path,
        password: password,
        seed: seed,
        language: lang.nameEnglish,
        restoreHeight: height,
        spendKey: spendKey);


    currentWallet!.setCacheAttribute(key: "cakewallet.seed", value: seed);
    currentWallet!.setCacheAttribute(key: "cakewallet.passphrase", value: passphrase??'');

    final wallet = BeldexWallet(
      walletInfo: walletInfo,
      derivationInfo: await walletInfo.getDerivationInfo(),
      unspentCoinsInfo: unspentCoinsInfoSource,
      password: password,
    );
    await wallet.init();

    return wallet;
  }

  Future<void> repairOldAndroidWallet(String name) async {
    try {
      if (!Platform.isAndroid) return;

      final oldAndroidWalletDirPath = await outdatedAndroidPathForWalletDir(name: name);
      final dir = Directory(oldAndroidWalletDirPath);

      if (!dir.existsSync()) return;

      final newWalletDirPath = await pathForWalletDir(name: name, type: getType());

      dir.listSync().forEach((f) {
        final file = File(f.path);
        final name = f.path.split('/').last;
        final newPath = newWalletDirPath + '/$name';
        final newFile = File(newPath);

        if (!newFile.existsSync()) {
          newFile.createSync();
        }
        newFile.writeAsBytesSync(file.readAsBytesSync());
      });
    } catch (e) {
      printV(e.toString());
    }
  }

  @override
  Future<String> getSeeds(String name, String password, WalletType type) async {
    try {
      final path = await pathForWallet(name: name, type: getType());

      if (walletFilesExist(path)) await repairOldAndroidWallet(name);

      await beldex_wallet_manager
          .openWallet(path: path, password: password);
      final walletInfo = await WalletInfo.get(name, getType());
      if (walletInfo == null) {
        throw Exception('Wallet not found');
      }
      final wallet = BeldexWallet(
        walletInfo: walletInfo,
        derivationInfo: await walletInfo.getDerivationInfo(),
        unspentCoinsInfo: unspentCoinsInfoSource,
        password: password,
      );
      return wallet.seed;
    } catch (_) {
      // if the file couldn't be opened or read
      return '';
    }
  }

  @override
  Future<bool> requireHardwareWalletConnection(String name) async {
    final walletInfo = await WalletInfo.get(name, getType());
    if (walletInfo == null) {
      throw Exception('Wallet not found');
    }
    return walletInfo.isHardwareWallet;
  }
}

Future<void> closeWalletAwaitIfShould(int wmaddr, int waddr) async {
  if (Platform.isWindows) {
    await Isolate.run(() {
      beldex.WalletManager_closeWallet(
          Pointer.fromAddress(wmaddr), Pointer.fromAddress(waddr), true);
      beldex.WalletManager_errorString(Pointer.fromAddress(wmaddr));
    });
  } else {
    unawaited(Isolate.run(() {
      beldex.WalletManager_closeWallet(
          Pointer.fromAddress(wmaddr), Pointer.fromAddress(waddr), true);
      beldex.WalletManager_errorString(Pointer.fromAddress(wmaddr));
    }));
  }
}