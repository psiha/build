################################################################################
#
# T:N.U.N. Android ABI config file.
#
# Copyright (c) 2016. Domagoj Saric. All rights reserved.
#
################################################################################

set( ARM64                    true                    )
set( ANDROID_ARCH_NAME        "arm64"                 )
set( ANDROID_NDK_ABI_NAME     "arm64-v8a"             )
set( ANDROID_GCC_MACHINE_NAME "aarch64-linux-android" )
set( CMAKE_SYSTEM_PROCESSOR   "aarch64"               )
set( TNUN_cpu_archs           "aarch64"               )

list( APPEND TNUN_common_compiler_options -march=armv8-a )
