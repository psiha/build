################################################################################
#
# PSI Clang toolchain file.
#
# Copyright (c) Domagoj Saric. All rights reserved.
#
################################################################################
# http://stackoverflow.com/questions/15548023/clang-optimization-levels
################################################################################

include( "${CMAKE_CURRENT_LIST_DIR}/gcc_compatibles.cmake" )

list( APPEND PSI_compiler_optimize_for_speed -fvectorize -fslp-vectorize )
list( APPEND PSI_compiler_report_optimization -Rpass=loop-.* )

list( APPEND PSI_default_warnings -Wdocumentation )

set( THIN_LTO_SUPPORTED ON )

if ( THIN_LTO_SUPPORTED )
    set( PSI_compiler_LTO -flto=thin )
    set( PSI_linker_LTO   -flto=thin )

    if ( NOT EMSCRIPTEN )
        # https://github.com/emscripten-core/emscripten/issues/15427
        list( APPEND PSI_compiler_LTO -fwhole-program-vtables )
    endif()

    # LTO cache folder - enables incremental LTO
    set( LTO_CACHE_DIR "${CMAKE_CURRENT_BINARY_DIR}/lto.cache" )

    # LTO cache pruning policy - an incremental LTO cache with no pruning
    # policy grows without bound across build directories, so bound it by
    # default (projects needing different limits override the cache vars).
    set( PSI_LTO_CACHE_SIZE        "8g"  CACHE STRING "Maximum on-disk size of the incremental LTO cache (lld/gold size syntax, e.g. 8g, 512m; ignored on Apple ld64, which has no absolute cache size limit)" )
    set( PSI_LTO_CACHE_PRUNE_AFTER "72h" CACHE STRING "Evict incremental LTO cache entries unused for longer than this (Xs/Xm/Xh, e.g. 72h)" )

    if ( APPLE )
        list( APPEND PSI_linker_LTO "-Wl,-cache_path_lto,${LTO_CACHE_DIR}" )
        # ld64 has no absolute cache size limit, only -max_relative_cache_size_lto
        # (a percentage of free disk space), so PSI_LTO_CACHE_SIZE is not wired
        # here; only the time-based eviction policy is, converted to seconds.
        if ( PSI_LTO_CACHE_PRUNE_AFTER MATCHES "^([0-9]+)([smh])$" )
            set( _psi_lto_prune_amount "${CMAKE_MATCH_1}" )
            set( _psi_lto_prune_unit   "${CMAKE_MATCH_2}" )
            if ( _psi_lto_prune_unit STREQUAL "h" )
                math( EXPR _psi_lto_prune_after_seconds "${_psi_lto_prune_amount} * 3600" )
            elseif ( _psi_lto_prune_unit STREQUAL "m" )
                math( EXPR _psi_lto_prune_after_seconds "${_psi_lto_prune_amount} * 60" )
            else()
                set( _psi_lto_prune_after_seconds "${_psi_lto_prune_amount}" )
            endif()
            list( APPEND PSI_linker_LTO "-Wl,-prune_after_lto,${_psi_lto_prune_after_seconds}" )
        else()
            message( WARNING "PSI_LTO_CACHE_PRUNE_AFTER '${PSI_LTO_CACHE_PRUNE_AFTER}' is not of the form <N>[smh] - ld64 LTO cache pruning left at its default" )
        endif()
    else()
        list( APPEND PSI_linker_LTO "-Wl,--thinlto-cache-dir=${CMAKE_CURRENT_BINARY_DIR}/lto.cache" )
        list( APPEND PSI_linker_LTO "-Wl,--thinlto-cache-policy=cache_size_bytes=${PSI_LTO_CACHE_SIZE}:prune_after=${PSI_LTO_CACHE_PRUNE_AFTER}" )
        list( APPEND PSI_linker_LTO_gold "-Wl,-plugin-opt,cache-dir=${CMAKE_CURRENT_BINARY_DIR}/lto.cache" )
        list( APPEND PSI_linker_LTO_gold "-Wl,-plugin-opt,cache-policy=cache_size_bytes=${PSI_LTO_CACHE_SIZE}:prune_after=${PSI_LTO_CACHE_PRUNE_AFTER}" )
    endif()


    # LTO parallelism - will use all cores if CMAKE_PARALLEL_LEVEL is not defined

    if ( DEFINED ENV{CMAKE_BUILD_PARALLEL_LEVEL} )
        set( LTO_JOBS $ENV{CMAKE_BUILD_PARALLEL_LEVEL} )
    else()
        # https://clang.llvm.org/docs/ThinLTO.html#controlling-backend-parallelism
        set( LTO_JOBS all )
        # Apple linker does not understand "all", so detect number of cores
        if( CMAKE_HOST_APPLE )
            find_program( cmd_sysctl "sysctl" )
            if( cmd_sysctl )
                execute_process( COMMAND ${cmd_sysctl} "hw.ncpu" OUTPUT_VARIABLE info )
                string( REGEX REPLACE "^.*hw.ncpu: ([0-9]+).*$" "\\1" LTO_JOBS "${info}" )
            else()
                set( LTO_JOBS 0 )
            endif()
        endif()
    endif()

    set( PSI_linker_LTO_jobs ${LTO_JOBS} CACHE STRING "Number of LTO parallel jobs" )

    if ( APPLE AND PSI_USE_LINKER STREQUAL "default" )
        list( APPEND PSI_linker_LTO -Wl,-mllvm,-threads=${PSI_linker_LTO_jobs} )
    else()
        list( APPEND PSI_linker_LTO -Wl,--thinlto-jobs=${PSI_linker_LTO_jobs} )
        list( APPEND PSI_linker_LTO_gold -Wl,-plugin-opt,jobs=${PSI_linker_LTO_jobs} )
    endif()
endif()

list( APPEND PSI_compiler_disable_LTO -fno-whole-program-vtables )

set( PSI_address_sanitizer             -fsanitize=address   )
set( PSI_undefined_behaviour_sanitizer -fsanitize=undefined )
set( PSI_integer_sanitizer             -fsanitize=integer   )
set( PSI_thread_sanitizer              -fsanitize=thread    )
set( PSI_memory_sanitizer              -fsanitize=memory    )
set( PSI_cfi_sanitizer                 -fsanitize=cfi       )

set( PSI_compiler_runtime_sanity_checks ${PSI_address_sanitizer} ${PSI_undefined_behaviour_sanitizer} ${PSI_integer_sanitizer} )
set( PSI_linker_runtime_sanity_checks ${PSI_compiler_runtime_sanity_checks} )

# safe-stack sanitizer causes multiple symbols linker error when combined with address sanitizer
#if( NOT ${CMAKE_CXX_COMPILER_ID} STREQUAL "AppleClang" )
    # list( APPEND PSI_linker_runtime_sanity_checks -fsanitize=safe-stack )
#endif()

set( PSI_code_coverage_compiler_flags -fprofile-instr-generate -fcoverage-mapping )
set( PSI_code_coverage_linker_flags   -fprofile-instr-generate )

set( PSI_compiler_runtime_integer_checks ${PSI_integer_sanitizer} )
set( PSI_linker_runtime_integer_checks   ${PSI_compiler_runtime_integer_checks} )

# Implementation note:
# When Clang is used behind ccache, it throws a lot of "unused-argument"
# warnings. I'm not sure why that happens (it also happens with Clang for
# Android, both from ndk-build and CMake Android build).
# This causes lots of noisy compiler output which make it very difficult to see
# actual warnings/errors reported by compiler.
#                                             (11.08.2016. Nenad Miksa)
if( "${CMAKE_CXX_COMPILER}" MATCHES ".*ccache" )
    list( APPEND PSI_common_compiler_options -Qunused-arguments )
endif()

list( APPEND PSI_default_warnings -Wheader-guard -fdiagnostics-color )

set( PSI_compiler_time_trace "-ftime-trace" )

list( APPEND PSI_common_compiler_options -fenable-matrix ) # this option is supposedly orphaned (according to an Apple Clang developer)

set( CLANG true )
