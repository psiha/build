################################################################################
#
# T:N.U.N. Visual Studio/MSVC CMake tool chain file.
#
# Copyright (c) 2016 - 2019. Domagoj Saric.
#
################################################################################

# www.drdobbs.com/cpp/the-most-underused-compiler-switches-in/240166599

# Implementation note: Use the dash (instead of slash) syntax as the compiler
# supports this and it plays better in certain CMake related special/edge-cases
# (e.g. generator expressions).
#                                             (01.06.2016.) (Domagoj Saric)
set( TNUN_compiler_debug_symbols                  -Zi                                         )
set( TNUN_compiler_debug_flags                    -DDEBUG -Od -MDd                            )
set( TNUN_compiler_release_flags                  -Ox -Oy -GF -Gw -Gm- -GS- -Gy -MD           )
set( TNUN_linker_debug_symbols                    -DEBUG                                      )
set( TNUN_compiler_LTO                            -GL                                         )
set( TNUN_compiler_disable_LTO                    -GL-                                        )
set( TNUN_linker_LTO                              -LTCG                                       )
set( TNUN_compiler_fastmath                       -fp:except- -fp:fast -Qfast_transcendentals )
set( TNUN_compiler_precisemath                    -fp:precise                                 )
set( TNUN_compiler_rtti_on                        -GR                                         )
set( TNUN_compiler_rtti_off                       -GR-                                        )
set( TNUN_compiler_exceptions_on                  -EHsc                                       )
set( TNUN_compiler_exceptions_off                 -EHs-c- -D_HAS_EXCEPTIONS=0 -wd4577         )
set( TNUN_compiler_report_optimization            -Qpar-report:1 -Qvec-report:2               ) # https://msdn.microsoft.com/en-us/library/jj658585.aspx Vectorizer and Parallelizer Messages
set( TNUN_compiler_optimize_for_speed             -Ox -Ot -Ob3 -Qpar                          )
set( TNUN_compiler_optimize_for_size              -Ox -Os -Ob2                                )
set( TNUN_compiler_thread_safe_init               -Zc:threadSafeInit                          )
set( TNUN_compiler_disable_thread_safe_init       -Zc:threadSafeInit-                         )
set( TNUN_compiler_runtime_sanity_checks          -GS -sdl -guard:cf                          ) #...mrmlj...-fp:strict would disable fast-math so for now it is moved to the dbg_only version
set( TNUN_compiler_dbg_only_runtime_sanity_checks -RTC1 -fp:strict                            )
set( TNUN_warnings_as_errors                      -WX                                         )
set( TNUN_default_warnings                        -W4                                         )
set( TNUN_compiler_runtime_integer_checks         -RTCc -D_ALLOW_RTCc_IN_STL                  ) # A separate option as it can break valid code or code that relies on behaviour that these checks catch https://www.reddit.com/r/cpp/comments/46mhne/rtcc_rejects_conformant_code_with_visual_c_2015


# w4373: '...': virtual function overrides '...', previous versions of the compiler did not override when parameters only differed by const/volatile qualifiers
# w4324: 'structure was padded due to alignment specifier'
# w5104: 'found 'L#x' in macro replacement list, did you mean 'L""#x'?' @ windows.h + experimental PP
# w5105: 'macro expansion producing 'defined' has undefined behavior' @ windows.h + experimental PP
add_compile_options( /permissive- -Oi -wd4324 -wd4373 -wd5104 -wd5105 )


if ( CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" ) # real MSVC, not clang-cl
    add_compile_options( /std:c++latest /MP )
    if ( CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "19.26" )
        add_compile_options( /Zc:preprocessor )
    else()
        add_compile_options( /experimental:preprocessor )
    endif()

    if ( CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "19.28" )
        # Use Address Sanitizer instead of RTC (RTC is not compatible with ASan - compilation passes, but RTC throws a lot of false positives)
        list( REMOVE_ITEM TNUN_compiler_dbg_only_runtime_sanity_checks -RTC1 )
        unset( TNUN_compiler_runtime_integer_checks )  # RTCc not compatible with ASan, and we don't want to enable RTC in STL

        list( APPEND TNUN_compiler_runtime_sanity_checks -fsanitize=address )
        # Implementation note:
        # CMake 3.20 and earlier will fail to recognize the -fsanitize=address
        # flag and enable it in Visual Studio project. This needs to be done manually.
        # Ninja and Makefile projects are not affected.
        # The tracking issue is: https://gitlab.kitware.com/cmake/cmake/-/issues/21081
        #                                         (06.07.2021. Nenad Miksa)
        #
    endif()
else()
    set( CLANG_CL true )
    
    # https://github.com/llvm/llvm-project/issues/53259
    add_compile_definitions( __GNUC__ )
    
    # if using Visual Studio, then we need to add /MP. Ninja + clang-cl does not recognize this flag
    if ( ${CMAKE_GENERATOR} MATCHES "Visual Studio" )
        add_compile_options( /MP )
        # clang-cl does not recognize /std:c++latest flag
        add_compile_options( /clang:-std=gnu++20 )
    else()
        add_compile_options( $<$<COMPILE_LANGUAGE:CXX>:/clang:-std=gnu++20> )
        add_compile_options( $<$<NOT:$<COMPILE_LANGUAGE:CXX>>:/clang:-std=gnu11> )
    endif()

    set( THIN_LTO_SUPPORTED        ON                                                   )
    set( TNUN_compiler_LTO         -flto=thin -fwhole-program-vtables                   )
    set( TNUN_compiler_disable_LTO -fno-lto   -fno-whole-program-vtables                )
    set( TNUN_linker_LTO           "/lldltocache:${CMAKE_CURRENT_BINARY_DIR}/lto.cache" )

    if ( DEFINED ENV{CMAKE_BUILD_PARALLEL_LEVEL} )
        set( LTO_JOBS $ENV{CMAKE_BUILD_PARALLEL_LEVEL} )
    else()
        set( LTO_JOBS $ENV{NUMBER_OF_PROCESSORS} )
    endif()

    set( TNUN_linker_LTO_jobs ${LTO_JOBS} CACHE STRING "Number of LTO parallel jobs" )

    if ( DEFINED ENV{CMAKE_BUILD_PARALLEL_LEVEL} )
        list( APPEND TNUN_linker_LTO "/threads:${TNUN_linker_LTO_jobs}" )
    endif()

    # remove unsupported compile flags
    list( REMOVE_ITEM TNUN_compiler_release_flags -Gm- )
    # clang sanitizers do not support MDd and MTd runtimes
    # also, on WOA64, MDd runtime does not exist (even with true msvc compiler)
    string( REPLACE "-MDd" "-MD" TNUN_compiler_debug_flags "${TNUN_compiler_debug_flags}" )
    list( REMOVE_ITEM TNUN_compiler_fastmath -Qfast_transcendentals )

    add_compile_options( -Wno-error=unused-command-line-argument -Wno-macro-redefined )

    # without those __cpp_rtti macro has incorrect definitions
    list( APPEND TNUN_compiler_rtti_on  /clang:-frtti    -D_HAS_STATIC_RTTI=1 )
    list( APPEND TNUN_compiler_rtti_off /clang:-fno-rtti -D_HAS_STATIC_RTTI=0 )

    # argument unused during compilation - use default clang optimization flags, not the MSVC-emulated ones
    list( REMOVE_ITEM TNUN_compiler_optimize_for_speed -Ob3 -Qpar )
    list( APPEND TNUN_compiler_optimize_for_speed /clang:-O3 /clang:-fvectorize /clang:-fslp-vectorize )

    list( APPEND TNUN_compiler_report_optimization /clang:-Rpass=loop-.* )
    set( TNUN_compiler_time_trace /clang:-ftime-trace )

    # clang sanitizers work only on Intel at the moment
    if ( CMAKE_SYSTEM_PROCESSOR STREQUAL "AMD64" )
        set( TNUN_compiler_runtime_sanity_checks -fsanitize=undefined -fsanitize=address -fsanitize=integer )

        set( TNUN_linker_runtime_sanity_checks clang_rt.asan_dynamic-x86_64.lib clang_rt.asan_dynamic_runtime_thunk-x86_64.lib )

        add_compile_options( /clang:-msse3 /clang:-msse4 )
    endif()

    # Assumes Clang 11.0.0 or newer
    add_compile_options( /clang:-fenable-matrix )
endif()

add_definitions(
  -D_CRT_SECURE_NO_WARNINGS
  -D_SCL_SECURE_NO_WARNINGS
  -D_SBCS
  -D_WIN32_WINNT=0x0A00 # Win10
)

set( TNUN_ABIs
  Win32
  x64
  Aarch64
)

if( NOT DEFINED TNUN_ABI AND ${CMAKE_GENERATOR} MATCHES "Visual Studio" )
  if ( CMAKE_VS_PLATFORM_NAME MATCHES 64 )
    if ( CMAKE_SYSTEM_PROCESSOR STREQUAL "aarch64" )
        set( TNUN_ABI aarch64 )
    else()
        set( TNUN_ABI x64 )
    endif()
  else()
    set( TNUN_ABI Win32 )
  endif()
else()
  if ( ${CMAKE_SIZEOF_VOID_P} EQUAL 8 )
    if ( CMAKE_SYSTEM_PROCESSOR STREQUAL "aarch64" )
        set( TNUN_ABI aarch64 )
    else()
        set( TNUN_ABI x64 )
    endif()
  else()
    set( TNUN_ABI Win32 )
  endif()
endif()

set( TNUN_arch_include_dir "${CMAKE_CURRENT_LIST_DIR}/windows" )
include( "${TNUN_arch_include_dir}/${TNUN_ABI}.abi.cmake" )

################################################################################
# TNUN_setup_target_for_arch()
################################################################################

function( TNUN_setup_target_for_arch target base_target_name arch )
  include( "${TNUN_arch_include_dir}/${arch}.arch.cmake" )

  if ( NOT TNUN_binary_dir )
    set( TNUN_binary_dir "${PROJECT_BINARY_DIR}" )
  endif()

  set( LIBRARY_OUTPUT_PATH "${TNUN_binary_dir}/lib/${TNUN_ABI}" )
  set_property( TARGET ${target} PROPERTY ARCHIVE_OUTPUT_DIRECTORY         "${LIBRARY_OUTPUT_PATH}" )
  set_property( TARGET ${target} PROPERTY LIBRARY_OUTPUT_DIRECTORY         "${LIBRARY_OUTPUT_PATH}" )
  set_property( TARGET ${target} PROPERTY ARCHIVE_OUTPUT_DIRECTORY_RELEASE "${LIBRARY_OUTPUT_PATH}" )
  set_property( TARGET ${target} PROPERTY LIBRARY_OUTPUT_DIRECTORY_RELEASE "${LIBRARY_OUTPUT_PATH}" )
  set_property( TARGET ${target} PROPERTY OUTPUT_NAME                      "${base_target_name}_${TNUN_arch_suffix}_${TNUN_os_suffix}" )

  target_compile_options( ${target} PRIVATE ${TNUN_arch_compiler_options} )
endfunction()
