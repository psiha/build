################################################################################
#
# PSI Main build (compiler&linker) options file.
#
# Copyright (c) Domagoj Saric.
#
################################################################################


################################################################################
#
# add_compile_options()
#
################################################################################

# Similar to the builtin add_compile_options, but receives build configuration as a first
# parameter. Abstracts-away usage of generator expressions.
function( PSI_add_compile_options configuration )
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

function( PSI_target_compile_options configuration target visibility )
    foreach( arg ${ARGN} )
        target_compile_options( ${target} ${visibility} $<$<CONFIG:${configuration}>:${arg}> )
    endforeach()
endfunction()

# Similar to the builtin add_compile_options, but applies given options
# only to the c++ sources.
function( PSI_add_cxx_compile_options )
    if( ${CMAKE_GENERATOR} MATCHES "Visual Studio" )
        add_compile_options( ${ARGV} )
    else()
        foreach( arg ${ARGV} )
            add_compile_options( $<$<COMPILE_LANGUAGE:CXX>:${arg}> )
        endforeach()
    endif()
endfunction()

# Behaves as the combination of PSI_add_compile_options and
# PSI_add_cxx_compile_options - it applies given options only to
# C++ sources for a given build configuration.
function( PSI_add_cxx_compile_options_for_config configuration )
    if( ${CMAKE_GENERATOR} MATCHES "Visual Studio" )
        foreach( arg ${ARGN} )
            add_compile_options( $<$<CONFIG:${configuration}>:${arg}> )
        endforeach()
    else()
        foreach( arg ${ARGN} )
            add_compile_options( $<$<AND:$<CONFIG:${configuration}>,$<COMPILE_LANGUAGE:CXX>>:${arg}> )
        endforeach()
    endif()
endfunction()

# Removes already set compile options for a given configuration.
# Useful for unsetting flags set with the PSI_add_compile_options
function( PSI_remove_compile_options_for_config configuration )
    string( TOUPPER ${configuration} configuration )
    get_directory_property( current_compile_options COMPILE_OPTIONS )
    foreach( arg ${ARGN} )
        set( option $<$<CONFIG:${configuration}>:${arg}> )
        string( REPLACE "${option}" "" current_compile_options "${current_compile_options}" )
    endforeach()
    set_directory_properties( PROPERTIES COMPILE_OPTIONS "${current_compile_options}" )
endfunction()

# Removes given compile options if they are already set.
# Useful for undoing CMake's builtin add_compile_options.
function( PSI_remove_compile_options )
    get_directory_property( current_compile_options COMPILE_OPTIONS )
    foreach( option ${ARGN} )
        string( REPLACE "${option}" "" current_compile_options "${current_compile_options}" )
    endforeach()
    set_directory_properties( PROPERTIES COMPILE_OPTIONS "${current_compile_options}" )
endfunction()

# Removes given compile options from given target for given build type.
# Useful for undoing CMake's builtin target_compile_options
function( PSI_target_remove_compile_options_for_config target configuration )
    string( TOUPPER ${configuration} configuration )
    get_target_property( current_compile_options ${target} COMPILE_OPTIONS )
    foreach( arg ${ARGN} )
        set( option $<$<CONFIG:${configuration}>:${arg}> )
        string( REPLACE "${option}" "" current_compile_options "${current_compile_options}" )
    endforeach()
    set_target_properties( ${target} PROPERTIES COMPILE_OPTIONS "${current_compile_options}" )
endfunction()

# Removes given compile options from given target.
# Useful for undoing CMake's builtin target_compile_options
function( PSI_target_remove_compile_options target )
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

# Similar to CMake's builtin add_link_options, but applies given options only
# to the given build type.
function( PSI_add_link_options configuration )
    foreach( arg ${ARGN} )
        add_link_options( $<$<CONFIG:${configuration}>:${arg}> )
    endforeach()
endfunction()

function( PSI_target_link_options configuration target visibility )
    foreach( arg ${ARGN} )
        target_link_options( ${target} ${visibility} $<$<CONFIG:${configuration}>:${arg}> )
    endforeach()
endfunction()

# Removes given link options for given build type.
# Useful for undoing the effect of PSI_add_link_options
function( PSI_remove_link_options_for_config configuration )
    string( TOUPPER ${configuration} configuration )
    get_directory_property( current_link_options LINK_OPTIONS )
    foreach( arg ${ARGN} )
        set( option $<$<CONFIG:${configuration}>:${arg}> )
        string( REPLACE "${option}" "" current_link_options "${current_link_options}" )
    endforeach()
    set_directory_properties( PROPERTIES LINK_OPTIONS "${current_link_options}" )
endfunction()

# Removes given link options.
# Useful for undoing CMake's builtin add_link_options.
function( PSI_remove_link_options )
    get_directory_property( current_link_options LINK_OPTIONS )
    foreach( option ${ARGN} )
        string( REPLACE "${option}" "" current_link_options "${current_link_options}" )
    endforeach()
    set_directory_properties( PROPERTIES LINK_OPTIONS "${current_link_options}" )
endfunction()

# Removes given link options from given target for given build type.
# Useful for undoing CMake's builtin target_link_options.
function( PSI_target_remove_link_options_for_config target configuration )
    string( TOUPPER ${configuration} configuration )
    get_target_property( current_link_options ${target} LINK_OPTIONS )
    foreach( arg ${ARGN} )
        set( option $<$<CONFIG:${configuration}>:${arg}> )
        string( REPLACE "${option}" "" current_link_options "${current_link_options}" )
    endforeach()
    set_target_properties( ${target} PROPERTIES LINK_OPTIONS "${current_link_options}" )
endfunction()

# Removes given link options from given target.
# Useful for undoing CMake's builtin target_link_options.
function( PSI_target_remove_link_options target )
    string( TOUPPER ${configuration} configuration )
    get_target_property( current_link_options ${target} LINK_OPTIONS )
    foreach( arg ${ARGN} )
        set( option ${arg} )
        string( REPLACE "${option}" "" current_link_options "${current_link_options}" )
    endforeach()
    set_target_properties( ${target} PROPERTIES LINK_OPTIONS "${current_link_options}" )
endfunction()

# w/ LTO enabled w/ non-Xcode generators/build environment debug symbols (i.e.
# the intermediate files containing them) "vanish" - to workaround this we
# order the linker to save the final .obj
# https://clang.llvm.org/docs/CommandGuide/clang.html#cmdoption-flto
# https://github.com/llvm/llvm-project/issues/113973
# https://stackoverflow.com/questions/71610020/debugger-doesnt-locate-symbols-in-source-when-interprocedural-optimization-is-e
# Have to place this function here (instead of the OSX toolchain) since there
# is no way w/ CMake to checkwhether a function exists (and provide a dummy
# implementation otherwise).
function( PSI_target_fix_debug_symbols_for_osx_lto target )
  if ( APPLE AND NOT CMAKE_GENERATOR STREQUAL "Xcode" ) # for simplicity do not check whether LTO is enabled 
    target_link_options( ${target} PRIVATE -Wl,-object_path_lto,${CMAKE_BINARY_DIR}/${target}_lto.o )
    # This step is not strictly necessary when using the default/Apple linker
    # (it produces a single lto .o file which the debugger is able to pickup)
    # but is with LLVM's lld (which produces an LTO directory with many .o
    # files).
    add_custom_command( TARGET ${target} POST_BUILD COMMAND dsymutil $<TARGET_FILE_DIR:${target}>/${target} VERBATIM )
  endif()
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
elseif( ANDROID_TOOLCHAIN ) # PSI android.toolchain.cmake does not define this variable, while native Android Studio toolchain does
    include( "${CMAKE_CURRENT_LIST_DIR}/toolchains/android-studio.toolchain.cmake" )
elseif( EMSCRIPTEN )
    include( "${CMAKE_CURRENT_LIST_DIR}/toolchains/emscripten.cmake" )
else()
    # Android and iOS (crosscompiling platforms) have to specify the toolchain
    # file explicitly.
endif()


################################################################################
# malloc overcommit policies
# https://www.etalabs.net/overcommit.html
################################################################################

set( PSI_MALLOC_OVERCOMMIT_POLICY ${PSI_MALLOC_OVERCOMMIT_POLICY_default} CACHE STRING "Assumed OS policy/implementation WRT memory allocation overcommit" )
set_property( CACHE PSI_MALLOC_OVERCOMMIT_POLICY PROPERTY STRINGS Disabled Partial Full )
list( APPEND PSI_common_compile_definitions
    PSI_OVERCOMMIT_Disabled=0
    PSI_OVERCOMMIT_Partial=1
    PSI_OVERCOMMIT_Full=2
    PSI_MALLOC_OVERCOMMIT=PSI_OVERCOMMIT_${PSI_MALLOC_OVERCOMMIT_POLICY}
)
if ( PSI_MALLOC_OVERCOMMIT_POLICY STREQUAL Full )
    list( APPEND PSI_common_compile_definitions PSI_NOEXCEPT_EXCEPT_BADALLOC=noexcept )
else()
    list( APPEND PSI_common_compile_definitions PSI_NOEXCEPT_EXCEPT_BADALLOC= )
endif()


set( PSI_compiler_dev_release_flags ${PSI_compiler_release_flags} )
string( REPLACE "NDEBUG" "DEBUG" PSI_compiler_dev_release_flags "${PSI_compiler_dev_release_flags}" )
if ( MSVC )
    string( REPLACE "MD" "MDd" PSI_compiler_dev_release_flags "${PSI_compiler_dev_release_flags}" )
endif()
list( APPEND PSI_compiler_release_flags -DNDEBUG )
if( NOT PSI_DO_NOT_ADD_DEFAULT_BUILD_FLAGS )
    PSI_add_compile_options( Debug      ${PSI_compiler_debug_flags}       ${PSI_compiler_debug_symbols}          )
    PSI_add_compile_options( Release    ${PSI_compiler_release_flags}                                            )
    PSI_add_compile_options( DevRelease ${PSI_compiler_dev_release_flags} ${PSI_compiler_debug_symbols} -D_DEBUG )

    add_compile_options    ( ${PSI_common_compiler_options} ${PSI_default_warnings}             )
    add_compile_definitions( ${PSI_common_compile_definitions}                                  )
    add_link_options       ( ${PSI_common_link_options}                                         )
    PSI_add_link_options   ( Debug      ${PSI_linker_debug_symbols}                             )
    PSI_add_link_options   ( Release    ${PSI_linker_release_flags}                             )
    PSI_add_link_options   ( DevRelease ${PSI_linker_release_flags} ${PSI_linker_debug_symbols} )
endif()

# https://gitlab.kitware.com/cmake/cmake/-/issues/25725
set( CMAKE_C_STANDARD   23 )
set( CMAKE_CXX_STANDARD 26 )
set( CMAKE_CXX_EXTENSIONS ON )
