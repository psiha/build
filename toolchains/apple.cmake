################################################################################
#
# PSI Shared toolchain for Apple platforms.
#
# Copyright (c) Domagoj Saric.
#
################################################################################

# https://developer.apple.com/library/mac/documentation/DeveloperTools/Reference/XcodeBuildSettingRef/1-Build_Setting_Reference/build_setting_ref.html

set( CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LIBRARY libc++ )

set( CMAKE_XCODE_ATTRIBUTE_ARCHS            "$(ARCHS_STANDARD)" ) # http://www.cocoanetics.com/2014/10/xcode-6-drops-armv7s
set( CMAKE_XCODE_ATTRIBUTE_VALID_ARCHS      "$(ARCHS_STANDARD)" )
set( CMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH NO                  )

# Xcode 14 no longer supports armv7 and i386
if ( XCODE AND XCODE_VERSION VERSION_GREATER_EQUAL "14.0.0" )
    set( CMAKE_OSX_ARCHITECTURES "arm64;x86_64" )
endif()

set( CMAKE_XCODE_ATTRIBUTE_GCC_C_LANGUAGE_STANDARD     gnu11   )
set( CMAKE_XCODE_ATTRIBUTE_GCC_CXX_LANGUAGE_STANDARD   gnu++17 )
set( CMAKE_XCODE_ATTRIBUTE_GCC_C++_LANGUAGE_STANDARD   gnu++17 )
set( CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LANGUAGE_STANDARD gnu++17 )

# https://cmake.org/cmake/help/latest/policy/CMP0025.html
# Required to distinguish AppleClang from true Clang on Apple platform
cmake_policy( SET CMP0025 NEW )

if( ${CMAKE_CXX_COMPILER_ID} MATCHES "Clang" )
    include( "${CMAKE_CURRENT_LIST_DIR}/clang.cmake" )
    list( APPEND PSI_common_compiler_options -fconstant-cfstrings -fobjc-call-cxx-cdtors )
else()
    include( "${CMAKE_CURRENT_LIST_DIR}/gcc_compatibles.cmake" )
    list( APPEND PSI_common_compiler_options -mconstant-cfstrings )
endif()

# Xcode (7 & 8) report that function-sections are incompatible embed-bitcode
set( CMAKE_XCODE_ATTRIBUTE_ENABLE_BITCODE "NO" )
macro( PSI_enable_bitcode )
  # -ffunction-sections is not supported with -fembed-bitcode
  # Also, on Xcode 8.2:
  # -fno-function-sections is not supported with -fembed-bitcode
  # So, we need to ensure this neither of those flag is ever set.

    if ( XCODE )
        list( REMOVE_ITEM PSI_compiler_release_flags -ffunction-sections )

        set( CMAKE_XCODE_ATTRIBUTE_ENABLE_BITCODE[variant=Release]          "YES"     )
        set( CMAKE_XCODE_ATTRIBUTE_BITCODE_GENERATION_MODE[variant=Release] "bitcode" ) # Without this, Xcode adds -fembed-bitcode-marker compile options instead of -fembed-bitcode

        # -mllvm and -bitcode_bundle (Xcode setting ENABLE_BITCODE=YES) cannot be used together
        list( REMOVE_ITEM PSI_linker_LTO -Wl,-mllvm,-threads=${PSI_linker_LTO_jobs} )
    else()
        list( APPEND PSI_common_compiler_options $<$<CONFIG:Release>:-fembed-bitcode> )
    endif()
endmacro()

list( APPEND PSI_common_link_options $<$<CONFIG:RELEASE>:-dead_strip> )

set( PSI_ABI   default   )
set( PSI_ABIs ${PSI_ABI} )

################################################################################
# malloc overcommit policy
#
# iOS's behaviour (the "jetsam" mechanism) seems very similar to Android's
# overcommit policy _and_ is non-configurable (through public APIs) - IOW:
# disable/omit all memalloc failure handling there.
# OSX uses a very similar mechanism as iOS ("memorystatus") yet it is not quite
# clear what it does after all the 'idle exit' processes are killed... -
# nonetheless use the same policy as for iOS.
# http://newosxbook.com/articles/MemoryPressure.html
# https://developer.apple.com/library/content/documentation/Performance/Conceptual/ManagingMemory/Articles/AboutMemory.html
#                                             (01.05.2017. Domagoj Saric)
################################################################################

set( PSI_MALLOC_OVERCOMMIT_POLICY Full )

#...mrmlj...reinvestigate this...
# set( CMAKE_XCODE_ATTRIBUTE_OBJROOT          "${PROJECT_BINARY_DIR}" )
# set( CMAKE_XCODE_ATTRIBUTE_BUILD_DIR        "${PROJECT_BINARY_DIR}" )
# set( CMAKE_XCODE_ATTRIBUTE_BUILD_ROOT       "${PROJECT_BINARY_DIR}" )
# set( CMAKE_XCODE_ATTRIBUTE_PROJECT_TEMP_DIR "${PROJECT_BINARY_DIR}" )
# set( CMAKE_XCODE_ATTRIBUTE_SYMROOT          "${PROJECT_BINARY_DIR}/lib" )
# set( CMAKE_XCODE_ATTRIBUTE_SYMROOT_RELEASE  "${PROJECT_BINARY_DIR}/lib" )
