Device configuration for Sony Xperia XZ1 Compact (lilac)
========================================================

Description
-----------

This repository is for LineageOS 18.1 on Sony Xperia XZ1 Compact (lilac).

How to build LineageOS
----------------------

* Make a workspace:

    ```bash
    mkdir -p ~/lineageos
    cd ~/lineageos
    ```

* Initialize the repo:

    ```bash
    repo init -u git://github.com/LineageOS/android.git -b lineage-18.1 --git-lfs
    ```

* Create a local manifest:

    ```bash
    mkdir .repo/local_manifests
    vim .repo/local_manifests/roomservice.xml

    <?xml version="1.0" encoding="UTF-8"?>
    <manifest>
        <!-- SONY -->
        <project name="Flamefire/android_kernel_sony_msm8998" path="kernel/sony/msm8998" remote="github" revision="lineage-18.1" />
        <project name="Flamefire/android_device_sony_yoshino-common" path="device/sony/yoshino-common" remote="github" revision="lineage-18.1" />
        <project name="Flamefire/android_device_sony_lilac" path="device/sony/lilac" remote="github" revision="lineage-18.1" />

        <!-- Pinned blobs for lilac -->
        <project name="Flamefire/android_vendor_sony_lilac" path="vendor/sony/lilac" remote="github" revision="lineage-18.1" />
    </manifest>
    ```

* And optional a manifest to limit the download:

    ```bash
    vim .repo/local_manifests/removals.xml

    <manifest>
        <remove-project name="platform/prebuilts/clang/host/darwin-x86"/>
        <remove-project name="LineageOS/android_prebuilts_gcc_darwin-x86_aarch64_aarch64-linux-android-4.9"/>
        <remove-project name="LineageOS/android_prebuilts_gcc_darwin-x86_arm_arm-linux-androideabi-4.9"/>
        <remove-project name="platform/prebuilts/gcc/darwin-x86/host/i686-apple-darwin-4.2.1"/>
        <remove-project name="LineageOS/android_prebuilts_gcc_darwin-x86_x86_x86_64-linux-android-4.9"/>
        <remove-project name="platform/prebuilts/gdb/darwin-x86"/>
        <remove-project name="platform/prebuilts/go/darwin-x86"/>
        <remove-project name="platform/prebuilts/python/darwin-x86/2.7.5"/>
        <remove-project name="platform/external/OpenCL-CTS"/>
    </manifest>
    ```

* Sync the repo:

    ```bash
    repo sync
    ```

* Extract vendor blobs

    ```bash
    cd device/sony/lilac
    ./extract-files.sh
    ```

* Setup the environment

    ```bash
    source build/envsetup.sh
    lunch lineage_lilac-userdebug
    ```

* (Semi-)optionally apply patches

    Some of the patches in this repo fix a few bugs or issues in LineageOS while others make the build deviate a lot from the "vanilla build".
    So this is only for advanced users!

    ```bash
    device/sony/lilac/patches/applyPatches.sh
    ```

* Get newer Clang compiler(s)

    For better performance/battery life a newer compiler is used.
    So e.g. for the kernel you need to get the folder `r416183b1` (at the time of writing) into `prebuilts/clang/host/linux-x86`.
    You can check other branches (e.g. for `r416183b1` the branch is `android-12.1.0_r22`) and checkout only that folder or otherwise copy or symlink it from anywhere into `prebuilts/clang/host/linux-x86`.
    The `make` below will abort with a more or less descriptive error if you miss this, so just try.

* Build LineageOS

    ```bash
    make -j8 bacon
    ```
