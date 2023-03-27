#!/usr/bin/env bash

# Apply all patches in this directory.
# Each patch must start with `# PWD: <rel path>`
# where `<rel path>` is the relative path from the android root dir,
# i.e. what would be `$ANDROID_BUILD_TOP`, to the path where the patch should be applied

set -euo pipefail

GREEN='\033[0;32m'
LGREEN='\033[1;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'
PATCH_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

repo_root=$(readlink -f "$PATCH_ROOT/../../../..")
if [ ! -d "$repo_root/device/sony/lilac/patches" ]; then
  echo -e "${RED}Failed to find repository root at $repo_root"
  exit 1
fi

numApplied=0
numSkipped=0
numWarned=0

for p in "$PATCH_ROOT/"*.patch "$PATCH_ROOT/asb-"*/*.patch; do
    patch_dir=$(head -n1 "$p" | grep "# PWD: " | awk '{print $NF}')
    if [[ "$patch_dir" == "" ]]; then
        echo "Faulty patch: $p"
        exit 1
    fi

    echo -n "Applying $(basename "$p") in ${patch_dir}: "
    patch_dir="$repo_root/$patch_dir"
    # If the reverse patch could be applied, then the patch was likely already applied
    patch --reverse --force  -p1 -d "$patch_dir" --input "$p" --dry-run > /dev/null && applied=1 || applied=0
    if out=$(patch --forward -p1 -d "$patch_dir" --input "$p" -r /dev/null --no-backup-if-mismatch 2>&1); then
        echo -e "${LGREEN}Done.${NC}"
        ((++numApplied))
        # We applied the patch but could apply the reverse before, i.e. would detect it as already applied.
        # This may happen for patches only deleting stuff where the reverse (adding it) may succeed via fuzzy match
        if [[ $applied == 1 ]]; then
            echo -e "${YELLOW}WARNING${NC}: Skip detection will not work correctly for this patch!"
            ((++numWarned))
        fi
    elif [[ $applied == 1 ]]; then
        echo -e "${GREEN}Skipped.${NC}"
        ((++numSkipped))
    else
        echo -e "${RED}Failed!${NC}"
        echo "$out"
        exit 1
    fi
done

echo -e "Patching done! ${LGREEN}Applied: ${numApplied}${NC}, ${GREEN}skipped: ${numSkipped}${NC}, ${YELLOW}warnings: ${numWarned}${NC}"
