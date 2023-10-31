################################################################################
#
# Android platform basic build instructions and information
# (native/NDK side only)
#
# Copyright (c) 2016. Domagoj Saric. All rights reserved.
#
################################################################################

* Build environment/prerequisites:
    - Ninja build system (v1.7.1+, https://ninja-build.org, autoinstalled)
    - JDK (8u92) http://www.oracle.com/technetwork/java/javase/downloads/index.html
    - Android NDK (r11c)
        - http://developer.android.com/tools/sdk/ndk/index.html
        - https://github.com/android-ndk
        - the toolchain file looks for the NDK in the following locations and in
          the following order:
          - CMake ANDROID_NDK variable
          - environment ANDROID_NDK variable
          - ${ANDROID_NDK_ROOT}/android-ndk-${android_ndk_default_version}
          - $ENV{PSI_3rd_party_root}/Android/NDK/android-ndk-${android_ndk_default_version}
          where android_ndk_default_version is (currently) r11c
    - Android SDK (r24+) http://developer.android.com/sdk/index.html (studio bundle or command line tools separately)
        - install the required platforms (Android SDK Manager) and emulators (Android AVD Manager)

* Building/Debugging:
	- Creating the distribution package from the command line:
        - "ninja package" in the build directory
            or
        - cmake --build <dir-with-the-generated-makefile> --target package
