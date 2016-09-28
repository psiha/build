################################################################################
#
# T:N.U.N. Clang toolchain file.
#
# Copyright (c) 2016. Domagoj Saric. All rights reserved.
#
################################################################################
# http://stackoverflow.com/questions/15548023/clang-optimization-levels
################################################################################

include( "${CMAKE_CURRENT_LIST_DIR}/gcc_compatibles.cmake" )

list( APPEND TNUN_compiler_optimize_for_speed -fvectorize -fslp-vectorize -fslp-vectorize-aggressive )
list( APPEND TNUN_compiler_report_optimization -Rpass=loop-.* )
list( APPEND TNUN_compiler_LTO -fwhole-program-vtables )

# http://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html
# http://clang.llvm.org/docs/AddressSanitizer.html
# http://clang.llvm.org/docs/UsersManual.html#controlling-code-generation
set( TNUN_linker_runtime_sanity_checks -fsanitize=undefined -fsanitize=address ) # AppleClang lag: -fsanitize=thread -fsanitize=memory -fsanitize=dataflow -fsanitize=cfi -fsanitize=safe-stack
set( TNUN_compiler_runtime_sanity_checks ${TNUN_linker_runtime_sanity_checks} -fno-omit-frame-pointer )
set( TNUN_linker_runtime_integer_checks -fsanitize=integer )
set( TNUN_compiler_runtime_integer_checks ${TNUN_compiler_runtime_integer_checks} )

# Leak sanitizer is available only on Clang on Linux x64.
# http://clang.llvm.org/docs/LeakSanitizer.html
#if( ${CMAKE_SYSTEM_NAME} MATCHES "Linux" AND TNUN_ABI STREQUAL "x64" )
#    list( APPEND TNUN_compiler_runtime_sanity_checks -fsanitize=leak )
#    list( APPEND TNUN_linker_runtime_sanity_checks -fsanitize=leak)
#endif()

# Implementation note:
# When Clang is used behind ccache, it throws a lot of "unused-argument"
# warnings. I'm not sure why that happens (it also happens with Clang for
# Android, both from ndk-build and CMake Android build).
# This causes lots of noisy compiler output which make it very difficult to see
# actual warnings/errors reported by compiler.
#                                             (11.08.2016. Nenad Miksa)
if( "${CMAKE_CXX_COMPILER}" MATCHES ".*ccache" )
    add_compile_options( -Qunused-arguments )
endif()

add_compile_options( -Wheader-guard -fdiagnostics-color )

set( USING_CLANG true )
