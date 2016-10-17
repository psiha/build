################################################################################
#
# T:N.U.N. Shared toolchain for Apple platforms.
#
# Copyright (c) 2016. Domagoj Saric. All rights reserved.
#
################################################################################

# https://developer.apple.com/library/mac/documentation/DeveloperTools/Reference/XcodeBuildSettingRef/1-Build_Setting_Reference/build_setting_ref.html

set( CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LIBRARY libc++ )

set( CMAKE_XCODE_ATTRIBUTE_ARCHS            "$(ARCHS_STANDARD)" ) # http://www.cocoanetics.com/2014/10/xcode-6-drops-armv7s
set( CMAKE_XCODE_ATTRIBUTE_VALID_ARCHS      "$(ARCHS_STANDARD)" )
set( CMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH NO                  )

set( CMAKE_XCODE_ATTRIBUTE_GCC_C_LANGUAGE_STANDARD     gnu11   )
set( CMAKE_XCODE_ATTRIBUTE_GCC_CXX_LANGUAGE_STANDARD   gnu++14 )
set( CMAKE_XCODE_ATTRIBUTE_GCC_C++_LANGUAGE_STANDARD   gnu++14 )
set( CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LANGUAGE_STANDARD gnu++14 )

# https://cmake.org/cmake/help/latest/policy/CMP0025.html
# Required to distinguish AppleClang from true Clang on Apple platform
cmake_policy( SET CMP0025 NEW )

if( ${CMAKE_CXX_COMPILER_ID} MATCHES "Clang" )
    include( "${CMAKE_CURRENT_LIST_DIR}/clang.cmake" )
    add_compile_options( -fconstant-cfstrings -fobjc-call-cxx-cdtors )
else()
    include( "${CMAKE_CURRENT_LIST_DIR}/gcc_compatibles.cmake" )
    add_compile_options( -mconstant-cfstrings )
endif()

# Xcode (7 & 8) report that function-sections are incompatible embed-bitcode
set( CMAKE_XCODE_ATTRIBUTE_ENABLE_BITCODE "NO" )
function( TNUN_enable_bitcode )
  add_compile_options( -fno-function-sections )
  set( CMAKE_XCODE_ATTRIBUTE_ENABLE_BITCODE "YES" )
  set( CMAKE_XCODE_ATTRIBUTE_BITCODE_GENERATION_MODE "bitcode" ) # Without this, Xcode adds -fembed-bitcode-marker compile options instead of -fembed-bitcode
endfunction()

link_libraries( $<$<CONFIG:RELEASE>:-dead_strip> )

set( TNUN_ABI   default    )
set( TNUN_ABIs ${TNUN_ABI} )

#...mrmlj...reinvestigate this...
# set( CMAKE_XCODE_ATTRIBUTE_OBJROOT          "${PROJECT_BINARY_DIR}" )
# set( CMAKE_XCODE_ATTRIBUTE_BUILD_DIR        "${PROJECT_BINARY_DIR}" )
# set( CMAKE_XCODE_ATTRIBUTE_BUILD_ROOT       "${PROJECT_BINARY_DIR}" )
# set( CMAKE_XCODE_ATTRIBUTE_PROJECT_TEMP_DIR "${PROJECT_BINARY_DIR}" )
# set( CMAKE_XCODE_ATTRIBUTE_SYMROOT          "${PROJECT_BINARY_DIR}/lib" )
# set( CMAKE_XCODE_ATTRIBUTE_SYMROOT_RELEASE  "${PROJECT_BINARY_DIR}/lib" )
