################################################################################
#
# Warning silencing utilities
#
################################################################################

function( psi_silence_all_warnings_on_targets )
    foreach( target ${ARGV} )
        if( CMAKE_CXX_COMPILER_ID MATCHES "MSVC" )
            # TODO this does not help with warning options set up the hierachy
            # (globally or on the parent directory) - and we still get MSVC
            # complaining about overriding warning options
            get_target_property( target_options ${target} COMPILE_OPTIONS )
            list( REMOVE_ITEM target_options "-W4" "-W3" "-W2" "-W1" )
            set_target_properties( ${target} PROPERTIES COMPILE_OPTIONS "${target_options}" )
        endif()
        target_compile_options( ${target} PRIVATE "-w" )
    endforeach()
endfunction()

function( psi_silence_all_warnings_on_sources )
    set_source_files_properties( ${ARGV} PROPERTIES COMPILE_OPTIONS "-w" )
endfunction()
