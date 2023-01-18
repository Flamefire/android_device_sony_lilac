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
if [[ ! -d "$MY_DIR" ]]; then MY_DIR="$PWD"; fi

LINEAGE_ROOT="$MY_DIR"/../../..

HELPER="$LINEAGE_ROOT"/vendor/lineage/build/tools/extract_utils.sh
if [ ! -f "$HELPER" ]; then
    echo "Unable to find helper script at $HELPER"
    exit 1
fi

# Patch utils if not done
if ! grep -qF "# if line contains apk, jar or vintf fragment, it needs to be packaged" "$HELPER"; then
    patch --directory "$(dirname "$HELPER")" --quiet --no-backup-if-mismatch << 'EOF'
		Author: Michael Bestas <mkbestas@lineageos.org>
		Date:   Mon Nov 15 22:18:04 2021 +0200
		
		    extract_utils: Automatically add apk/jar/vintf fragments to PRODUCT_PACKAGES
		    
		    Change-Id: I9d12e00c294d02b40fde2b66d7797f69f6504c35
		diff --git a/extract_utils.sh b/extract_utils.sh
		index 455830f..b3dce4a 100644
		--- a/extract_utils.sh
		+++ b/extract_utils.sh
		@@ -1127,6 +1127,13 @@ function parse_file_list() {
		             PRODUCT_PACKAGES_LIST+=("${SPEC#-}")
		             PRODUCT_PACKAGES_HASHES+=("$HASH")
		             PRODUCT_PACKAGES_FIXUP_HASHES+=("$FIXUP_HASH")
		+        # if line contains apk, jar or vintf fragment, it needs to be packaged
		+        elif suffix_match_file ".apk" "$(src_file "$SPEC")" || \
		+             suffix_match_file ".jar" "$(src_file "$SPEC")" || \
		+             [[ "$SPEC" == *"etc/vintf/manifest/"* ]]; then
		+            PRODUCT_PACKAGES_LIST+=("$SPEC")
		+            PRODUCT_PACKAGES_HASHES+=("$HASH")
		+            PRODUCT_PACKAGES_FIXUP_HASHES+=("$FIXUP_HASH")
		         else
		             PRODUCT_COPY_FILES_LIST+=("$SPEC")
		             PRODUCT_COPY_FILES_HASHES+=("$HASH")
		@@ -1794,11 +1801,7 @@ function generate_prop_list_from_image() {
		         if array_contains "$FILE" "${skipped_vendor_files[@]}"; then
		             continue
		         fi
		-        if suffix_match_file ".apk" "$FILE" ; then
		-            echo "-vendor/$FILE" >> "$output_list_tmp"
		-        else
		-            echo "vendor/$FILE" >> "$output_list_tmp"
		-        fi
		+        echo "vendor/$FILE" >> "$output_list_tmp"
		     done
		 
		     # Sort merged file with all lists
EOF
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

while [ "$1" != "" ]; do
    case $1 in
        -n | --no-cleanup )     CLEAN_VENDOR=false
                                ;;
        -s | --section )        shift
                                SECTION=$1
                                CLEAN_VENDOR=false
                                ;;
        * )                     SRC=$1
                                ;;
    esac
    shift
done

if [ -z "$SRC" ]; then
    SRC=adb
fi

# Initialize the helper
setup_vendor "$DEVICE" "$VENDOR" "$LINEAGE_ROOT" false "$CLEAN_VENDOR"

extract "$MY_DIR"/proprietary-files.txt "$SRC" "$SECTION"
extract "$MY_DIR"/proprietary-files-vendor.txt "$SRC" "$SECTION"

#
# Fix product path
#

DEVICE_ROOT="$LINEAGE_ROOT"/vendor/"$VENDOR"/"$DEVICE"/proprietary

function fix_product_path () {
    sed -i \
        's/\/system\/framework\//\/system\/product\/framework\//g' \
        "$DEVICE_ROOT"/"$1"
}

fix_product_path product/etc/permissions/com.qualcomm.qti.imscmservice-V2.0-java.xml
fix_product_path product/etc/permissions/com.qualcomm.qti.imscmservice-V2.1-java.xml
fix_product_path product/etc/permissions/com.qualcomm.qti.imscmservice.xml
fix_product_path product/etc/permissions/embms.xml
fix_product_path product/etc/permissions/lpa.xml
fix_product_path product/etc/permissions/qcrilhook.xml
fix_product_path product/etc/permissions/telephonyservice.xml

"$MY_DIR"/setup-makefiles.sh
