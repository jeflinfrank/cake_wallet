# cw_beldex

Beldex wallet module for Cake Wallet, backed by native bindings to Beldex’s wallet library and high-level Dart wrappers.

## Features

- Create/open/restore Beldex wallets; manage accounts and subaddresses.
- Build/sign/broadcast transactions; track history and unspent outputs.
- Ledger hardware wallet support.
- Exception types for common wallet operations.

## Usage

See `lib/api/wallet.dart`, `wallet_manager.dart`, and high-level wrappers like `beldex_wallet.dart` and `beldex_wallet_service.dart` in the app for examples of creating and managing wallets.