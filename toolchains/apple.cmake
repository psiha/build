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

include( "${CMAKE_CURRENT_LIST_DIR}/clang.cmake" )

add_compile_options( -fconstant-cfstrings -fobjc-call-cxx-cdtors )

link_libraries( $<$<CONFIG:RELEASE>:-dead_strip> )

set( TNUN_ABI default )

#set( CMAKE_XCODE_ATTRIBUTE_OBJROOT          "${PROJECT_BINARY_DIR}" )
#set( CMAKE_XCODE_ATTRIBUTE_BUILD_DIR        "${PROJECT_BINARY_DIR}" )
#set( CMAKE_XCODE_ATTRIBUTE_BUILD_ROOT       "${PROJECT_BINARY_DIR}" )
#set( CMAKE_XCODE_ATTRIBUTE_PROJECT_TEMP_DIR "${PROJECT_BINARY_DIR}" )

################################################################################
# TNUN_setup_target_for_arch()
################################################################################

function( TNUN_setup_target_for_arch target base_target_name arch )
  #...mrmlj...
  #set_property( TARGET ${target} PROPERTY XCODE_ATTRIBUTE_OBJROOT "${PROJECT_BINARY_DIR}/build" )
  #set_property( TARGET ${target} PROPERTY XCODE_ATTRIBUTE_SYMROOT "${PROJECT_BINARY_DIR}/lib"   )
  set_property( TARGET ${target} PROPERTY OUTPUT_NAME             "${base_target_name}_${TNUN_os_suffix}" )
endfunction()
