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
else()
    # Android and iOS (crosscompiling platforms) have to specify the toolchain
    # file explicitly.
endif()


################################################################################
#
# add_compile_options()
#
################################################################################

function( TNUN_add_compile_options configuration )
    # Implementation note:
    # The builtin add_compile_options() seems broken (w/ CMake 3.5.2) when used
    # with multiple options: the "$<1" and ">" suffix end up in the compiler
    # options.
    # https://cmake.org/cmake/help/v3.5/command/add_compile_options.html
    # https://cmake.org/pipermail/cmake-developers/2012-August/016617.html
    # http://stackoverflow.com/a/35361099/6041906
    #                                         (14.05.2016.) (Domagoj Saric)
    foreach( arg ${ARGN} )
        add_compile_options( $<$<CONFIG:${configuration}>:${arg}> )
    endforeach()
endfunction()

TNUN_add_compile_options( Release ${TNUN_compiler_release_flags} )


################################################################################
#
# add_link_options()
#
################################################################################

function( TNUN_add_link_options configuration options )
    # Implementation note:
    # Function for symmetry/consistency with the TNUN_add_compile_options()
    # function (with a major the difference: this function accepts a single
    # string of options as opposed to a list).
    #                                         (24.05.2016.) (Domagoj Saric)
    string( TOUPPER ${configuration} configuration )
    set( CMAKE_EXE_LINKER_FLAGS_${configuration} "${CMAKE_EXE_LINKER_FLAGS_${configuration}} ${options}" PARENT_SCOPE )
endfunction()
