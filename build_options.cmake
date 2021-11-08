################################################################################
#
# T:N.U.N. Main build (compiler&linker) options file.
#
# Copyright (c) 2016 - 2017. Domagoj Saric.
#
################################################################################


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

function( TNUN_remove_compile_options_for_config configuration )
    string( TOUPPER ${configuration} configuration )
    get_directory_property( current_compile_options COMPILE_OPTIONS )
    foreach( arg ${ARGN} )
        set( option $<$<CONFIG:${configuration}>:${arg}> )
        string( REPLACE "${option}" "" current_compile_options "${current_compile_options}" )
    endforeach()
    set_directory_properties( PROPERTIES COMPILE_OPTIONS "${current_compile_options}" )
endfunction()

function( TNUN_remove_compile_options )
    get_directory_property( current_compile_options COMPILE_OPTIONS )
    foreach( option ${ARGN} )
        string( REPLACE "${option}" "" current_compile_options "${current_compile_options}" )
    endforeach()
    set_directory_properties( PROPERTIES COMPILE_OPTIONS "${current_compile_options}" )
endfunction()

function( TNUN_target_remove_compile_options_for_config target configuration )
    string( TOUPPER ${configuration} configuration )
    get_target_property( current_compile_options ${target} COMPILE_OPTIONS )
    foreach( arg ${ARGN} )
        set( option $<$<CONFIG:${configuration}>:${arg}> )
        string( REPLACE "${option}" "" current_compile_options "${current_compile_options}" )
    endforeach()
    set_target_properties( ${target} PROPERTIES COMPILE_OPTIONS "${current_compile_options}" )
endfunction()

function( TNUN_target_remove_compile_options target )
    string( TOUPPER ${configuration} configuration )
    get_target_property( current_compile_options ${target} COMPILE_OPTIONS )
    foreach( arg ${ARGN} )
        set( option ${arg} )
        string( REPLACE "${option}" "" current_compile_options "${current_compile_options}" )
    endforeach()
    set_target_properties( ${target} PROPERTIES COMPILE_OPTIONS "${current_compile_options}" )
endfunction()

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
        add_link_options( $<$<CONFIG:${configuration}>:${arg}> )
    endforeach()
endfunction()

function( TNUN_remove_link_options_for_config configuration )
    string( TOUPPER ${configuration} configuration )
    get_directory_property( current_link_options LINK_OPTIONS )
    foreach( arg ${ARGN} )
        set( option $<$<CONFIG:${configuration}>:${arg}> )
        string( REPLACE "${option}" "" current_link_options "${current_link_options}" )
    endforeach()
    set_directory_properties( PROPERTIES LINK_OPTIONS "${current_link_options}" )
endfunction()

function( TNUN_remove_link_options )
    get_directory_property( current_link_options LINK_OPTIONS )
    foreach( option ${ARGN} )
        string( REPLACE "${option}" "" current_link_options "${current_link_options}" )
    endforeach()
    set_directory_properties( PROPERTIES LINK_OPTIONS "${current_link_options}" )
endfunction()

function( TNUN_target_remove_link_options_for_config target configuration )
    string( TOUPPER ${configuration} configuration )
    get_target_property( current_link_options ${target} LINK_OPTIONS )
    foreach( arg ${ARGN} )
        set( option $<$<CONFIG:${configuration}>:${arg}> )
        string( REPLACE "${option}" "" current_link_options "${current_link_options}" )
    endforeach()
    set_target_properties( ${target} PROPERTIES LINK_OPTIONS "${current_link_options}" )
endfunction()

function( TNUN_target_remove_link_options target )
    string( TOUPPER ${configuration} configuration )
    get_target_property( current_link_options ${target} LINK_OPTIONS )
    foreach( arg ${ARGN} )
        set( option ${arg} )
        string( REPLACE "${option}" "" current_link_options "${current_link_options}" )
    endforeach()
    set_target_properties( ${target} PROPERTIES LINK_OPTIONS "${current_link_options}" )
endfunction()

################################################################################
# default options
################################################################################

# http://www.cmake.org/Wiki/CMake_Cross_Compiling
# https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html
# http://stackoverflow.com/questions/12802377/in-cmake-how-can-i-find-the-directory-of-an-included-file
if ( WIN32 ) # TODO: add detection of Windows Phone / Windows Universal platform
    include( "${CMAKE_CURRENT_LIST_DIR}/toolchains/windows.toolchain.cmake" )
elseif( APPLE AND NOT iOS )
    include( "${CMAKE_CURRENT_LIST_DIR}/toolchains/osx.toolchain.cmake" )
elseif( ${CMAKE_SYSTEM_NAME} MATCHES "Linux" )
    include( "${CMAKE_CURRENT_LIST_DIR}/toolchains/linux.toolchain.cmake" )
elseif( ANDROID_TOOLCHAIN ) # TNUN android.toolchain.cmake does not define this variable, while native Android Studio toolchain does
    include( "${CMAKE_CURRENT_LIST_DIR}/toolchains/android-studio.toolchain.cmake" )
elseif( EMSCRIPTEN )
    include( "${CMAKE_CURRENT_LIST_DIR}/toolchains/emscripten.cmake" )
else()
    # Android and iOS (crosscompiling platforms) have to specify the toolchain
    # file explicitly.
endif()

set( TNUN_compiler_dev_release_flags ${TNUN_compiler_release_flags} )
if ( MSVC )
    string( REPLACE "MD" "MDd" TNUN_compiler_dev_release_flags "${TNUN_compiler_dev_release_flags}" )
endif()
list( APPEND TNUN_compiler_release_flags -DNDEBUG )
if( NOT TNUN_DO_NOT_ADD_DEFAULT_BUILD_FLAGS )
    TNUN_add_compile_options( Debug   ${TNUN_compiler_debug_flags} ${TNUN_compiler_debug_symbols} )
    TNUN_add_compile_options( Release ${TNUN_compiler_release_flags} )
    add_compile_options( ${TNUN_default_warnings} )
    TNUN_add_link_options( Release ${TNUN_linker_release_flags} )
endif()


################################################################################
# malloc overcommit policies
# https://www.etalabs.net/overcommit.html
################################################################################

add_definitions(
    -DTNUN_OVERCOMMIT_Disabled=0
    -DTNUN_OVERCOMMIT_Partial=1
    -DTNUN_OVERCOMMIT_Full=2
    -DTNUN_MALLOC_OVERCOMMIT=TNUN_OVERCOMMIT_${TNUN_MALLOC_OVERCOMMIT_POLICY}
)

if ( TNUN_MALLOC_OVERCOMMIT_POLICY STREQUAL Full )
  add_definitions( -DTNUN_NOEXCEPT_EXCEPT_BADALLOC=noexcept )
else()
  add_definitions( -DTNUN_NOEXCEPT_EXCEPT_BADALLOC= )
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
