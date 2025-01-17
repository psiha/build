################################################################################
#
# PSI Apple OS X CMake tool chain file.
#
# Copyright (c) Domagoj Saric. All rights reserved.
#
################################################################################

cmake_minimum_required( VERSION 3.19 )

include( "${CMAKE_CURRENT_LIST_DIR}/apple.cmake" )

# MACOSX_RPATH
# cmake.org/cmake/help/latest/policy/CMP0042.html
# https://en.wikipedia.org/wiki/Rpath
# https://blog.kitware.com/upcoming-in-cmake-2-8-12-osx-rpath-support
# https://cmake.org/Wiki/CMake_RPATH_handling
# http://web.archive.org/web/20080602043910/http://people.debian.org/~che/personal/rpath-considered-harmful
# cmake_policy( SET CMP0042 OLD )
# set( CMAKE_MACOSX_RPATH 0 ) # even with the policy set CMake 3.5.2 still issues the warning?

set( CMAKE_OSX_DEPLOYMENT_TARGET 14.0 )

set( OSX true )

set( PSI_os_suffix OSX )

set( PSI_cpu_archs default )

set( PSI_LIBCPP_LOCATION /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include/c++/v1 )
include( ${CMAKE_CURRENT_LIST_DIR}/gcc_compatibles_stl.cmake )

################################################################################
# PSI_setup_target_for_arch()
################################################################################

function( PSI_setup_target_for_arch target base_target_name arch )
  set_property( TARGET ${target} PROPERTY ARCHIVE_OUTPUT_DIRECTORY_RELEASE "${PROJECT_BINARY_DIR}/lib" )
  set_property( TARGET ${target} PROPERTY LIBRARY_OUTPUT_DIRECTORY_RELEASE "${PROJECT_BINARY_DIR}/lib" )
  set_property( TARGET ${target} PROPERTY OUTPUT_NAME                      "${base_target_name}_${PSI_os_suffix}" )
endfunction()
