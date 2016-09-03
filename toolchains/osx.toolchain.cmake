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

set( CMAKE_OSX_ARCHITECTURES           "$(ARCHS_STANDARD)" )
set( CMAKE_XCODE_ATTRIBUTE_VALID_ARCHS "$(ARCHS_STANDARD_32_64_BIT)" )
set( CMAKE_OSX_DEPLOYMENT_TARGET       "10.7"                        )
set( CPACK_SYSTEM_NAME                 "OSX"                         )

# Implementation note:
# CMake (3.5.2) 'somehow' adds ${CMAKE_OSX_ARCHITECTURES} and
# ${CMAKE_OSX_SYSROOT} to the compiler options even if a generator other than
# Xcode (e.g. Ninja) is used (and this breaks the build of course).
#                                         (27.06.2016.) (Domagoj Saric)
if ( NOT ${CMAKE_GENERATOR} MATCHES "Xcode" )
  unset( CMAKE_OSX_ARCHITECTURES )
  unset( CMAKE_OSX_SYSROOT       )
endif ()

set( OSX true )

set( TNUN_os_suffix OSX )

set( TNUN_cpu_archs default )

set( TNUN_ABI x64 )

add_compile_options( -mmmx -mfpmath=sse -mcx16 )

if("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
    set( USING_CLANG true )
    set( MACOSX_CPP_LIBRARY_DEFAULT "libc++" )
else()
    set( USING_GCC true )
    set( MACOSX_CPP_LIBRARY_DEFAULT "stdc++" )
endif()

set( MACOSX_CPP_LIBRARY ${MACOSX_CPP_LIBRARY_DEFAULT} CACHE STRING "C++ library used on Mac OS X" )
set_property( CACHE MACOSX_CPP_LIBRARY PROPERTY STRINGS "libc++" "stdc++" )
if(${USING_CLANG})
    if(${MACOSX_CPP_LIBRARY} STREQUAL "libc++")
        set(MACOSX_USE_LIBCXX true)
        add_compile_options( -stdlib=libc++ )
        link_libraries( -stdlib=libc++ )
    else()
        set(MACOSX_USE_LIBCXX false)
        add_compile_options( -stdlib=libstdc++ )
        link_libraries( -stdlib=libstdc++ )
    endif()
endif()
if( ${USING_GCC} )
    if(${MACOSX_CPP_LIBRARY} STREQUAL "libc++")
        set(MACOSX_USE_LIBCXX true)
        add_compile_options( -nostdinc++ -I/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include/c++/v1 )
        link_libraries( -lc++ -lc++abi -lm -lc -lgcc )
    else()
        set(MACOSX_USE_LIBCXX false)
    endif()
endif()

################################################################################
# TNUN_setup_target_for_arch()
################################################################################

function( TNUN_setup_target_for_arch target base_target_name arch )
  set_property( TARGET ${target} PROPERTY ARCHIVE_OUTPUT_DIRECTORY_RELEASE "${PROJECT_BINARY_DIR}/lib" )
  set_property( TARGET ${target} PROPERTY LIBRARY_OUTPUT_DIRECTORY_RELEASE "${PROJECT_BINARY_DIR}/lib" )
  set_property( TARGET ${target} PROPERTY OUTPUT_NAME                       "${base_target_name}_${TNUN_os_suffix}" )
endfunction()
