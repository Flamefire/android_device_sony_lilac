#!/usr/bin/env bash

# Apply patches to other repos
# Needs to be run from within repo and with envsetup sourced

set -euo pipefail

PATCH_ROOT="$ANDROID_BUILD_TOP/device/sony/lilac/patches"

numApplied=0
numSkipped=0
numWarned=0

for p in "$PATCH_ROOT/"*.patch; do
    patch_dir=$(head -n1 "$p" | grep "# PWD: " | awk '{print $NF}')
    if [[ "$patch_dir" == "" ]]; then
        echo "Faulty patch: $p"
        exit 1
    fi

    echo -n "Applying $(basename "$p") in $patch_dir : "
    # If the reverse patch could be applied, then the patch was likely already applied
    patch --reverse --force  -p1 -d "$patch_dir" --input "$p" --dry-run > /dev/null && applied=1 || applied=0
    if out=$(patch --forward -p1 -d "$patch_dir" --input "$p" -r /dev/null --no-backup-if-mismatch 2>&1); then
        echo "Done."
        ((++numApplied))
        # We applied the patch but could apply the reverse before, i.e. would detect it as already applied.
        # This may happen for patches only deleting stuff where the reverse (adding it) may succeed via fuzzy match
        if [[ $applied == 1 ]]; then
            echo "WARNING: Skip detection will not work correctly for this patch!"
            ((++numWarned))
        fi
    elif [[ $applied == 1 ]]; then
        echo "Skipped."
        ((++numSkipped))
    else
        echo "Failed!"
        echo "$out"
        exit 1
    fi
done

echo "Patching done! Applied: $numApplied, skipped: $numSkipped, warnings: $numWarned"
