################################################################################
#
# T:N.U.N. Windows CMake toolchain file.
#
# Copyright (c) 2016 - 2017. Domagoj Saric.
#
################################################################################

set( TNUN_os_suffix    Windows           )
set( CPACK_SYSTEM_NAME ${TNUN_os_suffix} )

################################################################################
# malloc overcommit policy
#
# Windows does not use memory overcommit (even in its phone variants), i.e. OOM
# conditions can be reliably caught and handled there.
#                                             (01.05.2017. Domagoj Saric)
################################################################################

set( TNUN_MALLOC_OVERCOMMIT_POLICY Disabled )

message( STATUS "CMAKE_CXX_COMPILER_ID: ${CMAKE_CXX_COMPILER_ID}" )
message( STATUS "CMAKE_CXX_COMPILER_VERSION: ${CMAKE_CXX_COMPILER_VERSION}" )

message( STATUS "CMAKE_CXX_SIMULATE_ID: ${CMAKE_CXX_SIMULATE_ID}" )
message( STATUS "CMAKE_CXX_SIMULATE_VERSION: ${CMAKE_CXX_SIMULATE_VERSION}" )

# if using clang-cl, use msvc.toolchain.cmake
if ( CMAKE_CXX_COMPILER_ID STREQUAL "Clang" AND NOT CMAKE_CXX_SIMULATE_ID STREQUAL "MSVC" )
    message( STATUS "Using clang toolchain" )
    include( "${CMAKE_CURRENT_LIST_DIR}/clang.cmake" )
else()
    message( STATUS "Using msvc toolchain" )
    include( "${CMAKE_CURRENT_LIST_DIR}/msvc.toolchain.cmake" )
endif()
