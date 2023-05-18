################################################################################
#
# T:N.U.N. MSVC ABI config file.
#
# Copyright (c) 2016. Domagoj Saric. All rights reserved.
#
################################################################################

set( TNUN_cpu_archs
  x86_sse2
)

list( APPEND TNUN_common_compiler_options -arch:SSE2 )
