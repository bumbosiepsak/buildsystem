include_guard(GLOBAL)

function(conventions_include_files convention_name)
endfunction(conventions_include_files)

function(conventions_exclude_files convention_name)
endfunction(conventions_exclude_files)

function(conventions_exclude_files_from_all)
endfunction(conventions_exclude_files_from_all)

function(conventions_define convention_name)
endfunction(conventions_define)

function(conventions_initialize)
endfunction(conventions_initialize)

function(conventions_finalize)
    add_custom_target(conventions_check
        COMMENT "Conventions check"
        COMMAND ${CMAKE_COMMAND} -E echo "FAILED: Conventions check: not present in this build"
        COMMAND ${CMAKE_COMMAND} -E false
    )
    add_custom_target(conventions_apply
        COMMENT "Conventions application"
        COMMAND ${CMAKE_COMMAND} -E echo "FAILED: Conventions application: not present in this build"
        COMMAND ${CMAKE_COMMAND} -E false
    )
endfunction(conventions_finalize)
