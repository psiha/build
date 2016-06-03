################################################################################
#
# T:N.U.N. Android CMake toolchain file.
#
# Copyright (c) 2016. Domagoj Saric. All rights reserved.
#
# In large part, a heavily trimmed down version of the OpenCV/taka-no-me
# version (NDK r11+, Clang only).
#
# https://github.com/Itseez/opencv/blob/master/platforms/android/android.toolchain.cmake
# http://code.opencv.org/projects/opencv/repository/revisions/master/changes/platforms/android/android.toolchain.cmake
# https://github.com/taka-no-me/android-cmake/blob/master/android.toolchain.cmake
# https://github.com/chenxiaolong/android-cmake/blob/mbp/android.toolchain.cmake
# https://gitlab.kitware.com/vtk/vtk/blob/master/CMake/android.toolchain.cmake
# https://gitlab.kitware.com/vtk/vtk/blob/master/CMake/vtkAndroid.cmake
# https://llvm.org/svn/llvm-project/lldb/trunk/cmake/platforms/Android.cmake
#
################################################################################


set( CMAKE_CONFIGURATION_TYPES Release CACHE STRING "Supported configuartion types" FORCE )
set( CMAKE_BUILD_TYPE          Release CACHE STRING "Target configuration"          FORCE )

include( "${CMAKE_CURRENT_LIST_DIR}/clang.cmake" )
include( "${CMAKE_CURRENT_LIST_DIR}/../utilities.cmake" )

################################################################################
# Ninja setup
#
# Implementation note: For simplicity sake, assume that Android builds use Ninja
# and perform automatic setup. Currently also assumes Windows as the host OS
# for Android builds, to be cleaned up...
#                                             (31.05.2016.) (Domagoj Saric)
################################################################################

find_program( TNUN_ninja_path ninja )
if ( NOT TNUN_ninja_path )
    set( ninja_dl ninja-win.zip )
    TNUN_make_temp_path( ninja_dl )
    file( DOWNLOAD
        # https://github.com/ninja-build/ninja
        https://github.com/ninja-build/ninja/releases/download/v1.7.1/ninja-win.zip
        ${ninja_dl}
        STATUS success
        SHOW_PROGRESS
    )
    list( GET success 0 success )
    if ( NOT success EQUAL 0 )
        message( FATAL_ERROR "[TNUN] Error downloading Ninja." )
    endif()
    set( windir $ENV{windir} )
    execute_process( COMMAND ${CMAKE_COMMAND} -E tar xzf
        "${ninja_dl}"
        WORKING_DIRECTORY "${windir}"
        RESULT_VARIABLE success
        OUTPUT_VARIABLE output
        ERROR_VARIABLE  output
    )
    if ( NOT success EQUAL 0 )
        message( FATAL_ERROR "[TNUN] Error extracting Ninja to ${windir}." )
    endif()
endif( NOT TNUN_ninja_path )


################################################################################
# NDK location
# https://github.com/android-ndk/ndk/wiki
################################################################################

if ( NOT ANDROID_NDK )
    set( ANDROID_NDK "$ENV{ANDROID_NDK}" )
    if ( NOT ANDROID_NDK )
        set( android_ndk_default_version r12-beta2 )
        if ( ANDROID_NDK_ROOT )
            set( ANDROID_NDK "${ANDROID_NDK_ROOT}/android-ndk-${android_ndk_default_version}" )
        else()
            set( ANDROID_NDK "$ENV{TNUN_3rd_party_root}/Android/NDK/android-ndk-${android_ndk_default_version}" )
        endif()
    endif()
    if( NOT IS_DIRECTORY ${ANDROID_NDK} )
        message( FATAL_ERROR "[TNUN] Cannot find Android NDK." )
    endif()
endif ( NOT ANDROID_NDK )


# Standard settings
set( CMAKE_SYSTEM_NAME    Android )
set( CMAKE_SYSTEM_VERSION 2.6     )

set( ANDROID true )
set( UNIX    true )

set( TNUN_os_suffix Android )

# Detect current host platform (to support builds on 32 bit hosts).
if ( NOT DEFINED ANDROID_NDK_HOST_X64 AND (CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "amd64|x86_64|AMD64" OR CMAKE_HOST_APPLE) )
  set( ANDROID_NDK_HOST_X64 1 )
endif()

set( TOOL_OS_SUFFIX "" )
if( CMAKE_HOST_APPLE )
  set( ANDROID_NDK_HOST_SYSTEM_NAME "darwin-x86_64" )
elseif( CMAKE_HOST_WIN32 )
  if ( ANDROID_NDK_HOST_X64 )
    set( ANDROID_NDK_HOST_SYSTEM_NAME "windows-x86_64" )
  else()
    set( ANDROID_NDK_HOST_SYSTEM_NAME "windows" )
  endif()
  set( TOOL_OS_SUFFIX ".exe" )
elseif( CMAKE_HOST_UNIX )
  if ( ANDROID_NDK_HOST_X64 )
    set( ANDROID_NDK_HOST_SYSTEM_NAME "linux-x86_64" )
  else()
    set( ANDROID_NDK_HOST_SYSTEM_NAME "linux-x86" )
  endif()
else()
  message( FATAL_ERROR "[TNUN] Cross-compilation on your platform is not supported by this CMake toolchain" )
endif()


set( ANDROID_NDK_TOOLCHAINS_PATH    "${ANDROID_NDK}/toolchains" )
set( ANDROID_NDK_TOOLCHAINS_SUBPATH "/prebuilt/${ANDROID_NDK_HOST_SYSTEM_NAME}" )
set( ANDROID_CLANG_TOOLCHAIN_ROOT   "${ANDROID_NDK_TOOLCHAINS_PATH}/llvm${ANDROID_NDK_TOOLCHAINS_SUBPATH}" )


set( TNUN_ABIs
  aarch64-linux-android
  arm-linux-androideabi
  x86_64
  x86
)


if( NOT DEFINED TNUN_ABI )
  include( CMakeForceCompiler )
  CMAKE_FORCE_CXX_COMPILER( "${CMAKE_COMMAND}" none_yet )
  CMAKE_FORCE_C_COMPILER  ( "${CMAKE_COMMAND}" none_yet )
  #...mrmlj...this fails to work...the sub-builds, even though they get a properly defined TNUN_ABI fail @ the compiler check !??
  #return()
  #...mrmlj...as a workaround set a default abi to make the checks pass and then unset it at the end (so that sub_project.cmake can detect that this is the root 'invocation' and skip creating any targets)...
  set( TNUN_ABI arm-linux-androideabi )
  set( TNUN_internal_workaround_unset_abi true )
endif()


if ( NOT ANDROID_NATIVE_API_LEVEL )
    if ( TNUN_ABI MATCHES arm-linux-androideabi )
    set( ANDROID_NATIVE_API_LEVEL 15 ) # ICS
  elseif ( TNUN_ABI STREQUAL x86 )
    set( ANDROID_NATIVE_API_LEVEL 18 ) # JB
  else() # 64bit
    set( ANDROID_NATIVE_API_LEVEL 21 ) # L
  endif()
endif()

set( CMAKE_ANDROID_API_MIN ${ANDROID_NATIVE_API_LEVEL} )
if ( CROSS_COMPILING )
  message( STATUS "[TNUN] Targeting Android API level ${ANDROID_NATIVE_API_LEVEL}." )
endif()

set( CMAKE_ANDROID_STL_TYPE c++_static )

set( gcc_ver   4.9 )
set( abi_sufix ""  )

# http://clang.llvm.org/docs/CrossCompilation.html
set( TNUN_arch_include_dir "${CMAKE_CURRENT_LIST_DIR}/android" )
include( "${TNUN_arch_include_dir}/${TNUN_ABI}.abi.cmake" )

set( ANDROID_GCC_TOOLCHAIN_NAME "${TNUN_ABI}-${gcc_ver}" )
set( ANDROID_TOOLCHAIN_ROOT     "${ANDROID_NDK_TOOLCHAINS_PATH}/${ANDROID_GCC_TOOLCHAIN_NAME}${ANDROID_NDK_TOOLCHAINS_SUBPATH}" )
set( ANDROID_LLVM_TRIPLE        "${CMAKE_SYSTEM_PROCESSOR}-none-linux-android${abi_sufix}" )

# Global includes and link directories
# Android support files
set( ANDROID_CXX_ROOT         "${ANDROID_NDK}/sources/cxx-stl"                       )
set( ANDROID_LLVM_ROOT        "${ANDROID_CXX_ROOT}/llvm-libc++"                      )
set( TNUN_ABI_INCLUDE_DIRS "${ANDROID_CXX_ROOT}/llvm-libc++abi/libcxxabi/include" )
set( ANDROID_STL_INCLUDE_DIRS "${ANDROID_LLVM_ROOT}/libcxx/include"
                              "${TNUN_ABI_INCLUDE_DIRS}"                          )
set( ANDROID_SYSROOT          "${ANDROID_NDK}/platforms/android-${ANDROID_NATIVE_API_LEVEL}/arch-${ANDROID_ARCH_NAME}" )

# where is the target environment
set( CMAKE_FIND_ROOT_PATH "${ANDROID_TOOLCHAIN_ROOT}/bin" "${ANDROID_TOOLCHAIN_ROOT}/${ANDROID_GCC_MACHINE_NAME}" "${ANDROID_SYSROOT}" "${CMAKE_INSTALL_PREFIX}" "${CMAKE_INSTALL_PREFIX}/share" )


# Implementation note: These "basic toolchain flags" have to be added to the
# compiler flags but also to the linker flags in order for the "Check for
# working CXX compiler" test to succeed.
# link_libraries() is (ab)used (see the related note in build_options.cmake) in
# order to avoid messing with/polluting the cache (this has a tendency to append
# the same flags on every configure run) with the CMAKE_*_*_FLAGS variables.
# And in the great mess that is CMake add_compile_options() and link_libraries()
# want their parameters specified in different ways (link_libraries() requires a
# list, not a quoted string, but 'paired options' such as -target <my_triple>
# have to be 'grouped' in quoted strings...and this is of course documented
# nowhere). So, to avoid duplication, 'some' transformation has to be done on
# the options in order to satisfy both functions.
#                                             (01.06.2016.) (Domagoj Saric)
set( ANDROID_BASIC_TOOLCHAIN_FLAGS "-target ${ANDROID_LLVM_TRIPLE}" "-gcc-toolchain ${ANDROID_TOOLCHAIN_ROOT}" "--sysroot=${ANDROID_SYSROOT}" )
foreach( a_flag ${ANDROID_BASIC_TOOLCHAIN_FLAGS} )
  string( REPLACE " " ";" a_flag "${a_flag}" )
  add_compile_options( ${a_flag} )
endforeach()
link_libraries( ${ANDROID_BASIC_TOOLCHAIN_FLAGS} )
link_libraries( "-Wl,--no-undefined" "-Wl,-z,relro" "-Wl,-z,now" "-Wl,-z,nocopyreloc" )
link_libraries( $<$<CONFIG:RELEASE>:-Wl,--gc-sections> )
link_libraries( $<$<CONFIG:RELEASE>:-Wl,--icf=all>     ) # http://research.google.com/pubs/pub36912.html Safe ICF: Pointer Safe and Unwinding Aware Identical Code Folding in Gold
#-fuse-ld=gold ...mrmlj...does not work with Android NDK r11 (but should be the default)


include_directories( SYSTEM ${ANDROID_NDK}/sources/android/support/include               )
include_directories( SYSTEM "${ANDROID_SYSROOT}/usr/include" ${ANDROID_STL_INCLUDE_DIRS} )
link_directories   ( "${ANDROID_SYSROOT}/usr/lib"                                        )

set( _CMAKE_TOOLCHAIN_PREFIX "${ANDROID_GCC_MACHINE_NAME}-" )
set( CMAKE_C_COMPILER   "${ANDROID_CLANG_TOOLCHAIN_ROOT}/bin/clang${TOOL_OS_SUFFIX}"                       )
set( CMAKE_CXX_COMPILER "${ANDROID_CLANG_TOOLCHAIN_ROOT}/bin/clang++${TOOL_OS_SUFFIX}"                     )
set( CMAKE_ASM_COMPILER "${ANDROID_TOOLCHAIN_ROOT}/bin/${_CMAKE_TOOLCHAIN_PREFIX}gcc${TOOL_OS_SUFFIX}"     )
set( CMAKE_STRIP        "${ANDROID_TOOLCHAIN_ROOT}/bin/${_CMAKE_TOOLCHAIN_PREFIX}strip${TOOL_OS_SUFFIX}"   )
set( CMAKE_AR           "${ANDROID_TOOLCHAIN_ROOT}/bin/${_CMAKE_TOOLCHAIN_PREFIX}gcc-ar${TOOL_OS_SUFFIX}"  )
set( CMAKE_LINKER       "${ANDROID_TOOLCHAIN_ROOT}/bin/${_CMAKE_TOOLCHAIN_PREFIX}ld${TOOL_OS_SUFFIX}"      )
set( CMAKE_NM           "${ANDROID_TOOLCHAIN_ROOT}/bin/${_CMAKE_TOOLCHAIN_PREFIX}nm${TOOL_OS_SUFFIX}"      )
set( CMAKE_OBJCOPY      "${ANDROID_TOOLCHAIN_ROOT}/bin/${_CMAKE_TOOLCHAIN_PREFIX}objcopy${TOOL_OS_SUFFIX}" )
set( CMAKE_OBJDUMP      "${ANDROID_TOOLCHAIN_ROOT}/bin/${_CMAKE_TOOLCHAIN_PREFIX}objdump${TOOL_OS_SUFFIX}" )
set( CMAKE_RANLIB       "${ANDROID_TOOLCHAIN_ROOT}/bin/${_CMAKE_TOOLCHAIN_PREFIX}ranlib${TOOL_OS_SUFFIX}"  )

include( "${CMAKE_CURRENT_LIST_DIR}/clang.cmake" )

add_definitions( -DANDROID -D__ANDROID__ )

################################################################################
# TNUN_setup_target_for_arch()
################################################################################

function( TNUN_setup_target_for_arch target base_target_name arch )
  include( "${TNUN_arch_include_dir}/${arch}.arch.cmake" )

  # Standard Android directory layout for per-ABI libraries:
  # https://developer.android.com/ndk/guides/abis.html#sa
  set( LIBRARY_OUTPUT_PATH "${TNUN_binary_dir}/lib/${ANDROID_NDK_ABI_NAME}" )
  set_property( TARGET ${target} PROPERTY ARCHIVE_OUTPUT_DIRECTORY "${LIBRARY_OUTPUT_PATH}" )
  set_property( TARGET ${target} PROPERTY LIBRARY_OUTPUT_DIRECTORY "${LIBRARY_OUTPUT_PATH}" )
  set_property( TARGET ${target} PROPERTY OUTPUT_NAME              "${base_target_name}_${TNUN_arch_suffix}_${TNUN_os_suffix}" )

  set( runtime_libs_dir "${ANDROID_LLVM_ROOT}/libs/${ANDROID_NDK_ABI_NAME}" )
  link_directories      ( "${runtime_libs_dir}" ) #...mrmlj...no target_link_directories http://stackoverflow.com/questions/25164041/is-there-a-link-directories-or-equivilent-property-in-cmake
  target_link_libraries ( ${target} "${runtime_libs_dir}/libc++.a" )
  target_compile_options( ${target} PRIVATE ${TNUN_arch_compiler_options} )
endfunction()


# macro to find packages on the host OS
macro( find_host_package )
 set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER )
 set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY NEVER )
 set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE NEVER )
 if( CMAKE_HOST_WIN32 )
  SET( WIN32 1 )
  SET( UNIX )
 elseif( CMAKE_HOST_APPLE )
  SET( APPLE 1 )
  SET( UNIX )
 endif()
 find_package( ${ARGN} )
 SET( WIN32 )
 SET( APPLE )
 SET( UNIX 1 )
 set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM ONLY )
 set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY )
 set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY )
endmacro()


# macro to find programs on the host OS
macro( find_host_program )
 set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER )
 set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY NEVER )
 set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE NEVER )
 if( CMAKE_HOST_WIN32 )
  SET( WIN32 1 )
  SET( UNIX )
 elseif( CMAKE_HOST_APPLE )
  SET( APPLE 1 )
  SET( UNIX )
 endif()
 find_program( ${ARGN} )
 SET( WIN32 )
 SET( APPLE )
 SET( UNIX 1 )
 set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM ONLY )
 set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY )
 set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY )
endmacro()

#...mrmlj...ugh...
if ( TNUN_internal_workaround_unset_abi )
  unset( TNUN_ABI )
endif()
