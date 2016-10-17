################################################################################
#
# T:N.U.N. iOS CMake tool chain file.
#
# Copyright (c) 2016. Domagoj Saric. All rights reserved.
#
# Adapted from bits&pieces gathered from various preexisting OSS solutions.
#
# http://www.cmake.org/Wiki/CMake_Cross_Compiling
#
# https://github.com/Kitware/VTK/blob/master/CMake/ios.toolchain.xcode.cmake
# https://github.com/cristeab/ios-cmake
# https://github.com/plenluno/ios-cmake
# https://code.google.com/archive/p/ios-cmake
# https://llvm.org/svn/llvm-project/llvm/trunk/cmake/platforms/iOS.cmake
# https://cmake.org/pipermail/cmake-developers/2014-September/023068.html [cmake-developers] iOS support
#
################################################################################


include( "${CMAKE_CURRENT_LIST_DIR}/apple.cmake" )
unset( TNUN_native_optimization ) # This makes no sense when cross-compiling.

# Standard settings
set( CMAKE_SYSTEM_NAME      Darwin )
set( CPACK_SYSTEM_NAME      iOS    )
set( CMAKE_SYSTEM_VERSION   6      )
set( CMAKE_SYSTEM_PROCESSOR arm    )
set( APPLE true )
set( iOS   true )
# compatibility with build scripts that rely on ios toolchains defining IOS instead of iOS
# CMake variables are case sensitive (unlike functions, macros and commands: https://cmake.org/cmake/help/latest/manual/cmake-language.7.html#variables
set( IOS   true )
set( UNIX  true )

if( NOT ${CMAKE_GENERATOR} MATCHES "Xcode" )
    message( FATAL_ERROR "iOS toolchain supports only XCode generator" )
endif()

# Compiler detection is skipped, so we must manually set these variables so code that depend on them can work
set( CMAKE_CXX_COMPILER_ID "AppleClang" CACHE STRING "C++ compiler id" )
set( CMAKE_C_COMPILER_ID "AppleClang"  CACHE STRING "C compiler id" )

set( TNUN_os_suffix iOS )

set( TNUN_cpu_archs default )

# Skip the platform compiler checks for cross compiling (or not)...
set( CMAKE_CXX_COMPILER_WORKS true CACHE STRING "Skip CMake compiler detection (requires a functioning code signing identity and provisioning profile)." )
set( CMAKE_C_COMPILER_WORKS   ${CMAKE_CXX_COMPILER_WORKS} )
if ( NOT CMAKE_CXX_COMPILER_WORKS )
    # Make sure all executables are bundles otherwise try compiles will fail.
    set( CMAKE_MACOSX_BUNDLE                         true                         )
    set( CMAKE_XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY    "iPhone Developer"           )
   #set( CMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED "NO"                         )
    set( MACOSX_BUNDLE_GUI_IDENTIFIER                "com.tnun.cmake-try-compile" )
endif()

# http://code.google.com/p/ios-cmake/source/browse/toolchain/iOS.cmake
# http://stackoverflow.com/questions/5010062/xcodebuild-simulator-or-device
set( CMAKE_XCODE_EFFECTIVE_PLATFORMS "-universal;-iphonesimulator;-iphoneos;" )
set( CMAKE_IOS_DEVELOPER_ROOT        "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer" )
set( CMAKE_XCODE_ATTRIBUTE_SDKROOT   iphoneos ) # "Latest iOS"

list( APPEND TNUN_compiler_optimize_for_size -mthumb ) #...mrmlj...this will cause (harmless) warnings on ARM64 builds...
set( XCODE_ATTRIBUTE_CFLAGS_armv7  "-mcpu=cortex-a8 -mtune=cortex-a9"  ) 
set( XCODE_ATTRIBUTE_CFLAGS_armv7s "                -mtune=cortex-a15" ) # http://www.anandtech.com/show/6292/iphone-5-a6-not-a15-custom-core


# Implementation note:
# Disable optimiser pass reports for iOS builds as they get run by the
# ios.universal_build.sh script and then Xcode interprets this optimiser output
# from the child-build process as errors.
#                                             (13.05.2016.) (Domagoj Saric)
string( REPLACE "-Rpass=loop-.*" "" TNUN_compiler_optimize_for_speed  "${TNUN_compiler_optimize_for_speed}" )

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG "${CMAKE_BINARY_DIR}/${CMAKE_CFG_INTDIR}" )
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}/${CMAKE_CFG_INTDIR}" )

################################################################################
# TNUN_ios_add_universal_build()
################################################################################
set( TNUN_toolchains_dir "${CMAKE_CURRENT_LIST_DIR}" )
function( TNUN_ios_add_universal_build target )
    # Generate a 'universal'/'fat' (i.e. simulator+device) build:
    add_custom_command(
        TARGET ${target}
        POST_BUILD
        COMMAND "${TNUN_toolchains_dir}/ios.universal_build.sh"
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        VERBATIM
    )
endfunction()


################################################################################
# TNUN_setup_target_for_arch()
################################################################################

function( TNUN_setup_target_for_arch target base_target_name arch )
  #...mrmlj...doesn't play well w/ th universal_build script...
  #set_property( TARGET ${target} PROPERTY XCODE_ATTRIBUTE_OBJROOT "${PROJECT_BINARY_DIR}"     )
  #set_property( TARGET ${target} PROPERTY XCODE_ATTRIBUTE_SYMROOT "${PROJECT_BINARY_DIR}/lib" )
  #set_property( TARGET ${target} PROPERTY ARCHIVE_OUTPUT_DIRECTORY_RELEASE "${PROJECT_BINARY_DIR}/lib" )
  #set_property( TARGET ${target} PROPERTY LIBRARY_OUTPUT_DIRECTORY_RELEASE "${PROJECT_BINARY_DIR}/lib" )
  set_property( TARGET ${target} PROPERTY OUTPUT_NAME                      "${base_target_name}_${TNUN_os_suffix}" )
endfunction()


# set_xcode_property( TARGET XCODE_PROPERTY XCODE_VALUE )
#  A convenience macro for setting xcode specific properties on targets
#  example: set_xcode_property (myioslib IPHONEOS_DEPLOYMENT_TARGET "3.1")
macro( set_xcode_property TARGET XCODE_PROPERTY XCODE_VALUE )
	set_property( TARGET ${TARGET} PROPERTY XCODE_ATTRIBUTE_${XCODE_PROPERTY} ${XCODE_VALUE} )
endmacro( set_xcode_property )


# find_host_package( PROGRAM ARGS )
#  A macro used to find executable programs on the host system, not within the
# iOS environment.
macro( find_host_package )
	set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER )
	set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY NEVER )
	set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE NEVER )
	set( iOS false )

	find_package(${ARGN})

	set( iOS true )
	set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM ONLY )
	set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY )
	set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY )
endmacro( find_host_package )
