################################################################################
#
# T:N.U.N. Android ABI config file.
#
# Copyright (c) 2016. Domagoj Saric. All rights reserved.
#
################################################################################

set( x86                      true                 )
set( CMAKE_SYSTEM_PROCESSOR   "i686"               )
set( ANDROID_NDK_ABI_NAME     "x86"                )
set( ANDROID_ARCH_NAME        "x86"                )
set( ANDROID_GCC_MACHINE_NAME "i686-linux-android" )
set( TNUN_cpu_archs           "x86"                )

add_compile_options( -m32 -march=atom -mmmx -mssse3 -mcx16 )
