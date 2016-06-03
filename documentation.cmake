################################################################################
#
# T|N.U.N. Build documentation utilities
#
# Copyright (c) 2016. Domagoj saric. All rights reserved.
#
################################################################################

################################################################################
# add_documentation()
#
# Supported configuration variables ('global parameters') and their mappings to
# Doxygen options:
# TNUN_DOC_PROJECT_LABEL          -> PROJECT_NAME
# TNUN_DOC_PROJECT_VERSION        -> PROJECT_NUMBER
# TNUN_DOC_PROJECT_DESCRIPTION    -> PROJECT_BRIEF
# TNUN_DOC_PROJECT_LOGO           -> PROJECT_LOGO
# TNUN_DOC_STAGE_PATH             -> OUTPUT_DIRECTORY
# TNUN_DOC_HIDE_SCOPE_NAMES       -> HIDE_SCOPE_NAMES
# TNUN_DOC_ENABLED_SECTIONS       -> ENABLED_SECTIONS
# TNUN_DOC_SHOW_NAMESPACES        -> SHOW_NAMESPACES
# TNUN_DOC_SOURCES                -> INPUT
# TNUN_DOC_SOURCES_TO_EXCLUDE     -> EXCLUDE
# TNUN_DOC_EXAMPLE_PATH           -> EXAMPLE_PATH
# TNUN_DOC_FILTER_PATTERNS        -> FILTER_PATTERNS
# TNUN_DOC_CLANG_ASSISTED_PARSING -> CLANG_ASSISTED_PARSING
# TNUN_DOC_EXTRA_DEFINES          -> PREDEFINED
################################################################################

set( TNUN_dir "${CMAKE_CURRENT_LIST_DIR}" )

macro( TNUN_internal_cmake2doxy_boolean boolean )
  string( REPLACE "OFF" "NO"  ${boolean} ${${boolean}} )
  string( REPLACE "ON"  "YES" ${boolean} ${${boolean}} )
endmacro()

function( TNUN_add_documentation )

  # https://cmake.org/pipermail/cmake/2011-January/042313.html
  find_package( Doxygen )
  if ( NOT DOXYGEN_FOUND )
    message( WARNING "Unable to find Doxygen" )
    return()
  endif()
  
  if ( NOT DEFINED TNUN_DOC_STAGE_PATH )
    set( TNUN_DOC_STAGE_PATH "${PROJECT_BINARY_DIR}/doc" )
  endif()

  option( TNUN_DOC_CLANG_ASSISTED_PARSING "Use Clang for parsing sources when generating the documentation (more accurate but slower)" NO )
  if ( TNUN_DOC_CLANG_ASSISTED_PARSING )
    set( TNUN_DOXYGEN_CLANG_OPTIONS "-fms-extensions -fdelayed-template-parsing -fmsc-version=1900 -Wno-ignored-attributes -Wno-multichar -D\"BOOST_PP_CONFIG_FLAGS()\"=1 -DDOXYGEN_ONLY" )
  endif()

  option( TNUN_DOC_SHOW_NAMESPACES  YES )
  option( TNUN_DOC_HIDE_SCOPE_NAMES NO  )

  # Convert CMake list to a Doxygen-friendly "\ + newline" separated list.
  string( REPLACE ";" " \\\n\t" TNUN_DOC_SOURCES "${TNUN_DOC_SOURCES}" )
  TNUN_internal_cmake2doxy_boolean( TNUN_DOC_SHOW_NAMESPACES  )
  TNUN_internal_cmake2doxy_boolean( TNUN_DOC_HIDE_SCOPE_NAMES )
  TNUN_internal_cmake2doxy_boolean( TNUN_DOC_CLANG_ASSISTED_PARSING )
  configure_file(
    "${TNUN_dir}/doxyfile.in"
    "${PROJECT_BINARY_DIR}/doxyfile"
  )
  # Implementation note:
  # First remove the intermediate documentation directory to
  # ensure clean documentation generation (w/o leftovers from a
  # previous build).
  #                             (27.01.2014.) (Domagoj Saric)
  add_custom_target( Documentation
    COMMAND           "${CMAKE_COMMAND}" -E remove_directory "${TNUN_DOC_STAGE_PATH}"
    COMMAND           "${CMAKE_COMMAND}" -E make_directory   "${TNUN_DOC_STAGE_PATH}/html"
    COMMAND           "${DOXYGEN_EXECUTABLE}" "${PROJECT_BINARY_DIR}/doxyfile"
    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}/../doc"
    COMMENT           "Doxygen documentation"
    SOURCES           "${PROJECT_BINARY_DIR}/doxyfile"
                      #"${TNUN_DOC_SOURCES}"

  )
  set_property( TARGET Documentation PROPERTY EXCLUDE_FROM_ALL false )

  install(
    DIRECTORY      "${TNUN_DOC_STAGE_PATH}"
    DESTINATION    "./"
    COMPONENT      Documentation
    CONFIGURATIONS ${install_configs}
  )
  install(
    FILES          "${TNUN_dir}/documentation.html"
    DESTINATION    "./doc"
    COMPONENT      Documentation
    CONFIGURATIONS ${install_configs}
  )

endfunction()
