################################################################################
#
# TNUN Build utility CMake functionality
#
# Copyright (c) 2016. Domagoj Saric. All rights reserved.
#
################################################################################
# Implementation note: Because CMake lacks support for "One build, multiple
# compilers and packages."
# http://stackoverflow.com/questions/9542971/using-cmake-with-multiple-compilers-for-the-same-language
# http://cmake.3232098.n2.nabble.com/One-build-multiple-compilers-and-packages-td7585262.html
# http://www.kitware.com/media/html/BuildingExternalProjectsWithCMake2.8.html
# http://www.cmake.org/Wiki/CMake_FAQ#I_change_CMAKE_C_COMPILER_in_the_GUI_but_it_changes_back_on_the_next_configure_step._Why.3F
#                                             (25.02.2016.) (Domagoj Saric)
################################################################################

cmake_minimum_required( VERSION 3.1 )


################################################################################
# TNUN_add_abi_subproject()
################################################################################

function( TNUN_add_abi_subproject project_name abi )

  if ( TNUN_subproject_build )
    return()
  endif()
  
  if ( iOS ) #...mrmlj...cleanup this 'special pleading'...
    install(
      DIRECTORY      "${PROJECT_BINARY_DIR}/Release/"
      DESTINATION    "lib"
      COMPONENT      Libraries
      CONFIGURATIONS ${install_configs}
    )
  else()
    install(
      DIRECTORY      "${PROJECT_BINARY_DIR}/lib"
      DESTINATION    "."
      COMPONENT      Libraries
      CONFIGURATIONS ${install_configs}
    )
  endif()

  if ( abi STREQUAL TNUN_ABI )
    return()
  endif()

  set( binary_dir "${PROJECT_BINARY_DIR}/${abi}" ) #CACHE INTERNAL "Directory that contains the cache of the subproject" )
  message( STATUS "[TNUN] Creating the separate * ${abi} * build tree:" )

  if ( CMAKE_BUILD_TYPE )
    list( APPEND extra_forwarded_variables -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE} )
  endif()
  if ( CMAKE_TOOLCHAIN_FILE )
    file( TO_NATIVE_PATH "${CMAKE_TOOLCHAIN_FILE}" native_toolchain_path )
    list( APPEND extra_forwarded_variables -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${native_toolchain_path} ) #...mrmlj...cmake barfs if quotes are used...todo...handle paths with spaces...
  endif()

  set( generator "${CMAKE_GENERATOR}" )
  if( MSVC ) #...mrmlj...special msvc knowledge (different generator required for different ABI)...
    if ( CMAKE_GENERATOR MATCHES 64 )
      string( REPLACE " Win64" "" generator "${generator}" )
    else()
      set( generator "${generator} Win64" )
    endif()
  endif()
  
  execute_process( COMMAND "${CMAKE_COMMAND}" -E make_directory "${binary_dir}" )
  execute_process(
    COMMAND "${CMAKE_COMMAND}"
      -G ${generator}
      -DTNUN_subproject_build:BOOL=true
      -DTNUN_ABI:STRING=${abi}
      -DTNUN_binary_dir:PATH=${PROJECT_BINARY_DIR}
      ${extra_forwarded_variables}
      ${ARGN}
      "${CMAKE_SOURCE_DIR}"
    WORKING_DIRECTORY "${binary_dir}"
    ERROR_VARIABLE    stderr
    OUTPUT_VARIABLE   stdout
  )
  message( STATUS ${stdout} )
  if ( stderr )
    message( FATAL_ERROR "[TNUN] ${abi} build tree creation failure:\n${stderr}" )
  endif()
  if ( generator MATCHES Ninja )
    # Implementation note: limit/decrease the level of build parallelism to
    # match the number of cores (Ninja's N+2 logic only hogs the build
    # machine).
    # Merely appending -j ${cpuCount} to the cmake --build command (after a
    # -- delimiter) didn't work when executed from Visual Studio (CMake
    # complained that it does not recognize the -j option).
    #                                     (28.02.2016.) (Domagoj Saric)
    include( ProcessorCount )
    ProcessorCount( cpuCount )
    set( build_command ninja -C "${binary_dir}" -j ${cpuCount} )
  else()
    set( build_command "${CMAKE_COMMAND}" --build "${binary_dir}" --config "${CMAKE_CFG_INTDIR}" )
  endif()
  # Implementation note: For VS and projects which only generate a single
  # target, try to guess the vcxproj name and include it directly instead of
  # through the opaque CMake custom target (rethink this through: this may end
  # up 'guessing' and including a single .vcxproj even though more are
  # generated).
  #                                         (12.11.2015.) (Domagoj Saric)
  set( possible_vs_subproject "${binary_dir}/${project_name}.vcxproj" )
  if ( CMAKE_GENERATOR MATCHES Visual AND generator MATCHES Visual AND EXISTS "${possible_vs_subproject}" )
    include_external_msproject( ${project_name}_${abi} "${possible_vs_subproject}" PLATFORM Win32 )
  else()
    add_custom_target( ${project_name}_${abi} ALL
      COMMAND ${build_command}
      COMMENT "Building ${project_name} for ${abi}..."
      VERBATIM
    )
  endif()

endfunction()


################################################################################
# TNUN_add_arch_library()
################################################################################

function( TNUN_add_arch_library target_name target_label arch )

  if ( NOT TNUN_ABI )
    # Implementation note: with makefile/non-IDE generators the 'root
    # invocation' does not use a default ABI/create any targets in order to have
    # a 'symmetrical' build (i.e. all binaries are built in subprojects).
    #                                         (03.06.2016.) (Domagoj Saric)
    return()
  endif()
  
  # Implementation note: a workaround for the fact that the 'global' setting in
  # gcc_compatibles.cmake seems to have no effect.
  #                                           (03.06.2016.) (Domagoj Saric)
  cmake_policy( SET CMP0063 NEW )

  set( base_target_name ${target_name} )
  list( LENGTH TNUN_ABIs      number_of_abis  )
  list( LENGTH TNUN_cpu_archs number_of_archs )
  if ( ( number_of_archs GREATER 1 ) OR ( number_of_abis GREATER 1 ) )
    set( target_name  "${target_name}_${arch}"    )
    set( target_label "${target_label} (${arch})" )
  endif()
  set( target_name "${target_name}_${TNUN_os_suffix}" )
  # Implementation note: Because CMake is so defficient this function cannot be
  # generalised to TNUN_add_arch_target(), so that it supports both libraries
  # and executables by using something like
  # add_${target_type}
  # instead of the 'hardcoded' add_library() call.
  #                                           (03.06.2016.) (Domagoj Saric)
  add_library( ${target_name} ${ARGN} )
  set_property( TARGET ${target_name} PROPERTY PROJECT_LABEL "${target_label}" )
  TNUN_setup_target_for_arch( ${target_name} ${base_target_name} ${arch} )

  set( TNUN_all_arch_targets ${TNUN_all_arch_targets} ${target_name} PARENT_SCOPE )
  
  if ( iOS )
      TNUN_ios_add_universal_build( ${target_name} )
  endif()

endfunction()
