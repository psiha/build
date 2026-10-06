################################################################################
#
# PSI link-time-optimization knobs.
#
# Copyright (c) Domagoj Saric.
#
################################################################################
#
# Options that shape the code the LTO *backend* produces: they have to reach the
# linker (which owns the whole-program pipeline), not just the per-TU compile
# steps. This module is the single description of them, usable from
#   - CMake, for one target or for every target of a (third party) directory
#     tree that is added with add_subdirectory(), and
#   - a script that prints the same options for consumers that are not CMake
#     (e.g. a cargo/rustc build), so that there is only one source of truth.
#
# What the knobs do (the cache variable of each is PSI_BUILD_<keyword>):
#
#   LTO_LINK_O                2|3  LLVM IR optimization level of the LTO pipeline
#                                  (ELF/Mach-O lld --lto-O<N>, lld-link /opt:lldlto=<N>)
#   LTO_LINK_CGO              2|3  LTO code generation level (--lto-CGO<N>, /opt:lldltocgo=<N>);
#                                  empty = the linker follows LTO_LINK_O
#   LINKER_O                  0|1|2 linker -O (string merging/ICF), not an LTO option;
#                                  lld-link: /opt:lldoptref (+ /opt:lldtailmerge for 2)
#   LINK_ICF_ALL              ON|OFF -Wl,--icf=all (not applied on Windows)
#   LTO_LINK_INLINE_THRESHOLD N    -inline-threshold given to the LTO backend at link
#   LTO_LINK_DISABLE_VECTORIZE / LTO_LINK_DISABLE_LOOP_VECTORIZE
#                             ON|OFF turn the vectorizers (or only the loop vectorizer) off in
#                                  the LTO backend; `#pragma clang loop vectorize(enable)` loops
#                                  still vectorize with the loop vectorizer-only switch
#   LTO_LINK_MACHINE_OUTLINER / LTO_LINK_HOT_COLD_SPLIT
#                             ON|OFF force --enable-machine-outliner / --hot-cold-split into the
#                                  LTO backend (ELF/Mach-O only, see "Caveats")
#   COMPILE_INLINE_THRESHOLD  N    -inline-threshold given to the compile step of every target
#                                  (-mllvm -inline-threshold=<N>), independent of the link-time one:
#                                  the two stages decide different calls, see "Two stages"
#   LTO_INLINE_THRESHOLD_AT_COMPILE
#                             ON|OFF shorthand: give the compile step the link-time threshold
#                                  (ignored when COMPILE_INLINE_THRESHOLD is set)
#
# Everything is applied to the Release and DevRelease configurations unless
# CONFIGS says otherwise, and only when PSI_BUILD_LTO_KNOBS (or the ENABLED
# argument) is ON.
#
# Two stages: with -flto the compile step still runs LLVM's pre-link pipeline,
# and that pipeline already inlines (at the default threshold) calls inside one
# translation unit. The link-time threshold therefore decides about the calls
# that are still pending at link (in practice the ones across translation
# units); it cannot take back what the compile step has already inlined, so a
# threshold *below* the default shrinks nothing inside a TU unless it is also
# given to the compile step (COMPILE_INLINE_THRESHOLD, or LTO_INLINE_THRESHOLD_AT_COMPILE
# to reuse the link-time value). The reverse also holds: a compile-time threshold alone
# is undone by the link-time inliner at its default. For a threshold sweep set both;
# the two values need not be equal. The same holds for rustc, see below.
#
# CMake usage
#
#   include( deps/psiha/build/lto_link_knobs.cmake )
#   # one target: values come from the PSI_BUILD_* cache variables unless given
#   PSI_lto_link_knobs( my_exe other_target LTO_LINK_O 3 LTO_LINK_INLINE_THRESHOLD 100 COMPILE_INLINE_THRESHOLD 100 )
#   # all targets of a directory tree, after the add_subdirectory() that created them:
#   add_subdirectory( deps/some_lib )
#   PSI_lto_link_knobs_in_directory( deps/some_lib EXCLUDE tool_not_to_touch )
#
# The link options go to executables, shared libraries and modules (static and
# object libraries carry none); the compile option (if requested) goes to every
# target that compiles sources. Explicit arguments win over the cache variables;
# an explicitly empty value ("") means "not set", so a project with variables of
# its own can forward them without the cache entries interfering:
#   PSI_lto_link_knobs( t ENABLED ${MY_SWITCH} LTO_LINK_O "${MY_LTO_O}" )
# Also available: CONFIGS <config>... and FLAVOR gnu|coff (default: coff for
# clang-cl, gnu otherwise; "gnu" is the -Wl,... syntax of ELF and Mach-O lld).
#
# Script usage (prints one option per line on stdout)
#
#   cmake -DPSI_BUILD_LTO_LINK_O=3 -DPSI_BUILD_LTO_LINK_CGO=3 \
#         -DPSI_BUILD_LTO_LINK_INLINE_THRESHOLD=100 -DPSI_BUILD_LINK_ICF_ALL=ON \
#         -DPSI_BUILD_FORMAT=rustc -DPSI_BUILD_RUSTC_LTO=linker-plugin \
#         -P deps/psiha/build/lto_link_knobs.cmake
#
#   PSI_BUILD_FORMAT   link     the linker command line options (default)
#                      compile  the compile step options (one line: split it on white space)
#                      rustc    ready-made rustc codegen options, see below
#   PSI_BUILD_LINK_FLAVOR gnu|coff  (default: coff on a Windows host, gnu elsewhere)
#   PSI_BUILD_RUSTC_LTO   fat|linker-plugin  (rustc format only, default fat)
#
# The knob variables are the same PSI_BUILD_* ones (the script ignores
# PSI_BUILD_LTO_KNOBS: asking for the options is the switch).
#
# rustc: the LLVM backend runs in one of two places and the options have to go
# where it runs. With rustc's own LTO (`lto = "fat"`/"thin") everything
# runs inside rustc, and `-C llvm-args=<opt>` is the only way to reach it (it
# covers the pre-link and the LTO stage alike, so there is no second place to
# set); the lld-only options (--lto-O, --lto-CGO) do not exist there. With
# `-C linker-plugin-lto` the crates are compiled to bitcode and lld runs the
# backend: the options are `-C link-arg=-Wl,--lto-O3`,
# `-C link-arg=-Wl,-mllvm,-inline-threshold=N`, ... (the format assumes the
# linker is driven through a clang/gcc-style driver), while `-C llvm-args=...`
# still reaches the pre-link pipeline of rustc itself, which is what
# LTO_INLINE_THRESHOLD_AT_COMPILE selects. The `rustc` format prints the
# right set for PSI_BUILD_RUSTC_LTO.
#
# Caveats
#  - Knobs applied at link only reach the backend run by the linker: not the
#    per-TU compile of non-LTO objects, and, with -flto, not the decisions the
#    pre-link pipeline has already taken (see "Two stages").
#  - The machine outliner and hot/cold splitting are off in the linker's backend
#    by default; forcing them into it is a known dead end with clang-cl on Windows
#    (WinEH unwind-table labels get merged/split incorrectly), so they are not
#    applied for the coff flavor.
#  - -Wl,--lto-O/--lto-CGO and -Wl,-mllvm,... need lld (also Apple's ld64.lld);
#    Apple's own ld64 does not know them.
#
################################################################################

include_guard( GLOBAL )

# An explicitly empty argument value ("") has to count as given (empty), not as missing.
if( POLICY CMP0174 )
    cmake_policy( SET CMP0174 NEW )
endif()

set( _psi_lto_knobs_value_keywords
    LTO_LINK_O LTO_LINK_CGO LINKER_O LTO_LINK_INLINE_THRESHOLD COMPILE_INLINE_THRESHOLD FLAVOR ENABLED
)
set( _psi_lto_knobs_flag_keywords
    LINK_ICF_ALL
    LTO_LINK_DISABLE_VECTORIZE LTO_LINK_DISABLE_LOOP_VECTORIZE
    LTO_LINK_MACHINE_OUTLINER LTO_LINK_HOT_COLD_SPLIT
    LTO_INLINE_THRESHOLD_AT_COMPILE
)

# The configurations the knobs apply to unless CONFIGS is given.
set( _psi_lto_knobs_default_configs Release DevRelease )

################################################################################
# Resolution of the arguments: every keyword not given falls back to its cache
# variable PSI_BUILD_<keyword> (ENABLED to PSI_BUILD_LTO_KNOBS). The result is a
# list of KEY=VALUE strings. Arguments: <out_var> <arguments...>; what is not a
# keyword is returned in <out_var>_positional.
################################################################################
macro( _psi_lto_knobs_resolve out_var )
    # (a macro: PARSE_ARGV reads the arguments of the calling function exactly as they were
    # passed, which keeps explicitly empty values that ${ARGN} would drop)
    cmake_parse_arguments( PARSE_ARGV 0 _psi_arg
        "" "${_psi_lto_knobs_value_keywords};${_psi_lto_knobs_flag_keywords}" "CONFIGS;EXCLUDE" )
    set( ${out_var} "" )
    foreach( _psi_keyword IN LISTS _psi_lto_knobs_value_keywords _psi_lto_knobs_flag_keywords )
        if( DEFINED _psi_arg_${_psi_keyword} )
            set( _psi_value "${_psi_arg_${_psi_keyword}}" )
        elseif( _psi_keyword STREQUAL "ENABLED" )
            set( _psi_value "${PSI_BUILD_LTO_KNOBS}" )
        elseif( _psi_keyword STREQUAL "FLAVOR" )
            if( WIN32 AND CLANG_CL )
                set( _psi_value coff )
            else()
                set( _psi_value gnu )
            endif()
        else()
            set( _psi_value "${PSI_BUILD_${_psi_keyword}}" )
        endif()
        list( APPEND ${out_var} "${_psi_keyword}=${_psi_value}" )
    endforeach()
    if( _psi_arg_CONFIGS )
        set( _psi_configs ${_psi_arg_CONFIGS} )
    else()
        set( _psi_configs ${_psi_lto_knobs_default_configs} )
    endif()
    string( REPLACE ";" "," _psi_configs "${_psi_configs}" )
    list( APPEND ${out_var} "CONFIGS=${_psi_configs}" )
    string( REPLACE ";" "," _psi_excluded "${_psi_arg_EXCLUDE}" )
    list( APPEND ${out_var} "EXCLUDE=${_psi_excluded}" )
    set( ${out_var}_positional "${_psi_arg_UNPARSED_ARGUMENTS}" )
endmacro()

# Spreads a resolved specification into s_<KEY> variables of the caller.
macro( _psi_lto_knobs_load spec )
    foreach( _psi_item IN LISTS ${spec} )
        if( _psi_item MATCHES "^([A-Z_]+)=(.*)$" )
            set( s_${CMAKE_MATCH_1} "${CMAKE_MATCH_2}" )
        endif()
    endforeach()
endmacro()

################################################################################
# The knobs as flavor-neutral entries, in the order they are emitted:
#   lto-o:<N>  lto-cgo:<N>  linker-o:<N>  icf:  llvm:<LLVM option>
# <entries_var> is what the linker gets, <compile_var> the compile step's.
################################################################################
function( _psi_lto_knobs_entries entries_var compile_var spec )
    _psi_lto_knobs_load( spec )
    set( entries "" )
    set( compile "" )
    foreach( check IN ITEMS "LTO_LINK_O|^[23]$" "LTO_LINK_CGO|^[23]$" "LINKER_O|^[012]$" "LTO_LINK_INLINE_THRESHOLD|^[0-9]+$" "COMPILE_INLINE_THRESHOLD|^[0-9]+$" )
        string( REPLACE "|" ";" check "${check}" )
        list( GET check 0 name )
        list( GET check 1 regex )
        if( NOT "${s_${name}}" STREQUAL "" AND NOT "${s_${name}}" MATCHES "${regex}" )
            message( WARNING "psi.build: ${name}='${s_${name}}' is ignored (expected ${regex})" )
        endif()
    endforeach()

    if( s_LTO_LINK_O MATCHES "^[23]$" )
        list( APPEND entries "lto-o:${s_LTO_LINK_O}" )
    endif()
    if( s_LTO_LINK_CGO MATCHES "^[23]$" )
        list( APPEND entries "lto-cgo:${s_LTO_LINK_CGO}" )
    endif()
    if( s_LINKER_O MATCHES "^[012]$" )
        list( APPEND entries "linker-o:${s_LINKER_O}" )
    endif()
    if( s_LINK_ICF_ALL AND NOT s_FLAVOR STREQUAL "coff" AND ( _psi_lto_knobs_in_script OR NOT WIN32 ) )
        list( APPEND entries "icf:" )
    endif()
    if( s_LTO_LINK_INLINE_THRESHOLD MATCHES "^[0-9]+$" )
        list( APPEND entries "llvm:-inline-threshold=${s_LTO_LINK_INLINE_THRESHOLD}" )
    endif()
    if( s_COMPILE_INLINE_THRESHOLD MATCHES "^[0-9]+$" )
        list( APPEND compile "llvm:-inline-threshold=${s_COMPILE_INLINE_THRESHOLD}" )
    elseif( s_LTO_INLINE_THRESHOLD_AT_COMPILE AND s_LTO_LINK_INLINE_THRESHOLD MATCHES "^[0-9]+$" )
        list( APPEND compile "llvm:-inline-threshold=${s_LTO_LINK_INLINE_THRESHOLD}" )
    endif()
    if( s_LTO_LINK_DISABLE_VECTORIZE )
        list( APPEND entries "llvm:-vectorize-loops=false" "llvm:-vectorize-slp=false" )
    elseif( s_LTO_LINK_DISABLE_LOOP_VECTORIZE )
        list( APPEND entries "llvm:-vectorize-loops=false" )
    endif()
    if( NOT s_FLAVOR STREQUAL "coff" )
        if( s_LTO_LINK_MACHINE_OUTLINER )
            list( APPEND entries "llvm:-enable-machine-outliner" )
        endif()
        if( s_LTO_LINK_HOT_COLD_SPLIT )
            list( APPEND entries "llvm:-hot-cold-split" )
        endif()
    endif()
    set( ${entries_var} "${entries}" PARENT_SCOPE )
    set( ${compile_var} "${compile}" PARENT_SCOPE )
endfunction()

# Renders one entry as linker command line option(s).
function( _psi_lto_knobs_link_tokens out_var flavor entry )
    string( REGEX MATCH "^([a-z-]+):(.*)$" _ "${entry}" )
    set( kind  "${CMAKE_MATCH_1}" )
    set( value "${CMAKE_MATCH_2}" )
    if( flavor STREQUAL "coff" )
        if( kind STREQUAL "lto-o" )
            set( tokens "/opt:lldlto=${value}" )
        elseif( kind STREQUAL "lto-cgo" )
            set( tokens "/opt:lldltocgo=${value}" )
        elseif( kind STREQUAL "linker-o" )
            set( tokens "/opt:lldoptref" )
            if( value STREQUAL "2" )
                list( APPEND tokens "/opt:lldtailmerge" )
            endif()
        elseif( kind STREQUAL "llvm" )
            set( tokens "/mllvm:${value}" )
        else()
            set( tokens "" )
        endif()
    else()
        if( kind STREQUAL "lto-o" )
            set( tokens "-Wl,--lto-O${value}" )
        elseif( kind STREQUAL "lto-cgo" )
            set( tokens "-Wl,--lto-CGO${value}" )
        elseif( kind STREQUAL "linker-o" )
            set( tokens "-Wl,-O${value}" )
        elseif( kind STREQUAL "icf" )
            set( tokens "-Wl,--icf=all" )
        elseif( kind STREQUAL "llvm" )
            set( tokens "-Wl,-mllvm,${value}" )
        else()
            set( tokens "" )
        endif()
    endif()
    set( ${out_var} "${tokens}" PARENT_SCOPE )
endfunction()

################################################################################
# CMake: PSI_lto_link_knobs( <target>... [CONFIGS <config>...] [<keyword> <value>]... )
################################################################################
function( _psi_lto_knobs_apply_to_target target spec )
    _psi_lto_knobs_load( spec )
    if( NOT s_ENABLED OR NOT TARGET ${target} )
        return()
    endif()
    _psi_lto_knobs_entries( entries compile_entries "${spec}" )
    set( prefix "$<$<CONFIG:${s_CONFIGS}>:" )
    set( suffix ">" )

    get_target_property( type ${target} TYPE )
    if( type MATCHES "^(EXECUTABLE|SHARED_LIBRARY|MODULE_LIBRARY)$" )
        set( described "" )
        foreach( entry IN LISTS entries )
            _psi_lto_knobs_link_tokens( tokens "${s_FLAVOR}" "${entry}" )
            foreach( token IN LISTS tokens )
                target_link_options( ${target} PRIVATE "${prefix}${token}${suffix}" )
                string( APPEND described " ${token}" )
            endforeach()
        endforeach()
        if( described )
            message( STATUS "psi.build: ${target} LTO link options:${described}" )
        endif()
    endif()

    if( compile_entries AND type MATCHES "^(EXECUTABLE|SHARED_LIBRARY|MODULE_LIBRARY|STATIC_LIBRARY|OBJECT_LIBRARY)$" )
        if( NOT CMAKE_CXX_COMPILER_ID MATCHES "Clang" AND NOT CMAKE_C_COMPILER_ID MATCHES "Clang" )
            message( WARNING "psi.build: ${target}: the compile-step inline threshold needs clang (-mllvm); skipped" )
        else()
            foreach( entry IN LISTS compile_entries )
                string( REGEX REPLACE "^llvm:" "" option "${entry}" )
                target_compile_options( ${target} PRIVATE "${prefix}SHELL:-mllvm ${option}${suffix}" )
            endforeach()
        endif()
    endif()
endfunction()

function( PSI_lto_link_knobs )
    _psi_lto_knobs_resolve( spec )
    foreach( target IN LISTS spec_positional )
        _psi_lto_knobs_apply_to_target( ${target} "${spec}" )
    endforeach()
endfunction()

################################################################################
# CMake: PSI_lto_link_knobs_in_directory( <dir> [EXCLUDE <target>...] [same as above] )
# Applies the knobs to every target created in <dir> and below. Call it after
# the add_subdirectory() that created them (CMake can only list what exists).
################################################################################
function( _psi_lto_knobs_apply_to_directory dir spec )
    _psi_lto_knobs_load( spec )
    string( REPLACE "," ";" excluded "${s_EXCLUDE}" )
    get_directory_property( targets DIRECTORY "${dir}" BUILDSYSTEM_TARGETS )
    foreach( target IN LISTS targets )
        if( NOT target IN_LIST excluded )
            _psi_lto_knobs_apply_to_target( ${target} "${spec}" )
        endif()
    endforeach()
    get_directory_property( subdirs DIRECTORY "${dir}" SUBDIRECTORIES )
    foreach( subdir IN LISTS subdirs )
        _psi_lto_knobs_apply_to_directory( "${subdir}" "${spec}" )
    endforeach()
endfunction()

function( PSI_lto_link_knobs_in_directory dir )
    _psi_lto_knobs_resolve( spec )
    get_filename_component( dir "${dir}" ABSOLUTE )
    _psi_lto_knobs_apply_to_directory( "${dir}" "${spec}" )
endfunction()

################################################################################
# Script mode: print the options.
################################################################################
function( _psi_lto_knobs_script_spec )
    _psi_lto_knobs_resolve( spec )
    set( spec "${spec}" PARENT_SCOPE )
endfunction()

function( _psi_lto_knobs_print )
    set( _psi_lto_knobs_in_script ON ) # the host's WIN32 says nothing about the link that is described
    if( NOT PSI_BUILD_FORMAT )
        set( PSI_BUILD_FORMAT link )
    endif()
    if( NOT PSI_BUILD_RUSTC_LTO )
        set( PSI_BUILD_RUSTC_LTO fat )
    endif()
    if( PSI_BUILD_LINK_FLAVOR )
        set( flavor "${PSI_BUILD_LINK_FLAVOR}" )
    elseif( CMAKE_HOST_WIN32 )
        set( flavor coff )
    else()
        set( flavor gnu )
    endif()
    if( NOT flavor MATCHES "^(gnu|coff)$" )
        message( FATAL_ERROR "PSI_BUILD_LINK_FLAVOR='${flavor}': expected gnu or coff" )
    endif()
    if( NOT PSI_BUILD_RUSTC_LTO MATCHES "^(fat|linker-plugin)$" )
        message( FATAL_ERROR "PSI_BUILD_RUSTC_LTO='${PSI_BUILD_RUSTC_LTO}': expected fat or linker-plugin" )
    endif()

    _psi_lto_knobs_script_spec( ENABLED ON FLAVOR "${flavor}" )
    _psi_lto_knobs_entries( entries compile_entries "${spec}" )

    set( lines "" )
    if( PSI_BUILD_FORMAT STREQUAL "link" )
        foreach( entry IN LISTS entries )
            _psi_lto_knobs_link_tokens( tokens "${flavor}" "${entry}" )
            list( APPEND lines ${tokens} )
        endforeach()
    elseif( PSI_BUILD_FORMAT STREQUAL "compile" )
        set( line "" )
        foreach( entry IN LISTS compile_entries )
            string( REGEX REPLACE "^llvm:" "" option "${entry}" )
            string( APPEND line " -mllvm ${option}" )
        endforeach()
        string( STRIP "${line}" line )
        if( line )
            list( APPEND lines "${line}" )
        endif()
    elseif( PSI_BUILD_FORMAT STREQUAL "rustc" )
        foreach( entry IN LISTS entries )
            string( REGEX MATCH "^([a-z-]+):(.*)$" _ "${entry}" )
            set( kind "${CMAKE_MATCH_1}" )
            set( value "${CMAKE_MATCH_2}" )
            _psi_lto_knobs_link_tokens( tokens "${flavor}" "${entry}" )
            if( kind STREQUAL "linker-o" OR kind STREQUAL "icf" )
                # the final link of native objects, whoever ran the LTO
                foreach( token IN LISTS tokens )
                    list( APPEND lines "-C link-arg=${token}" )
                endforeach()
            elseif( PSI_BUILD_RUSTC_LTO STREQUAL "fat" )
                if( kind STREQUAL "llvm" )
                    list( APPEND lines "-C llvm-args=${value}" )
                else()
                    message( NOTICE "psi.build: ${entry} has no counterpart with rustc's own LTO; skipped" )
                endif()
            else()
                foreach( token IN LISTS tokens )
                    list( APPEND lines "-C link-arg=${token}" )
                endforeach()
            endif()
        endforeach()
        if( PSI_BUILD_RUSTC_LTO STREQUAL "fat" AND compile_entries AND NOT entries MATCHES "llvm:-inline-threshold" )
            # one pipeline: a compile-step threshold without a link-time one is the only threshold
            foreach( entry IN LISTS compile_entries )
                string( REGEX REPLACE "^llvm:" "" option "${entry}" )
                list( APPEND lines "-C llvm-args=${option}" )
            endforeach()
        elseif( PSI_BUILD_RUSTC_LTO STREQUAL "linker-plugin" )
            # the pre-link pipeline of rustc itself
            foreach( entry IN LISTS compile_entries )
                string( REGEX REPLACE "^llvm:" "" option "${entry}" )
                list( APPEND lines "-C llvm-args=${option}" )
            endforeach()
        endif()
    else()
        message( FATAL_ERROR "PSI_BUILD_FORMAT='${PSI_BUILD_FORMAT}': expected link, compile or rustc" )
    endif()

    foreach( line IN LISTS lines )
        execute_process( COMMAND "${CMAKE_COMMAND}" -E echo "${line}" )
    endforeach()
endfunction()

if( CMAKE_SCRIPT_MODE_FILE )
    get_filename_component( _psi_script  "${CMAKE_SCRIPT_MODE_FILE}" REALPATH )
    get_filename_component( _psi_current "${CMAKE_CURRENT_LIST_FILE}" REALPATH )
    if( _psi_script STREQUAL _psi_current )
        _psi_lto_knobs_print()
        return()
    endif()
endif()

################################################################################
# The cache variables (project mode).
################################################################################

option( PSI_BUILD_LTO_KNOBS
    "Apply the LTO link-time knobs below (PSI_lto_link_knobs() and PSI_lto_link_knobs_in_directory() do nothing without it)"
    OFF )

set( PSI_BUILD_LTO_LINK_O "" CACHE STRING
    "LTO IR optimization level at link: 2 or 3 (empty = toolchain default)" )
set( PSI_BUILD_LTO_LINK_CGO "" CACHE STRING
    "LTO codegen optimization level at link: 2 or 3 (empty = lld default: same as LTO_LINK_O)" )
set( PSI_BUILD_LINKER_O "" CACHE STRING
    "lld linker -O (ICF/string merging), not LTO: 0, 1 or 2 (empty = toolchain default)" )
option( PSI_BUILD_LINK_ICF_ALL
    "Add -Wl,--icf=all to the link (lld/gold; not applied on Windows)"
    OFF )
set( PSI_BUILD_LTO_LINK_INLINE_THRESHOLD "" CACHE STRING
    "LLVM -inline-threshold of the LTO backend at link (empty = default; -Os-class is 50, O2-class 225); see also PSI_BUILD_COMPILE_INLINE_THRESHOLD" )
set( PSI_BUILD_COMPILE_INLINE_THRESHOLD "" CACHE STRING
    "LLVM -inline-threshold of the compile step (-mllvm; empty = default): the pre-link pipeline inlines inside a TU at the default threshold, and a lower link-time value is otherwise never seen. Independent of the link-time threshold" )
option( PSI_BUILD_LTO_INLINE_THRESHOLD_AT_COMPILE
    "Shorthand: give the compile step the link-time threshold (ignored when PSI_BUILD_COMPILE_INLINE_THRESHOLD is set)"
    OFF )
option( PSI_BUILD_LTO_LINK_DISABLE_VECTORIZE
    "Disable loop and SLP vectorization in the LTO backend at link"
    OFF )
option( PSI_BUILD_LTO_LINK_DISABLE_LOOP_VECTORIZE
    "Disable only the loop vectorizer in the LTO backend at link (SLP stays on; loops marked #pragma clang loop vectorize(enable) still vectorize)"
    OFF )
option( PSI_BUILD_LTO_LINK_MACHINE_OUTLINER
    "Force the machine outliner into the LTO backend (ELF/Mach-O only; known WinEH corruption with clang-cl)"
    OFF )
option( PSI_BUILD_LTO_LINK_HOT_COLD_SPLIT
    "Force hot/cold splitting into the LTO backend (ELF/Mach-O only; same WinEH caveat)"
    OFF )
