#!/bin/bash

set -x -e

cd "$(dirname "$0")"

if [[ ! -d "monero_c/.git" ]];
then
    rm -rf monero_c
    git clone https://github.com/MogamboPuri/monero_c --branch develop monero_c
    cd monero_c
    # NOTE: Make sure to update monero_c prebuilds link in workflow files
    # https://github.com/MrCyjaneK/monero_c/releases/download/v0.18.4.0-RC9/release-bundle.zip
    git checkout 42c2a28d4496c7ef27723dcf137f9d75f53ea6de
    git reset --hard
    git submodule update --init --force --recursive
    ./apply_patches.sh monero
    ./apply_patches.sh wownero
    ./apply_patches.sh zano
    ./apply_patches.sh beldex
else
    cd monero_c
fi

for coin in monero wownero zano beldex;
do
    if [[ ! -f "$coin/.patch-applied" ]];
    then
        ./apply_patches.sh $coin
    fi
done
cd ..

echo "monero_c source prepared".
