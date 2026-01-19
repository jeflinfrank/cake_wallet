git submodule update --init --recursive
# docker build -t ghcr.io/cake-tech/cake_wallet:debian13-flutter3.32.0-ndkr28-go1.24.1-ruststablenightly . # Uncomment to build the docker image yourself instead of pulling it from the registry
docker run --privileged -v$(pwd):$(pwd) -w $(pwd) -i --rm -e CC=gcc -e CXX=g++ ghcr.io/cake-tech/cake_wallet:debian13-flutter3.32.0-ndkr28-go1.24.1-ruststablenightly bash -x << EOF
set -x -e
pushd scripts
    ./gen_android_manifest.sh
    ./prepare_torch.sh
    ./prepare_reown.sh
    ./build_bitbox_flutter.sh
popd
pushd scripts/linux
    source ./app_env.sh cakewallet
    # source ./app_env.sh monero.com # Uncomment this line to build monero.com
    ./app_config.sh
    ./build_monero_all.sh
popd

flutter clean
./model_generator.sh
dart run tool/generate_localization.dart
dart run tool/generate_new_secrets.dart



flutter pub get
apt-get update
apt-get install -y ca-certificates git
update-ca-certificates
git config --global http.sslBackend openssl
pushd scripts/android 
    ./build_mwebd.sh 
popd
dart run ffigen --config cw_mweb/ffigen_config.yaml
flutter pub get
dart run ffigen --config scripts/bitbox_flutter/ffigen_config.yaml

flutter build linux
cp -r build/linux/x64 build/linux/current
# use line below if you are building on arm64
# cp -r build/linux/arm64 build/linux/current
# If you want to build flatpak you need --privileged flag
flatpak-builder --force-clean flatpak-build com.cakewallet.CakeWallet.yml
flatpak build-export export flatpak-build
flatpak build-bundle export build/linux/current/cake_wallet.flatpak com.cakewallet.CakeWallet
EOF