include_guard(GLOBAL)

function(targets_add_run_cmake)
    if(NOT TARGET run_cmake)
        add_custom_target(run_cmake # Forces CMake regeneration
            COMMAND ${CMAKE_COMMAND} touch -E ${CMAKE_CURRENT_LIST_FILE} # Git will ignore the timestamp
            DEPENDS ${CMAKE_CURRENT_LIST_FILE}
        )
    endif()
endfunction(targets_add_run_cmake)

function(targets_add_deploy)
    if(NOT TARGET deploy)
        add_custom_target(deploy)
    endif()
endfunction(targets_add_deploy)

function(targets_add_summarize)
    if(NOT TARGET summarize)
        add_custom_target(summarize)
    endif()
endfunction(targets_add_summarize)

function(targets_initialize)
    targets_add_run_cmake()
    targets_add_deploy()
    targets_add_summarize()
endfunction(targets_initialize)

function(targets_finalize)
endfunction(targets_finalize)
