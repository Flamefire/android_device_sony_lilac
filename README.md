Device configuration for Sony Xperia XZ1 Compact (lilac)
========================================================

Description
-----------

This repository is for LineageOS on Sony Xperia XZ1 Compact (lilac).

How to build LineageOS
----------------------

* Make a workspace:

    ```bash
    mkdir -p ~/lineageos
    cd ~/lineageos
    ```

* Initialize the repo:

    ```bash
    repo init -u ssh://git@github.com/LineageOS/android.git -b lineage-19.1
    ```

* Create a local manifest:

    ```bash
    mkdir .repo/local_manifests
    vim .repo/local_manifests/roomservice.xml

    <?xml version="1.0" encoding="UTF-8"?>
    <manifest>
        <!-- SONY -->
        <project name="Flamefire/android_kernel_sony_msm8998" path="kernel/sony/msm8998" remote="github" revision="lineage-19.1" />
        <project name="Flamefire/android_device_sony_yoshino-common" path="device/sony/yoshino-common" remote="github" revision="lineage-19.1" />
        <project name="Flamefire/android_device_sony_lilac" path="device/sony/lilac" remote="github" revision="lineage-19.1" />

        <!-- Pinned blobs for lilac -->
        <project name="Flamefire/android_vendor_sony_lilac" path="vendor/sony/lilac" remote="github" revision="lineage-19.1" />
    </manifest>
    ```

* And optional a manifest to limit the download:

    ```bash
    vim .repo/local_manifests/removals.xml

    <manifest>
        <remove-project name="platform/prebuilts/bazel/darwin-x86_64"/>
        <remove-project name="platform/prebuilts/clang/host/darwin-x86"/>
        <remove-project name="platform/prebuilts/gcc/darwin-x86/host/i686-apple-darwin-4.2.1"/>
        <remove-project name="platform/prebuilts/gdb/darwin-x86"/>
        <remove-project name="platform/prebuilts/go/darwin-x86"/>
        <remove-project name="platform/prebuilts/python/darwin-x86/2.7.5"/>
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

* Build LineageOS

    ```bash
    make -j8 bacon
    ```
