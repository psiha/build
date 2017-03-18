################################################################################
#
# T:N.U.N. Android ABI config file.
#
# Copyright (c) 2016. Domagoj Saric. All rights reserved.
#
################################################################################

set( x86                      true                   )
set( x86_64                   true                   )
set( CMAKE_SYSTEM_PROCESSOR   "x86_64"               )
set( ANDROID_NDK_ABI_NAME     "x86_64"               )
set( ANDROID_ARCH_NAME        "x86_64"               )
set( ANDROID_GCC_MACHINE_NAME "x86_64-linux-android" )
set( TNUN_cpu_archs           "x86_64"               )

add_compile_options( -m64 -march=atom -msse4.2 -mpopcnt ) # assume Silvermont arch