################################################################################
#
# T:N.U.N. Main build (compiler&linker) options file.
#
# Copyright (c) 2016. Domagoj Saric. All rights reserved.
#
################################################################################

# http://www.cmake.org/Wiki/CMake_Cross_Compiling
# https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html
# http://stackoverflow.com/questions/12802377/in-cmake-how-can-i-find-the-directory-of-an-included-file
if ( WIN32 ) # TODO: add detection of Windows Phone / Windows Universal platform
    include( "${CMAKE_CURRENT_LIST_DIR}/toolchains/msvc.toolchain.cmake" )
elseif( APPLE AND NOT iOS )
    include( "${CMAKE_CURRENT_LIST_DIR}/toolchains/osx.toolchain.cmake" )
elseif( ${CMAKE_SYSTEM_NAME} MATCHES "Linux" )
    include( "${CMAKE_CURRENT_LIST_DIR}/toolchains/linux.toolchain.cmake" )
elseif( ANDROID_TOOLCHAIN ) # TNUN android.toolchain.cmake does not define this variable, while native Android Studio toolchain does
    include( "${CMAKE_CURRENT_LIST_DIR}/toolchains/android-studio.toolchain.cmake" )
else()
    # Android and iOS (crosscompiling platforms) have to specify the toolchain
    # file explicitly.
endif()


# Implementation note:
# A workaround for the fact that the ios.universal_build.sh script uses
# 'intermediate' configuration types (*-iphoneos and *-simulator) one of which
# ends up being passed to CPack.
#                                             (15.03.2016.) (Domagoj Saric)
if ( iOS )
    set( install_configs "" )
else()
    set( install_configs Release )
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
    string( TOUPPER ${configuration} configuration )
    foreach( arg ${ARGN} )
        add_compile_options( $<$<CONFIG:${configuration}>:${arg}> )
    endforeach()
endfunction()

TNUN_add_compile_options( Debug ${TNUN_compiler_debug_flags} ${TNUN_compiler_debug_symbols} )
TNUN_add_compile_options( Release ${TNUN_compiler_release_flags} )

option( TNUN_DEBUG_SYMBOLS_IN_RELEASE "Generate debug symbols for easier debugging of release builds" false )
if ( ${TNUN_DEBUG_SYMBOLS_IN_RELEASE} )
    TNUN_add_compile_options( Release ${TNUN_compiler_debug_symbols} )
endif()

option( TNUN_ALLOW_EXCEPTIONS "Allow exception support in C++ code" true )
option( TNUN_ALLOW_RTTI "Allow Runtime Type Information in C++ code" false )

if( ${CMAKE_GENERATOR} MATCHES "Visual Studio" )
    if( ${TNUN_ALLOW_EXCEPTIONS} )
        add_compile_options( ${TNUN_compiler_exceptions_on} )
    else()
        add_compile_options( ${TNUN_compiler_exceptions_off} )
    endif()

    if( ${TNUN_ALLOW_RTTI} )
        add_compile_options( ${TNUN_compiler_rtti_on} )
    else()
        add_compile_options( ${TNUN_compiler_rtti_off} )
    endif()
else()
    if( ${TNUN_ALLOW_EXCEPTIONS} )
        add_compile_options( $<$<COMPILE_LANGUAGE:CXX>:${TNUN_compiler_exceptions_on}> )
    else()
        add_compile_options( $<$<COMPILE_LANGUAGE:CXX>:${TNUN_compiler_exceptions_off}> )
    endif()

    if( ${TNUN_ALLOW_RTTI} )
        add_compile_options( $<$<COMPILE_LANGUAGE:CXX>:${TNUN_compiler_rtti_on}> )
    else()
        add_compile_options( $<$<COMPILE_LANGUAGE:CXX>:${TNUN_compiler_rtti_off}> )
    endif()
endif()

option( TNUN_NATIVE_CPU_OPTIMIZATION "Perform optimizations specific to host CPU" true )
if( ${TNUN_NATIVE_CPU_OPTIMIZATION} )
    TNUN_add_compile_options( Release ${TNUN_native_optimization} )
endif()

################################################################################
#
# add_link_options()
#
################################################################################

function( TNUN_add_link_options configuration )
    # Implementation note:
    # The documented feature of link_libraries(), that it also accepts linker
    # options, is (ab)used here to simulate add_compile_options() behaviour.
    # https://cmake.org/cmake/help/latest/prop_tgt/LINK_LIBRARIES.html
    #                                         (01.06.2016.) (Domagoj Saric)
    string( TOUPPER ${configuration} configuration )
    foreach( arg ${ARGN} )
        link_libraries( $<$<CONFIG:${configuration}>:${arg}> )
    endforeach()
endfunction()

TNUN_add_link_options( Debug ${TNUN_linker_debug_flags} )
TNUN_add_link_options( Release ${TNUN_linker_release_flags} )
