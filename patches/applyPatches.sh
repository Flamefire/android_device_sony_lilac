#!/usr/bin/env bash

# Apply patches to other repos
# Needs to be run from within repo and with envsetup sourced

set -euo pipefail

function do_patch {
    echo ""
    patch --forward -r /dev/null --no-backup-if-mismatch -p1 < "$PATCH_ROOT/$1" || true
}

PATCH_ROOT="$ANDROID_BUILD_TOP/device/sony/lilac/patches"

cd "$ANDROID_BUILD_TOP/external/selinux"
do_patch "fix_audit2allow.patch"

cd "$ANDROID_BUILD_TOP/frameworks/base"
do_patch "fix-null-ptr-in-customtile.patch"

cd "$ANDROID_BUILD_TOP/frameworks/native"
do_patch "workaround_egl_lib_symbols.patch"

cd "$ANDROID_BUILD_TOP/packages/apps/Settings"
do_patch "show-adb-root-option.patch"

cd "$ANDROID_BUILD_TOP/system/core"
do_patch "fix_snet_probs.patch"

cd "$ANDROID_BUILD_TOP/system/security"
do_patch "0001-keystore-Block-key-attestation-for-Google-Play-Servi.patch"

echo "Done."
