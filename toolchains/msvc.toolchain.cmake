################################################################################
#
# PSI Visual Studio/MSVC CMake tool chain file.
#
# Copyright (c) Domagoj Saric.
#
################################################################################

# www.drdobbs.com/cpp/the-most-underused-compiler-switches-in/240166599

# Implementation note: Use the dash (instead of slash) syntax as the compiler
# supports this and it plays better in certain CMake related special/edge-cases
# (e.g. generator expressions).
#                                             (01.06.2016.) (Domagoj Saric)
set( PSI_compiler_debug_symbols                  -Zi                                         )
set( PSI_compiler_debug_flags                    -DDEBUG -Od -MDd                            )
set( PSI_compiler_release_flags                  -Ox -Oy -GF -Gw -Gm- -GS- -Gy -MD           )
set( PSI_linker_debug_symbols                    -DEBUG                                      )
set( PSI_compiler_LTO                            -GL                                         )
set( PSI_compiler_disable_LTO                    -GL-                                        )
set( PSI_linker_LTO                              -LTCG                                       )
set( PSI_compiler_fastmath                       -fp:except- -fp:fast -Qfast_transcendentals )
set( PSI_compiler_precisemath                    -fp:precise                                 )
set( PSI_compiler_rtti_on                        -GR                                         )
set( PSI_compiler_rtti_off                       -GR-                                        )
set( PSI_compiler_exceptions_on                  -EHsc                                       )
set( PSI_compiler_exceptions_off                 -EHs-c- -D_HAS_EXCEPTIONS=0 -wd4577         )
set( PSI_compiler_report_optimization            -Qpar-report:1 -Qvec-report:2               ) # https://msdn.microsoft.com/en-us/library/jj658585.aspx Vectorizer and Parallelizer Messages
set( PSI_compiler_optimize_for_speed             -Ox -Ot -Ob3 -Qpar                          )
set( PSI_compiler_optimize_for_size              -Ox -Os -Ob2                                )
set( PSI_compiler_thread_safe_init               -Zc:threadSafeInit                          )
set( PSI_compiler_disable_thread_safe_init       -Zc:threadSafeInit-                         )
set( PSI_compiler_runtime_sanity_checks          -GS -sdl -guard:cf                          ) #...mrmlj...-fp:strict would disable fast-math so for now it is moved to the dbg_only version
set( PSI_compiler_dbg_only_runtime_sanity_checks -RTC1 -fp:strict                            )
set( PSI_warnings_as_errors                      -WX                                         )
set( PSI_default_warnings                        -W4                                         )
set( PSI_compiler_runtime_integer_checks         -RTCc -D_ALLOW_RTCc_IN_STL                  ) # A separate option as it can break valid code or code that relies on behaviour that these checks catch https://www.reddit.com/r/cpp/comments/46mhne/rtcc_rejects_conformant_code_with_visual_c_2015

set( PSI_common_compiler_options /permissive- /Zc:__cplusplus -Oi
    -wd4324 # 'structure was padded due to alignment specifier'
    -wd4373 # '...': virtual function overrides '...', previous versions of the compiler did not override when parameters only differed by const/volatile qualifiers
    -wd5104 # 'found 'L#x' in macro replacement list, did you mean 'L""#x'?' @ windows.h + experimental PP
    -wd5105 # 'macro expansion producing 'defined' has undefined behavior' @ windows.h + experimental PP
)
set( PSI_common_compile_definitions )

if ( CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" ) # real MSVC, not clang-cl
    list( APPEND PSI_common_compiler_options /MP )
    list( APPEND PSI_common_compiler_options /Zc:preprocessor )

    # Use Address Sanitizer instead of RTC (RTC is not compatible with ASan - compilation passes, but RTC throws a lot of false positives)
    list( REMOVE_ITEM PSI_compiler_dbg_only_runtime_sanity_checks -RTC1 )
    unset( PSI_compiler_runtime_integer_checks )  # RTCc not compatible with ASan, and we don't want to enable RTC in STL

    list( APPEND PSI_compiler_runtime_sanity_checks -fsanitize=address )
    list( APPEND PSI_compiler_debug_flags -D_DEBUG )
else()
    set( CLANG_CL true )

    # https://github.com/llvm/llvm-project/issues/53259
    list( APPEND PSI_common_compile_definitions __GNUC__ )
    
    # https://clang.llvm.org/docs/UsersManual.html#strict-aliasing
    list( APPEND PSI_common_compiler_options -fstrict-aliasing )

    # if using Visual Studio, then we need to add /MP. Ninja + clang-cl does not recognize this flag
    if ( ${CMAKE_GENERATOR} MATCHES "Visual Studio" )
        list( APPEND PSI_common_compiler_options /MP )
    endif()
    # clang-cl does not recognize /std:c++latest flag
    list( APPEND PSI_common_compiler_options $<$<COMPILE_LANGUAGE:CXX>:/clang:-std=c++2c> )
    list( APPEND PSI_common_compiler_options $<$<NOT:$<COMPILE_LANGUAGE:CXX>>:/clang:-std=gnu2x> )
    # https://developercommunity.visualstudio.com/t/ClangCL-Broken-C23-STL-support/10801253
    list( APPEND PSI_common_compiler_options $<$<COMPILE_LANGUAGE:CXX>:-D_HAS_CXX23=1> )

    set( THIN_LTO_SUPPORTED        ON                                                  )
    set( PSI_compiler_LTO         -flto=thin -fwhole-program-vtables                   )
    set( PSI_compiler_disable_LTO -fno-lto   -fno-whole-program-vtables                )
    set( PSI_linker_LTO           "/lldltocache:${CMAKE_CURRENT_BINARY_DIR}/lto.cache" )

    if ( DEFINED ENV{CMAKE_BUILD_PARALLEL_LEVEL} )
        set( LTO_JOBS $ENV{CMAKE_BUILD_PARALLEL_LEVEL} )
    else()
        set( LTO_JOBS $ENV{NUMBER_OF_PROCESSORS} )
    endif()

    set( PSI_linker_LTO_jobs ${LTO_JOBS} CACHE STRING "Number of LTO parallel jobs" )

    if ( DEFINED ENV{CMAKE_BUILD_PARALLEL_LEVEL} )
        list( APPEND PSI_linker_LTO "/threads:${PSI_linker_LTO_jobs}" )
    endif()

    # remove unsupported compile flags
    list( REMOVE_ITEM PSI_compiler_release_flags -Gm- )
    list( REMOVE_ITEM PSI_compiler_fastmath -Qfast_transcendentals )
    # clang sanitizers do not support MDd and MTd runtimes
    # also, on WOA64, MDd runtime does not exist (even with true msvc compiler)
    string( REPLACE "-MDd" "-MD" PSI_compiler_debug_flags "${PSI_compiler_debug_flags}" )
    # replace by at least the basic iterator debug level
    list( APPEND PSI_compiler_debug_flags -D_ITERATOR_DEBUG_LEVEL=1 )

    list( APPEND PSI_default_warnings -Wno-error=unused-command-line-argument -Wno-macro-redefined )

    # without those __cpp_rtti macro has incorrect definitions
    list( APPEND PSI_compiler_rtti_on  /clang:-frtti    -D_HAS_STATIC_RTTI=1 )
    list( APPEND PSI_compiler_rtti_off /clang:-fno-rtti -D_HAS_STATIC_RTTI=0 )

    # argument unused during compilation - use default clang optimization flags, not the MSVC-emulated ones
    list( REMOVE_ITEM PSI_compiler_optimize_for_speed -Ob3 -Qpar )
    list( APPEND PSI_compiler_optimize_for_speed /clang:-O3 /clang:-fvectorize /clang:-fslp-vectorize )

    list( APPEND PSI_compiler_report_optimization /clang:-Rpass=loop-.* )
    set( PSI_compiler_time_trace /clang:-ftime-trace )

    # clang sanitizers work only on Intel at the moment
    if ( CMAKE_SYSTEM_PROCESSOR STREQUAL "AMD64" )
        set( PSI_compiler_runtime_sanity_checks -fsanitize=undefined -fsanitize=address -fsanitize=integer )

        set( PSI_linker_runtime_sanity_checks clang_rt.asan_dynamic-x86_64.lib clang_rt.asan_dynamic_runtime_thunk-x86_64.lib )

        list( APPEND PSI_common_compiler_options /clang:-mavx /clang:-mfma )
    endif()

    list( APPEND PSI_common_compiler_options /clang:-fenable-matrix )
endif()

list( APPEND PSI_common_compile_definitions
  _CRT_SECURE_NO_WARNINGS
  _SCL_SECURE_NO_WARNINGS
  _SBCS
  _WIN32_WINNT=0x0A00 # Win10
)

set( PSI_ABIs
  Win32
  x64
  Aarch64
)

if( NOT DEFINED PSI_ABI AND ${CMAKE_GENERATOR} MATCHES "Visual Studio" )
  if ( CMAKE_VS_PLATFORM_NAME MATCHES 64 )
    if ( CMAKE_SYSTEM_PROCESSOR STREQUAL "aarch64" )
        set( PSI_ABI aarch64 )
    else()
        set( PSI_ABI x64 )
    endif()
  else()
    set( PSI_ABI Win32 )
  endif()
else()
  if ( ${CMAKE_SIZEOF_VOID_P} EQUAL 8 )
    if ( CMAKE_SYSTEM_PROCESSOR STREQUAL "aarch64" )
        set( PSI_ABI aarch64 )
    else()
        set( PSI_ABI x64 )
    endif()
  else()
    set( PSI_ABI Win32 )
  endif()
endif()

set( PSI_arch_include_dir "${CMAKE_CURRENT_LIST_DIR}/windows" )
include( "${PSI_arch_include_dir}/${PSI_ABI}.abi.cmake" )

################################################################################
# PSI_setup_target_for_arch()
################################################################################

function( PSI_setup_target_for_arch target base_target_name arch )
  include( "${PSI_arch_include_dir}/${arch}.arch.cmake" )

  if ( NOT PSI_binary_dir )
    set( PSI_binary_dir "${PROJECT_BINARY_DIR}" )
  endif()

  set( LIBRARY_OUTPUT_PATH "${PSI_binary_dir}/lib/${PSI_ABI}" )
  set_property( TARGET ${target} PROPERTY ARCHIVE_OUTPUT_DIRECTORY         "${LIBRARY_OUTPUT_PATH}" )
  set_property( TARGET ${target} PROPERTY LIBRARY_OUTPUT_DIRECTORY         "${LIBRARY_OUTPUT_PATH}" )
  set_property( TARGET ${target} PROPERTY ARCHIVE_OUTPUT_DIRECTORY_RELEASE "${LIBRARY_OUTPUT_PATH}" )
  set_property( TARGET ${target} PROPERTY LIBRARY_OUTPUT_DIRECTORY_RELEASE "${LIBRARY_OUTPUT_PATH}" )
  set_property( TARGET ${target} PROPERTY OUTPUT_NAME                      "${base_target_name}_${PSI_arch_suffix}_${PSI_os_suffix}" )

  target_compile_options( ${target} PRIVATE ${PSI_arch_compiler_options} )
endfunction()
