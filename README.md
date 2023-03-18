Device configuration for Sony Xperia XZ1 Compact (lilac)
========================================================

Description
-----------

This repository is for LineageOS 17.1 on Sony Xperia XZ1 Compact (lilac).

How to build LineageOS
----------------------

* Make a workspace:

    ```bash
    mkdir -p ~/lineageos
    cd ~/lineageos
    ```

* Initialize the repo:

    ```bash
    repo init -u git://github.com/LineageOS/android.git -b lineage-17.1
    ```

* Create a local manifest:

    ```bash
    mkdir .repo/local_manifests
    vim .repo/local_manifests/roomservice.xml

    <?xml version="1.0" encoding="UTF-8"?>
    <manifest>
        <!-- SONY -->
        <project name="Flamefire/android_kernel_sony_msm8998" path="kernel/sony/msm8998" remote="github" revision="lineage-17.1" />
        <project name="Flamefire/android_device_sony_yoshino-common" path="device/sony/yoshino-common" remote="github" revision="lineage-17.1" />
        <project name="Flamefire/android_device_sony_lilac" path="device/sony/lilac" remote="github" revision="lineage-17.1" />

        <!-- Pinned blobs for lilac -->
        <project name="Flamefire/android_vendor_sony_lilac" path="vendor/sony/lilac" remote="github" revision="lineage-17.1" />

        <!-- Newer Clang version -->
        <project path="prebuilts-extra/clang/host/linux-x86" name="platform/prebuilts/clang/host/linux-x86" groups="pdk" clone-depth="1" remote="aosp" revision="refs/tags/android-12.1.0_r22" >
            <linkfile src="clang-r416183b1" dest="prebuilts/clang/host/linux-x86/clang-r416183b1" />
            <!-- Replace the unneeded, conflicting build scripts with empty ones -->
            <!-- (repo manifest syntax has no way to delete or rename them) -->
            <copyfile src="clang-r416183b1/MODULE_LICENSE_MIT" dest="prebuilts-extra/clang/host/linux-x86/Android.mk" />
            <copyfile src="clang-r416183b1/MODULE_LICENSE_MIT" dest="prebuilts-extra/clang/host/linux-x86/Android.bp" />
            <copyfile src="clang-r416183b1/MODULE_LICENSE_MIT" dest="prebuilts-extra/clang/host/linux-x86/soong/Android.bp" />
        </project>
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

* Build LineageOS

    ```bash
    make -j8 bacon
    ```
