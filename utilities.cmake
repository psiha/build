################################################################################
#
# T|N.U.N. CMake utilities
#
# Copyright (c) 2016. Domagoj saric. All rights reserved.
#
################################################################################

cmake_minimum_required( VERSION 3.0 )


################################################################################
# PSI_make_temp_path()
################################################################################

function( PSI_make_temp_path file_name_variable )
        if( EXISTS $ENV{TEMP} )
        set( temp_dir "$ENV{TEMP}" )
    elseif( EXISTS $ENV{TMP} )
        set( temp_dir "$ENV{TMP}" )
    elseif( EXISTS $ENV{TMPDIR} )
        set( temp_dir "$ENV{TMPDIR}" )
    else()
        set( temp_dir "${PROJECT_BINARY_DIR}" )
    endif()
    set( file_name ${${file_name_variable}} )
    set( ${file_name_variable} "${temp_dir}/${file_name}" PARENT_SCOPE )
endfunction()
