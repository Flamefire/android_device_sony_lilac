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

function showError {
    echo -e "${RED}ERROR: $@${NC}" && false
}

repo_root=$(readlink -f "$PATCH_ROOT/../../../..")
if [ ! -d "$repo_root/device/sony/lilac/patches" ]; then
  showError "Failed to find repository root at $repo_root"
fi

patch_set=all
script_name=$(basename "$0")
for arg in "$@"; do
    case "$arg" in
        '--help'|'-h')
            echo "Usage: $script_name [--clean | --minimal | --minclang]"
            echo
            echo "Options:"
            echo "  --clean     Revert patched dirs instead of patching"
            echo "  --minimal   Only required & security patches"
            echo "  --minclang  Only required, new Clang, & security patches"
            exit 0
            ;;
        '--clean')      clean_patch_dirs=1;;
        '--minimal')    patch_set=minimal;;
        '--minclang')   patch_set=minclang;;
        *)              showError "unknown option: $arg"
    esac
done

numApplied=0
numSkipped=0
numWarned=0

function applyPatch {
    patch=${1:?"No patch specified"}

    if ! patch_dir=$(head -n1 "$patch" | grep "# PWD: " | awk '{print $NF}') || [[ "$patch_dir" == "" ]]; then
        showError "Faulty patch: $patch"
    fi

    if [ "${clean_patch_dirs:-}" ]; then
        if ! git -C "$patch_dir" diff --quiet; then
            echo -n "Cleaning ${patch_dir}: "
            git -C "$patch_dir" reset --hard --quiet
            git -C "$patch_dir" clean -d --force --quiet
            echo -e "${LGREEN}Done.${NC}"
        else
            echo "Ignoring ${patch_dir}  (no changes detected)"
        fi
        return
    fi

    parent="$(basename "$(dirname "$patch")")"
    msg="$(basename "$patch")"
    if [[ "$parent" =~ asb-* ]]; then
        msg+=" - ${YELLOW}${parent^^}${NC}"
    fi
    echo -en "Applying $msg in ${patch_dir}: "
    if [[ $(wc -l < "$patch") == 1 ]]; then
        echo -e "${LGREEN}Skipped (empty).${NC}"
        ((++numSkipped))
    else
        pushd "$repo_root/$patch_dir" > /dev/null
        # If the reverse patch could be applied, then the patch was likely already applied
        git apply --check --reverse -p1 --whitespace=nowarn "$patch" &> /dev/null && applied=1 || applied=0
        if out=$(git apply -p1 --whitespace=nowarn "$patch" 2>&1); then
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
	    popd > /dev/null
            exit 1
        fi
	popd > /dev/null
    fi
}

# Apply the latest ASB patch for each project/folder
for filename in $(find "$PATCH_ROOT/asb-"* -maxdepth 1 -type f -name '*.patch' -printf "%f\n" | sort -u); do
    patch=$(find "$PATCH_ROOT/asb-"* -maxdepth 1 -type f -name "$filename" | sort | tail -n1)
    applyPatch "$patch"
done

# Apply custom patches
if [ "$patch_set" = all ]; then
    for p in "$PATCH_ROOT/"*.patch; do
        applyPatch "$p"
    done
else
    # v17.1-20221115 fix: ValueError: list.remove(x): x not in list
    applyPatch "$PATCH_ROOT"/fix-custom-apn-script.patch
    if [ "$patch_set" = minclang ]; then
        # v17.1-20230225 fix: "arm-linux-androidkernel-as" is not allowed
        applyPatch "$PATCH_ROOT"/allow-newer-kernel-clang.patch
        applyPatch "$PATCH_ROOT"/update-kernel-clang-for-host-cc.patch
    fi
fi

echo -e "Patching done! ${LGREEN}Applied: ${numApplied}${NC}, ${GREEN}skipped: ${numSkipped}${NC}, ${YELLOW}warnings: ${numWarned}${NC}"
