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

# http://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html
# http://clang.llvm.org/docs/UsersManual.html#controlling-code-generation
set( TNUN_compiler_runtime_sanity_checks -fsanitize=undefined -fsanitize=integer )

add_compile_options( -Wheader-guard )
