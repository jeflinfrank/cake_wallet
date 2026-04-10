#!/bin/bash

set -e  

if [ -z "$APP_ANDROID_TYPE" ]; then
        echo "Please set APP_ANDROID_TYPE"
        exit 1
fi

# Prepare reown dependency
./build_reown_deps.sh
../build_bitbox_flutter.sh

./app_properties.sh
./app_icon.sh
./pubspec_gen.sh
./manifest.sh true #force overwrite manifest
./inject_app_details.sh