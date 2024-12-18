################################################################################
#
# PSI Android Studio CMake tool chain file. This is to be used together
# with the native android CMake toolchain bundled with Android studio 2.2+.
# For uses without Android Studio, please use the android.toolchain.cmake file.
#
# Copyright (c) 2016. Nenad Miksa.
#
################################################################################

set( CPACK_SYSTEM_NAME "Android" )

set( ANDROID true )

if( APPLE )
    unset( APPLE )
endif()

set( PSI_common_compile_definitions __ANDROID__ )

set( PSI_os_suffix Android )

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

string( REPLACE "-D_FORTIFY_SOURCE=2"      ""    ANDROID_COMPILER_FLAGS         "${ANDROID_COMPILER_FLAGS}" )
string( REPLACE "-D_FORTIFY_SOURCE=2"      ""    CMAKE_C_FLAGS                  "${CMAKE_C_FLAGS}  "        )
string( REPLACE "-D_FORTIFY_SOURCE=2"      ""    CMAKE_CXX_FLAGS                "${CMAKE_CXX_FLAGS}"        )
string( REPLACE "-D_FORTIFY_SOURCE=2"      ""    CMAKE_ASM_FLAGS                "${CMAKE_ASM_FLAGS}"        )

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
    unset( PSI_compiler_runtime_sanity_checks )
    unset( PSI_linker_runtime_sanity_checks )
    unset( PSI_compiler_runtime_integer_checks )
    unset( PSI_linker_runtime_integer_checks )
else()
    include( "${CMAKE_CURRENT_LIST_DIR}/gcc.cmake" )
endif()

# Re-enable source fortification only in debug/development builds
set( PSI_compiler_assertions -D_FORTIFY_SOURCE=2 )

set( PSI_arch_include_dir "${CMAKE_CURRENT_LIST_DIR}/android" )
set( PSI_ABI  ${ANDROID_ABI} )
set( PSI_ARCH ${ANDROID_ABI} )
if( ANDROID_ABI STREQUAL "armeabi-v7a" )
    set( PSI_ABI arm-linux-androideabi )
    if ( ANDROID_ARM_NEON )
        set( PSI_ARCH armv7-neon )
    else()
        set( PSI_ARCH armv7-vfp3d16 )
    endif()
elseif( ANDROID_ABI STREQUAL "arm64-v8a" )
    set( PSI_ABI  aarch64-linux-android )
    set( PSI_ARCH aarch64 )
endif()

if ( PSI_ARCH )
    include( "${PSI_arch_include_dir}/${PSI_ARCH}.arch.cmake" )
endif()
if ( PSI_ABI )
    include( "${PSI_arch_include_dir}/${PSI_ABI}.abi.cmake" )
endif()

# Some settings from android.toolchain.cmake which are better than in the
# default toolchain shipped with Android Studio.

list( APPEND PSI_common_link_options $<$<CONFIG:RELEASE>:-Wl,--icf=all>     ) # http://research.google.com/pubs/pub36912.html Safe ICF: Pointer Safe and Unwinding Aware Identical Code Folding in Gold
list( APPEND PSI_common_link_options $<$<CONFIG:RELEASE>:-Wl,--gc-sections> )


################################################################################
# malloc overcommit policy
#
# Android seems to have the most extreme overcommit policy, i.e. 'allow all
# memory allocations even if no RAM+swap is available' - IOW: disable/omit all
# memalloc failure handling there.
# https://groups.google.com/forum/#!topic/android-porting/l--HZ0urKVk
# https://bugzilla.mozilla.org/show_bug.cgi?id=600939
# https://forum.xda-developers.com/showthread.php?t=1621808
# https://groups.google.com/forum/m/#!topic/android-ndk/JhGRSv9KP6s
#                                             (01.05.2017. Domagoj Saric)
################################################################################

set( PSI_MALLOC_OVERCOMMIT_POLICY_default Full )


################################################################################
# PSI_setup_target_for_arch()
################################################################################

function( PSI_setup_target_for_arch target base_target_name arch )
  set_property( TARGET ${target} PROPERTY ARCHIVE_OUTPUT_DIRECTORY_RELEASE "${PROJECT_BINARY_DIR}/lib" )
  set_property( TARGET ${target} PROPERTY LIBRARY_OUTPUT_DIRECTORY_RELEASE "${PROJECT_BINARY_DIR}/lib" )
  set_property( TARGET ${target} PROPERTY OUTPUT_NAME                      "${base_target_name}_${PSI_os_suffix}" )
endfunction()
