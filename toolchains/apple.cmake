################################################################################
#
# T:N.U.N. Shared toolchain for Apple platforms.
#
# Copyright (c) 2016. Domagoj Saric. All rights reserved.
#
################################################################################

set( CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LIBRARY libc++ )

set( CMAKE_XCODE_ATTRIBUTE_ARCHS            "$(ARCHS_STANDARD)" ) # http://www.cocoanetics.com/2014/10/xcode-6-drops-armv7s
set( CMAKE_XCODE_ATTRIBUTE_VALID_ARCHS      "$(ARCHS_STANDARD)" )
set( CMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH NO                  )

set( CMAKE_XCODE_ATTRIBUTE_GCC_C_LANGUAGE_STANDARD     gnu11   )
set( CMAKE_XCODE_ATTRIBUTE_GCC_CXX_LANGUAGE_STANDARD   gnu++14 )
set( CMAKE_XCODE_ATTRIBUTE_GCC_C++_LANGUAGE_STANDARD   gnu++14 )
set( CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LANGUAGE_STANDARD gnu++14 )

include( "${CMAKE_CURRENT_LIST_DIR}/clang.cmake" )

add_compile_options( -fconstant-cfstrings -fobjc-call-cxx-cdtors )