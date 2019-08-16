################################################################################
#
# T:N.U.N. Android ABI config file.
#
# Copyright (c) 2016. - 2018. Domagoj Saric. All rights reserved.
#
################################################################################

# https://en.wikipedia.org/wiki/ARM_architecture
set( TNUN_cpu_archs
  # Implementation note: Dropping support for the old armeabi archs greatly
  # simplifies things: CMAKE_SYSTEM_PROCESSOR and ANDROID_NDK_ABI_NAME become
  # fixed (armv7-a and armeabi-v7a, respectively) just like in other ABIs.
  #                                           (03.06.2016.) (Domagoj Saric)
  #armv5te_armeabi ... obsolete
  #armv6m-vfp2_armeabi ... obsolete ... -marm -march=armv6k -mtune=arm1136j-s
  armv7-vfp3d16
  armv7-vfp3d32
  armv7-neon
)

set( abi_sufix                "eabi"                          )
set( ANDROID_ARCH_NAME        "arm"                           )
set( ANDROID_GCC_MACHINE_NAME "arm-linux-android${abi_sufix}" )
set( CMAKE_SYSTEM_PROCESSOR   "armv7-a"                       )

list( APPEND TNUN_compiler_optimize_for_size  -mthumb )
list( APPEND TNUN_compiler_optimize_for_speed -marm   )

add_compile_options( -march=armv7-a -mtune=cortex-a15 )
