################################################################################
#
# T:N.U.N. Apple OS X CMake tool chain file.
#
# Copyright (c) 2016. Domagoj Saric. All rights reserved.
#
################################################################################

include( "${CMAKE_CURRENT_LIST_DIR}/apple.cmake" )

# MACOSX_RPATH
# cmake.org/cmake/help/latest/policy/CMP0042.html
# https://en.wikipedia.org/wiki/Rpath
# https://blog.kitware.com/upcoming-in-cmake-2-8-12-osx-rpath-support
# https://cmake.org/Wiki/CMake_RPATH_handling
# http://web.archive.org/web/20080602043910/http://people.debian.org/~che/personal/rpath-considered-harmful
cmake_policy( SET CMP0042 OLD )
set( CMAKE_MACOSX_RPATH 0 ) # even with the policy set CMake 3.5.2 still issues the warning?

set( CMAKE_OSX_ARCHITECTURES           "$(ARCHS_STANDARD_32_64_BIT)" )
set( CMAKE_XCODE_ATTRIBUTE_VALID_ARCHS "$(ARCHS_STANDARD_32_64_BIT)" )
set( CMAKE_OSX_SYSROOT                 "macosx"                      ) #"Latest Mac OS X"
set( CMAKE_OSX_DEPLOYMENT_TARGET       "10.7"                        )

set( OSX true )

set( TNUN_os_suffix OSX )

set( TNUN_cpu_archs default )

add_compile_options( -mmmx -mfpmath=sse -mcx16 )

if ( LE_TARGET_ARCHITECTURE STREQUAL sse3 )
    set( XCODE_ATTRIBUTE_CFLAGS_i386   "-msse3  -march=prescott -mtune=core2"  )
    set( XCODE_ATTRIBUTE_CFLAGS_x86_64 "-mssse3 -march=core2    -mtune=corei7" )
elseif ( LE_TARGET_ARCHITECTURE STREQUAL sse4.1 )
    set( XCODE_ATTRIBUTE_CFLAGS_i386   "-msse4.1 -march=core2 -mtune=core2"  )
    set( XCODE_ATTRIBUTE_CFLAGS_x86_64 "-msse4.1 -march=core2 -mtune=corei7" )
endif()