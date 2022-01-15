#!/usr/bin/env bash

# Apply patches to other repos
# Needs to be run from within repo and with envsetup sourced

set -euo pipefail

function do_patch {
    echo ""
    patch --forward -r /dev/null --no-backup-if-mismatch -p1 < "$PATCH_ROOT/$1" || true
}

PATCH_ROOT="$ANDROID_BUILD_TOP/device/sony/lilac/patches"

cd "$ANDROID_BUILD_TOP/art"
do_patch "update-cpp-define-generator.patch"
do_patch "use-uxtw-instead-of-lsl-for-asm.patch"

cd "$ANDROID_BUILD_TOP/bionic"
do_patch "add-missing-nothrow.patch"
do_patch "dont-export-libm-libc-symbols.patch"
do_patch "remove-fallhthrough-warning.patch"

cd "$ANDROID_BUILD_TOP/build/soong"
do_patch "make-stub-symbols-visible.patch"
do_patch "update-clang.patch"

cd "$ANDROID_BUILD_TOP/external/libunwind_llvm"
do_patch "fix-llvm-unwind-warning-and-findUnwindSections.patch"

cd "$ANDROID_BUILD_TOP/external/selinux"
do_patch "fix_audit2allow.patch"

cd "$ANDROID_BUILD_TOP/frameworks/av"
do_patch "fix-mediaplayer2-flags.patch"

cd "$ANDROID_BUILD_TOP/frameworks/base"
do_patch "fix-null-ptr-in-customtile.patch"
do_patch "fix-reversed-logic.patch"

cd "$ANDROID_BUILD_TOP/frameworks/native"
do_patch "fix-native-vulkan.patch"
do_patch "workaround_egl_lib_symbols.patch"

cd "$ANDROID_BUILD_TOP/libnativehelper"
do_patch "fix-class-templates.patch"

cd "$ANDROID_BUILD_TOP/packages/apps/Settings"
do_patch "show-adb-root-option.patch"

cd "$ANDROID_BUILD_TOP/prebuilts/abi-dumps/vndk"
do_patch "update-abi-dumps.patch"

cd "$ANDROID_BUILD_TOP/system/core"
do_patch "fix_snet_probs.patch"

cd "$ANDROID_BUILD_TOP/system/keymaster"
do_patch "fix-fallthrough-in-keymaster.patch"

cd "$ANDROID_BUILD_TOP/system/libhidl"
do_patch "fix-setLocked-signature.patch"

cd "$ANDROID_BUILD_TOP/system/security"
do_patch "0001-keystore-Block-key-attestation-for-Google-Play-Servi.patch"

cd "$ANDROID_BUILD_TOP/system/tools/hidl"
do_patch "make-hidl_enum_values-inline.patch"
do_patch "suppress-bool-operation-warning.patch"

cd "$ANDROID_BUILD_TOP/vendor/qcom/opensource/audio"
do_patch "fix-dangling-pointer.patch"

echo "Done."
