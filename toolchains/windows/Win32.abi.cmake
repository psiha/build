################################################################################
#
# PSI MSVC ABI config file.
#
# Copyright (c) 2016. Domagoj Saric. All rights reserved.
#
################################################################################

set( PSI_cpu_archs
  x86_sse2
)

list( APPEND PSI_common_compiler_options -arch:SSE2 )
