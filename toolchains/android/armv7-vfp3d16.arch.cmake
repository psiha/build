################################################################################
#
# PSI Android ARMv7 CPU config file.
#
# Copyright (c) 2016. Domagoj Saric. All rights reserved.
#
################################################################################

set( CMAKE_ANDROID_ARCH   armeabi-v7a     )
set( ANDROID_NDK_ABI_NAME armeabi-v7a     )
set( PSI_arch_suffix     ARMv7a_VFP3-D16 )

list( APPEND PSI_common_compiler_options -march=armv7-a -mtune=cortex-a53 )
list( APPEND PSI_compiler_optimize_for_size  -mthumb )
list( APPEND PSI_compiler_optimize_for_speed -marm   )

# Implementation note:
#
# Official ndk-build script removed support for armeabi-v7a-hardfloat because
# Google does not want to support that anymore - they say that performance
# benefits by using this are not big and that it is not tested anyway. However,
# if all dependencies can be built with hardfloat, we can use it. Why not
# benefit where possible?
# We'll keep this disabled by default because using hardfloat ABI requires that
# all other dependencies (including 3rd party binaries) are using hardfloat ABI,
# which is not so common.
#
# https://stackoverflow.com/questions/32046055/is-it-safe-to-replace-armeabi-v7a-with-armeabi-v7a-hard
# http://blog.alexrp.com/2014/02/18/android-hard-float-support/
#
#                                             (01.09.2016. Nenad Miksa)

option( PSI_ANDROID_ARM7_HARDFLOAT_ABI "Use hardfloat ABI for armv7 binaries" false )
if( ${PSI_ANDROID_ARM7_HARDFLOAT_ABI} )
    list( APPEND PSI_common_compiler_options -mhard-float -D_NDK_MATH_NO_SOFTFP=1 )
    list( APPEND PSI_common_link_options     -Wl,--no-warn-mismatch -lm_hard )
endif()

# this is *required* to use the following linker flags that routes around
# a CPU bug in some Cortex-A8 implementations:
list( APPEND PSI_common_link_options "-Wl,--fix-cortex-a8" )
