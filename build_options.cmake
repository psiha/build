################################################################################
#
# T:N.U.N. Main build (compiler&linker) options file.
#
# Copyright (c) 2016. Domagoj Saric. All rights reserved.
#
################################################################################

# http://stackoverflow.com/questions/12802377/in-cmake-how-can-i-find-the-directory-of-an-included-file
if ( WIN32 )
    include( "${CMAKE_CURRENT_LIST_DIR}/toolchains/msvc.toolchain.cmake" )
elseif( APPLE AND NOT iOS )
    include( "${CMAKE_CURRENT_LIST_DIR}/toolchains/osx.toolchain.cmake" )
endif()

# For Android and iOS (crosscompiling platforms) have to specify the toolchain
# file explicitly.