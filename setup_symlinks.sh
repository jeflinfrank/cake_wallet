#!/bin/bash

set -e

# Get project root (where script is run)
PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"

# Define paths relative to project
SRC_DIR="$PROJECT_ROOT/scripts/monero_c/release/beldex"
DEST_DIR="$PROJECT_ROOT/android/app/src/main/jniLibs"

echo "Using source: $SRC_DIR"
echo "Using destination: $DEST_DIR"

# Remove old symlinks if they exist
rm -f "$DEST_DIR/arm64-v8a/libbeldex_libwallet2_api_c.so"
rm -f "$DEST_DIR/armeabi-v7a/libbeldex_libwallet2_api_c.so"
rm -f "$DEST_DIR/x86_64/libbeldex_libwallet2_api_c.so"

# Create symlinks
if [ ! -f "$SRC_DIR/aarch64-linux-android_libwallet2_api_c.so" ]; then
  echo ":x: Missing compiled libraries. Build monero_c first."
  exit 1
fi
ln -s "$SRC_DIR/aarch64-linux-android_libwallet2_api_c.so" \
      "$DEST_DIR/arm64-v8a/libbeldex_libwallet2_api_c.so"

if [ ! -f "$SRC_DIR/armv7a-linux-androideabi_libwallet2_api_c.so" ]; then
  echo ":x: Missing compiled libraries. Build monero_c first."
  exit 1
fi
ln -s "$SRC_DIR/armv7a-linux-androideabi_libwallet2_api_c.so" \
      "$DEST_DIR/armeabi-v7a/libbeldex_libwallet2_api_c.so"

if [ ! -f "$SRC_DIR/x86_64-linux-android_libwallet2_api_c.so" ]; then
  echo ":x: Missing compiled libraries. Build monero_c first."
  exit 1
fi
ln -s "$SRC_DIR/x86_64-linux-android_libwallet2_api_c.so" \
      "$DEST_DIR/x86_64/libbeldex_libwallet2_api_c.so"

echo ":white_check_mark: Symlinks created successfully"