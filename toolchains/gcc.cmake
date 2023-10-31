################################################################################
#
# PSI GCC toolchain file.
#
# Copyright (c) 2016. Nenad Miksa. All rights reserved.
#
################################################################################

include( "${CMAKE_CURRENT_LIST_DIR}/gcc_compatibles.cmake" )

if( ${CMAKE_SYSTEM_NAME} MATCHES "Linux" )
    set( PSI_code_coverage_compiler_flags -fprofile-arcs -ftest-coverage )
    set( PSI_code_coverage_linker_flags   -fprofile-arcs -ftest-coverage gcov )
endif()

list( APPEND PSI_common_compiler_options -fdiagnostics-color )

set( GCC true )
