################################################################################
#
# T:N.U.N. Visual Studio/MSVC CMake tool chain file.
#
# Copyright (c) 2016 - 2017. Domagoj Saric.
#
################################################################################

# www.drdobbs.com/cpp/the-most-underused-compiler-switches-in/240166599

# Implementation note: Use the dash (instead of slash) syntax as the compiler
# supports this and it plays better in certain CMake related special/edge-cases
# (e.g. generator expressions).
#                                             (01.06.2016.) (Domagoj Saric)
set( TNUN_compiler_debug_symbols                  -Zi                                         )
set( TNUN_compiler_debug_flags                    -DDEBUG -Od -MDd                            )
set( TNUN_compiler_release_flags                  -Ox -Ob2 -Oy -GF -Gw -Gm- -GS- -Gy -MD      )
set( TNUN_linker_debug_symbols                    -DEBUG                                      )
set( TNUN_compiler_LTO                            -GL                                         )
set( TNUN_linker_LTO                              -LTCG                                       )
set( TNUN_compiler_fastmath                       -fp:except- -fp:fast -Qfast_transcendentals )
set( TNUN_compiler_rtti_on                        -GR                                         )
set( TNUN_compiler_rtti_off                       -GR-                                        )
set( TNUN_compiler_exceptions_on                  -EHsc                                       )
set( TNUN_compiler_exceptions_off                 -D_HAS_EXCEPTIONS=0 -wd4577                 )
set( TNUN_compiler_report_optimization            -Qpar-report:1 -Qvec-report:2               ) # https://msdn.microsoft.com/en-us/library/jj658585.aspx Vectorizer and Parallelizer Messages
set( TNUN_compiler_optimize_for_speed             -Ox -Ot -Qpar                               )
set( TNUN_compiler_optimize_for_size              -Ox -Os                                     )
set( TNUN_compiler_runtime_sanity_checks          -GS -sdl -guard:cf                          ) #...mrmlj...-fp:strict would disable fast-math so for now it is moved to the dbg_only version
set( TNUN_compiler_dbg_only_runtime_sanity_checks -RTC1 -fp:strict                            )
set( TNUN_warnings_as_errors                      -WX                                         )
set( TNUN_default_warnings                        -W4                                         )
set( TNUN_compiler_runtime_integer_checks         -RTCc -D_ALLOW_RTCc_IN_STL                  ) # A separate option as it can break valid code or code that relies on behaviour that these checks catch https://www.reddit.com/r/cpp/comments/46mhne/rtcc_rejects_conformant_code_with_visual_c_2015


# w4373: '...': virtual function overrides '...', previous versions of the compiler did not override when parameters only differed by const/volatile qualifiers
# w4324: 'structure was padded due to alignment specifier'
add_compile_options( /std:c++latest -MP -Oi -Zc:threadSafeInit- -wd4324 -wd4373 )
add_definitions(
  -D_CRT_SECURE_NO_WARNINGS
  -D_SCL_SECURE_NO_WARNINGS
  -D_SBCS
  -D_WIN32_WINNT=0x0601 # Win7
)

set( TNUN_ABIs
  Win32
  x64
)

if( NOT DEFINED TNUN_ABI )
  if ( CMAKE_VS_PLATFORM_NAME MATCHES 64 )
    set( TNUN_ABI x64 )
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
