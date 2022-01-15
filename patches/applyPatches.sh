#!/usr/bin/env bash

# Apply patches to other repos
# Needs to be run from within repo and with envsetup sourced

set -euo pipefail

PATCH_ROOT="$ANDROID_BUILD_TOP/device/sony/lilac/patches"

for p in "$PATCH_ROOT/"*.patch; do
    patch_dir=$(head -n1 "$p" | grep "# PWD: " | awk '{print $NF}')
    if [[ "$patch_dir" == "" ]]; then
        echo "Faulty patch: $p"
        exit 1
    fi
    patch --forward -r /dev/null --no-backup-if-mismatch -p1 -d "$patch_dir" < "$p" || true
done

echo "Done."
