include_guard(GLOBAL)

include(print)

function(validate_build_dir target)
    STRING(TOLOWER "${target}" t)
    get_filename_component(BUILD_DIR_NAME ${CMAKE_BINARY_DIR} NAME)

    if(NOT BUILD_DIR_NAME MATCHES "[a-zA-Z_-]+-${t}$") # NOTE: Allowed "anything-host" and "anything-target" etc.
        print_fatal_error("You are not in proper build directory. You should navigate to 'build-${t}'")
    endif()
endfunction(validate_build_dir)

function(validate_variable_set variable_name)
    if(NOT ${variable_name})
        print_fatal_error("Your ${variable_name} has not been set at this stage of CMake configuration yet")
    endif()
endfunction(validate_variable_set)
