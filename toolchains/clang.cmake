################################################################################
#
# T:N.U.N. Clang toolchain file.
#
# Copyright (c) 2016. Domagoj Saric. All rights reserved.
#
################################################################################

include( "${CMAKE_CURRENT_LIST_DIR}/gcc_compatibles.cmake" )

list( APPEND TNUN_compiler_optimize_for_speed -fvectorize -fslp-vectorize -fslp-vectorize-aggressive )
# Implementation note:
# Disable optimiser pass reports for iOS builds as they get run by the
# ios.universal_build.sh script and then Xcode interprets this optimiser output
# from the child-build process as errors.
# ...mrmlj...iOS/Xcode specific knowledge...cleanup...
#                                             (13.05.2016.) (Domagoj Saric)
if ( NOT iOS )
    list( APPEND TNUN_compiler_optimize_for_speed -Rpass=loop-.* ) #-Rpass-missed=loop-vectorize -Rpass-analysis=loop-vectorize -mllvm -bb-vectorize-aligned-only
endif()

add_compile_options( -fconstant-cfstrings -fobjc-call-cxx-cdtors -Wheader-guard )
