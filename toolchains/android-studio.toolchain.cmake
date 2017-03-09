################################################################################
#
# T:N.U.N. Android Studio CMake tool chain file. This is to be used together with
# native android CMake toolchain bundled with Android studio 2.2 and newer.
# For uses without Android Studio, please use android.toolchain.cmake file.
#
# Copyright (c) 2016. Nenad Miksa. All rights reserved.
#
################################################################################

set( CPACK_SYSTEM_NAME "Android" )

set( ANDROID true )

if( APPLE )
    unset( APPLE )
endif()

add_definitions( -D__ANDROID__ )

set( TNUN_os_suffix Android )

set( CMAKE_CROSSCOMPILING true )

# Remove unwanted flags from the official toolchain file
string( REPLACE "-funwind-tables"          ""    ANDROID_COMPILER_FLAGS         "${ANDROID_COMPILER_FLAGS}" )
string( REPLACE "-funwind-tables"          ""    CMAKE_C_FLAGS                  "${CMAKE_C_FLAGS}  "        )
string( REPLACE "-funwind-tables"          ""    CMAKE_CXX_FLAGS                "${CMAKE_CXX_FLAGS}"        )
string( REPLACE "-funwind-tables"          ""    CMAKE_ASM_FLAGS                "${CMAKE_ASM_FLAGS}"        )

string( REPLACE "-fstack-protector-strong" ""    ANDROID_COMPILER_FLAGS         "${ANDROID_COMPILER_FLAGS}" )
string( REPLACE "-fstack-protector-strong" ""    CMAKE_C_FLAGS                  "${CMAKE_C_FLAGS}  "        )
string( REPLACE "-fstack-protector-strong" ""    CMAKE_CXX_FLAGS                "${CMAKE_CXX_FLAGS}"        )
string( REPLACE "-fstack-protector-strong" ""    CMAKE_ASM_FLAGS                "${CMAKE_ASM_FLAGS}"        )

string( REPLACE "-O2"                      "-O3" ANDROID_COMPILER_FLAGS_RELEASE "${ANDROID_COMPILER_FLAGS_RELEASE}" )
string( REPLACE "-O2"                      "-O3" CMAKE_C_FLAGS_RELEASE          "${CMAKE_C_FLAGS_RELEASE}  "        )
string( REPLACE "-O2"                      "-O3" CMAKE_CXX_FLAGS_RELEASE        "${CMAKE_CXX_FLAGS_RELEASE}"        )
string( REPLACE "-O2"                      "-O3" CMAKE_ASM_FLAGS_RELEASE        "${CMAKE_ASM_FLAGS_RELEASE}"        )

if("${ANDROID_TOOLCHAIN}" STREQUAL "clang")
    include( "${CMAKE_CURRENT_LIST_DIR}/clang.cmake" )

    # Implementation note:
    # This currently breaks with linker errors "undefined reference to
    # '__asan_report_load1', etc.
    # For now, just disable sanitization on Android. I will investigate this
    # later.
    #                                         (11.08.2016. Nenad Miksa)
    unset( TNUN_compiler_runtime_sanity_checks )
    unset( TNUN_linker_runtime_sanity_checks )
else()
    include( "${CMAKE_CURRENT_LIST_DIR}/gcc.cmake" )
endif()

set( TNUN_arch_include_dir "${CMAKE_CURRENT_LIST_DIR}/android" )

if( ANDROID_ABI STREQUAL "armeabi-v7a" )
    if ( ANDROID_ARM_NEON )
        include ( "${TNUN_arch_include_dir}/armv7-neon.arch.cmake" )
    else()
        include ( "${TNUN_arch_include_dir}/armv7-vfp3d16.arch.cmake" )
    endif()
elseif( ANDROID_ABI STREQUAL "arm64-v8a" )
    include( "${TNUN_arch_include_dir}/aarch64.arch.cmake" )
elseif( ANDROID_ABI STREQUAL "x86" )
    include( "${TNUN_arch_include_dir}/x86.arch.cmake" )
elseif( ANDROID_ABI STREQUAL "x86_64" )
    include( "${TNUN_arch_include_dir}/x86_64.arch.cmake" )
endif()

set( TNUN_ABI ${ANDROID_ABI} )

# Some settings from android.toolchain.cmake which are better than in default toolchain shipped with
# Android Studio.

# apparently gold is not supported on mips
if( NOT ( ANDROID_ABI STREQUAL "mips" OR ANDROID_ABI STREQUAL "mips64" ) )
    # Implementation note: https://github.com/android-ndk/ndk/issues/75
    #                                         (01.03.2017. Domagoj Saric)
    if ( CMAKE_HOST_WIN32 )
        set( gold_suffix ".exe" )
    endif()
    link_libraries( -fuse-ld=gold${gold_suffix} )
    link_libraries( $<$<CONFIG:RELEASE>:-Wl,--icf=all>     ) # http://research.google.com/pubs/pub36912.html Safe ICF: Pointer Safe and Unwinding Aware Identical Code Folding in Gold
endif()

link_libraries( $<$<CONFIG:RELEASE>:-Wl,--gc-sections> )

################################################################################
# TNUN_setup_target_for_arch()
################################################################################

function( TNUN_setup_target_for_arch target base_target_name arch )
  set_property( TARGET ${target} PROPERTY ARCHIVE_OUTPUT_DIRECTORY_RELEASE "${PROJECT_BINARY_DIR}/lib" )
  set_property( TARGET ${target} PROPERTY LIBRARY_OUTPUT_DIRECTORY_RELEASE "${PROJECT_BINARY_DIR}/lib" )
  set_property( TARGET ${target} PROPERTY OUTPUT_NAME                      "${base_target_name}_${TNUN_os_suffix}" )
endfunction()
