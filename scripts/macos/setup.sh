#!/bin/sh

. ./config.sh

cd $EXTERNAL_MACOS_LIB_DIR


# LIBRANDOMX_PATH=${EXTERNAL_MACOS_LIB_DIR}/monero/librandomx.a

# if [ -f "$LIBRANDOMX_PATH" ]; then
#     cp $LIBRANDOMX_PATH ./haven
# fi

libtool -static -o libboost.a ./libboost_*.a
libtool -static -o libmonero.a ./monero/*.a
libtool -static -o libbeldex.a ./beldex/*.a

# CW_HAVEN_EXTERNAL_LIB=../../../../../cw_haven/macos/External/macos/lib
# CW_HAVEN_EXTERNAL_INCLUDE=../../../../../cw_haven/macos/External/macos/include
CW_MONERO_EXTERNAL_LIB=../../../../../cw_monero/macos/External/macos/lib
CW_MONERO_EXTERNAL_INCLUDE=../../../../../cw_monero/macos/External/macos/include

CW_BELDEX_EXTERNAL_LIB=../../../../../cw_beldex/macos/External/macos/lib
CW_BELDEX_EXTERNAL_INCLUDE=../../../../../cw_beldex/macos/External/macos

# mkdir -p $CW_HAVEN_EXTERNAL_INCLUDE
mkdir -p $CW_MONERO_EXTERNAL_INCLUDE
# mkdir -p $CW_HAVEN_EXTERNAL_LIB
mkdir -p $CW_MONERO_EXTERNAL_LIB

# mkdir -p $CW_BELDEX_EXTERNAL_INCLUDE
mkdir -p $CW_BELDEX_EXTERNAL_INCLUDE
# mkdir -p $CW_BELDEX_EXTERNAL_LIB
mkdir -p $CW_BELDEX_EXTERNAL_LIB

# ln ./libboost.a ${CW_HAVEN_EXTERNAL_LIB}/libboost.a
# ln ./libcrypto.a ${CW_HAVEN_EXTERNAL_LIB}/libcrypto.a
# ln ./libssl.a ${CW_HAVEN_EXTERNAL_LIB}/libssl.a
# ln ./libsodium.a ${CW_HAVEN_EXTERNAL_LIB}/libsodium.a
# cp ./libhaven.a $CW_HAVEN_EXTERNAL_LIB
# cp ../include/haven/* $CW_HAVEN_EXTERNAL_INCLUDE

ln ./libboost.a ${CW_MONERO_EXTERNAL_LIB}/libboost.a
ln ./libcrypto.a ${CW_MONERO_EXTERNAL_LIB}/libcrypto.a
ln ./libssl.a ${CW_MONERO_EXTERNAL_LIB}/libssl.a
ln ./libsodium.a ${CW_MONERO_EXTERNAL_LIB}/libsodium.a
ln ./libunbound.a ${CW_MONERO_EXTERNAL_LIB}/libunbound.a
cp ./libmonero.a $CW_MONERO_EXTERNAL_LIB
cp ../include/monero/* $CW_MONERO_EXTERNAL_INCLUDE


ln ./libboost.a ${CW_BELDEX_EXTERNAL_LIB}/libboost.a
ln ./libcrypto.a ${CW_BELDEX_EXTERNAL_LIB}/libcrypto.a
ln ./libssl.a ${CW_BELDEX_EXTERNAL_LIB}/libssl.a
ln ./libsodium.a ${CW_BELDEX_EXTERNAL_LIB}/libsodium.a
ln ./libunbound.a ${CW_BELDEX_EXTERNAL_LIB}/libunbound.a
cp ./libbeldex.a $CW_BELDEX_EXTERNAL_LIB
cp ../include/beldex/* $CW_BELDEX_EXTERNAL_INCLUDE