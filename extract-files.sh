#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2020 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=lilac
VENDOR=sony

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        -n | --no-cleanup )
                CLEAN_VENDOR=false
                ;;
        -k | --kang )
                KANG="--kang"
                ;;
        -s | --section )
                SECTION="${2}"; shift
                CLEAN_VENDOR=false
                ;;
        * )
                SRC="${1}"
                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi


# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" true "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"
extract "${MY_DIR}/proprietary-files-vendor.txt" "${SRC}" "${KANG}" --section "${SECTION}"

#
# Blobs fixup start
#

DEVICE_ROOT="${ANDROID_ROOT}"/vendor/"${VENDOR}"/"${DEVICE}"/proprietary

# Fix referenced set_sched_policy for stock audio hal
"${PATCHELF}" --replace-needed "libcutils.so" "libprocessgroup.so" "${DEVICE_ROOT}"/vendor/lib/hw/audio.primary.msm8998.so

# Add a restorecon for /persist/wlan to taimport_vendor.rc
sed -i '4 a\    restorecon /persist/wlan' "${DEVICE_ROOT}"/vendor/etc/init/taimport_vendor.rc

# Change xml version from 2.0 to 1.0
sed -i 's/version\=\"2\.0\"/version\=\"1\.0\"/g' "${DEVICE_ROOT}"/product/etc/permissions/vendor.qti.hardware.data.connection-V1.0-java.xml
sed -i 's/version\=\"2\.0\"/version\=\"1\.0\"/g' "${DEVICE_ROOT}"/product/etc/permissions/vendor.qti.hardware.data.connection-V1.1-java.xml

#
# Blobs fixup end
#

"${MY_DIR}"/setup-makefiles.sh

# --- Post-process Android.bp ---
ANDROIDBP="${ANDROIDBP:-${MY_DIR:-$PWD}/Android.bp}"
[ -f "$ANDROIDBP" ] || { echo "Android.bp not found at $ANDROIDBP" >&2; exit 1; }

awk '
  BEGIN { inblk=0; depth=0; name=""; buf="" }
  /^[ \t]*(android_app_import|dex_import|java_import)[ \t]*\{[ \t]*$/ && !inblk {
    inblk=1; depth=1; name=""; buf=$0 ORS; next
  }
  inblk {
    buf = buf $0 ORS
    if (name=="" && $0 ~ /name:[ \t]*"[^"]+"/) { match($0,/name:[ \t]*"([^"]+)"/,m); name=m[1] }
    o=gsub(/\{/, "", $0); c=gsub(/\}/, "", $0); depth += o - c
    if (depth==0) {
      if (!(name=="SemcCameraUI-xxhdpi-release" || name=="com.sonymobile.camera.addon.api")) {
        printf "%s", buf
      }
      inblk=0; name=""; buf=""
    }
    next
  }
  { print }
' "$ANDROIDBP" > "$ANDROIDBP.tmp" && mv "$ANDROIDBP.tmp" "$ANDROIDBP"

cat >>"$ANDROIDBP" <<'EOF'

android_app_import {
	name: "SemcCameraUI-xxhdpi-release",
	owner: "sony",
	apk: "proprietary/priv-app/SemcCameraUI-xxhdpi-release/SemcCameraUI-xxhdpi-release.apk",
	certificate: "platform",
	dex_preopt: {
		enabled: false,
	},
	privileged: true,
	uses_libs: ["com.sonymobile.camera.addon.api"],
}

java_import {
	name: "com.sonymobile.camera.addon.api",
	owner: "sony",
	jars: ["proprietary/framework/com.sonymobile.camera.addon.api.jar"],
	installable: true,
}
EOF
# --- End rewrite ---
