docker run -v$(pwd):$(pwd) -w $(pwd) -i --rm ghcr.io/cake-tech/cake_wallet:debian13-flutter3.32.0-ndkr28-go1.24.1-ruststablenightly bash -x << EOF
set -x -e
pushd scripts/android
    ./build_torch.sh
    source ./app_env.sh cakewallet
    # source ./app_env.sh monero.com # Uncomment this line to build monero.com
    ./app_config.sh
    ./build_monero_all.sh
    ./build_decred.sh
    ./build_mwebd.sh
popd
pushd android/app
    [[ -f key.jks ]] || keytool -genkey -v -keystore key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias testKey -noprompt -dname "CN=CakeWallet, OU=CakeWallet, O=CakeWallet, L=Florida, S=America, C=USA" -storepass hunter1 -keypass hunter1
popd
flutter clean
./model_generator.sh
dart run tool/generate_android_key_properties.dart keyAlias=testKey storeFile=key.jks storePassword=hunter1 keyPassword=hunter1
dart run tool/generate_localization.dart
dart run tool/generate_new_secrets.dart
./run_pub_get_and_rustup.sh
./setup_symlinks.sh
flutter build apk --release --split-per-abi