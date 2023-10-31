################################################################################
#
# PSI Android ARMv7+NEON CPU config file.
#
# Copyright (c) 2016. Domagoj Saric. All rights reserved.
#
################################################################################

include( "${CMAKE_CURRENT_LIST_DIR}/armv7-vfp3d16.arch.cmake" )

set( PSI_arch_suffix ARMv7a_NEON )

list( APPEND PSI_common_compiler_options -mfpu=neon-vfpv4 )
