################################################################################
#
# T:N.U.N. Android ARMv7 CPU config file.
#
# Copyright (c) 2016. Domagoj Saric. All rights reserved.
#
################################################################################

set( CMAKE_ANDROID_ARCH   armeabi-v7a     )
set( ANDROID_NDK_ABI_NAME armeabi-v7a     )
set( TNUN_arch_suffix     ARMv7a_VFP3-D16 )

add_compile_options( -march=armv7-a -mtune=cortex-a9 )
list( APPEND TNUN_compiler_optimize_for_size  -mthumb )
list( APPEND TNUN_compiler_optimize_for_speed -marm   )

# this is *required* to use the following linker flags that routes around
# a CPU bug in some Cortex-A8 implementations:
link_libraries( "-Wl,--fix-cortex-a8" )
