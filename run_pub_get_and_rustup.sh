#!/bin/bash

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Running in root project..."
cd "$BASE_DIR" && flutter pub get

echo "Starting flutter pub get for all modules..."

for dir in "$BASE_DIR"/cw_*; do
    if [ -f "$dir/pubspec.yaml" ]; then
        echo "----------------------------------------"
        echo "Running in: $dir"
        (cd "$dir" && flutter pub get)
    fi
done

export RUSTUP_HOME=/usr/local/rustup
export CARGO_HOME=/usr/local/cargo
export TMPDIR=/usr/local/rustup/tmp

mkdir -p $RUSTUP_HOME $CARGO_HOME $TMPDIR

curl https://sh.rustup.rs -sSf | sh -s -- -y

rustup target install aarch64-linux-android

rustup target install armv7-linux-androideabi

rustup target install x86_64-linux-android

echo "Done!"