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

add_definitions( -D__ANDROID__ )

set( TNUN_os_suffix Android )

if("${ANDROID_TOOLCHAIN}" STREQUAL "clang")
    include( "${CMAKE_CURRENT_LIST_DIR}/clang.cmake" )
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
elseif( ANDROID_ABI STREQUAL "mips" )
    include( "${TNUN_arch_include_dir}/mipsel.arch.cmake" )
elseif( ANDROID_ABI STREQUAL "mips64" )
    include( "${TNUN_arch_include_dir}/mips64el.arch.cmake" )
elseif( ANDROID_ABI STREQUAL "x86" )
    include( "${TNUN_arch_include_dir}/x86.arch.cmake" )
elseif( ANDROID_ABI STREQUAL "x86_64" )
    include( "${TNUN_arch_include_dir}/x86_64.arch.cmake" )
endif()

# Some settings from android.toolchain.cmake which are better than in default toolchain shipped with
# Android Studio.

link_libraries( $<$<CONFIG:RELEASE>:-Wl,--gc-sections> )
link_libraries( $<$<CONFIG:RELEASE>:-Wl,--icf=all>     ) # http://research.google.com/pubs/pub36912.html Safe ICF: Pointer Safe and Unwinding Aware Identical Code Folding in Gold

################################################################################
# TNUN_setup_target_for_arch()
################################################################################

function( TNUN_setup_target_for_arch target base_target_name arch )
  set_property( TARGET ${target} PROPERTY ARCHIVE_OUTPUT_DIRECTORY_RELEASE "${PROJECT_BINARY_DIR}/lib" )
  set_property( TARGET ${target} PROPERTY LIBRARY_OUTPUT_DIRECTORY_RELEASE "${PROJECT_BINARY_DIR}/lib" )
  set_property( TARGET ${target} PROPERTY OUTPUT_NAME                      "${base_target_name}_${TNUN_os_suffix}" )
endfunction()