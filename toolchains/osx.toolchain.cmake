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

set( CMAKE_OSX_ARCHITECTURES "$(ARCHS_STANDARD)" )