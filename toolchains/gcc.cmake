################################################################################
#
# T:N.U.N. GCC toolchain file.
#
# Copyright (c) 2016. Nenad Miksa. All rights reserved.
#
################################################################################

include( "${CMAKE_CURRENT_LIST_DIR}/gcc_compatibles.cmake" )

list( APPEND TNUN_disabled_warnings -Wno-error=cpp -Wno-deprecated-declarations -Wno-unused-result )

if( ${CMAKE_SYSTEM_NAME} MATCHES "Linux" )
    set( TNUN_code_coverage_compiler_flags -fprofile-arcs -ftest-coverage )
    set( TNUN_code_coverage_linker_flags   -fprofile-arcs -ftest-coverage gcov )
endif()

add_compile_options( -fdiagnostics-color )

set( USING_GCC true )
