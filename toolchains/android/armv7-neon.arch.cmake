################################################################################
#
# T:N.U.N. Android ARMv7+NEON CPU config file.
#
# Copyright (c) 2016. Domagoj Saric. All rights reserved.
#
################################################################################

include( "${CMAKE_CURRENT_LIST_DIR}/armv7-vfp3d16.arch.cmake" )

set( TNUN_arch_suffix ARMv7a_NEON )

add_compile_options( -mfpu=neon-vfpv4 )
