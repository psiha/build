################################################################################
#
# PSI build options common to all GCC-compatible compilers.
#
# Copyright (c) Domagoj Saric. All rights reserved.
#
################################################################################

set( CMAKE_VISIBILITY_INLINES_HIDDEN true )

set( PSI_compiler_debug_symbols            -g                                                                                  )
set( PSI_compiler_debug_flags              -O0 -DDEBUG -D_DEBUG                                                                )
set( PSI_compiler_LTO                      -flto                                                                               )
set( PSI_compiler_disable_LTO              -fno-lto                                                                            )
set( PSI_linker_LTO                        -flto                                                                               )
set( PSI_compiler_fastmath                 -ffast-math -ffp-contract=fast                                                      )
set( PSI_compiler_precisemath              -fno-fast-math -ffp-contract=off                                                    )
set( PSI_compiler_rtti_on                  -frtti                                                                              )
set( PSI_compiler_rtti_off                 -fno-rtti                                                                           )
set( PSI_compiler_exceptions_on            -fexceptions                                                                        )
set( PSI_compiler_exceptions_off           -fno-exceptions                                                                     )
set( PSI_compiler_optimize_for_speed       -O3                                                                                 )
set( PSI_compiler_optimize_for_size        -Os                                                                                 )
set( PSI_compiler_thread_safe_init         -fthreadsafe-statics                                                                )
set( PSI_compiler_disable_thread_safe_init -fno-threadsafe-statics                                                             )
set( PSI_compiler_report_optimization      -ftree-vectorizer-verbose=6                                                         )
set( PSI_compiler_release_flags            -fomit-frame-pointer -ffunction-sections -fmerge-all-constants -fno-stack-protector )
set( PSI_default_warnings                  -Wall -Wextra -Wconversion -Wshadow -Wstrict-aliasing                               )
set( PSI_warnings_as_errors                -Werror                                                                             )
set( PSI_native_optimization               -march=native                                                                       )
set( PSI_compiler_coverage                 -fprofile-arcs -ftest-coverage                                                      )

set( PSI_common_compiler_options -fstrict-aliasing $<$<COMPILE_LANGUAGE:CXX>:-fstrict-enums> -fvisibility=hidden $<$<COMPILE_LANGUAGE:CXX>:-fvisibility-inlines-hidden> )

if ( NOT WIN32 )
    # -fPIC is not supported on Windows
    list( APPEND PSI_common_compiler_options -fPIC )
endif()

# "Unknown language" error with CMake 3.5.2 if COMPILE_LANGUAGE:C is used.
# + 'COMPILE_LANGUAGE' isn't supported by VS generators:
# https://cmake.org/cmake/help/latest/manual/cmake-generator-expressions.7.html#logical-expressions

list( APPEND PSI_common_compiler_options $<$<COMPILE_LANGUAGE:CXX>:-std=gnu++2b> )
list( APPEND PSI_common_compiler_options $<$<NOT:$<COMPILE_LANGUAGE:CXX>>:-std=gnu2x> )

# https://cmake.org/cmake/help/v3.3/policy/CMP0063.html
cmake_policy( SET CMP0063 NEW )
