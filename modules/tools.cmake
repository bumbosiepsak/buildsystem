include_guard(GLOBAL)

include(print)
include(toolchain)

function(tools_call_python result command)
    execute_process(
        COMMAND ${PYTHON} -c "${command}"
        RESULT_VARIABLE exit_code
        OUTPUT_VARIABLE output
        ERROR_VARIABLE error
    )

    if(NOT exit_code EQUAL 0)
        print_fatal_error("Calling ${PYTHON} failed for command ${command}: ${output} ${error}")
    endif()

    set(${result} ${output} PARENT_SCOPE)
endfunction(tools_call_python)

macro(tools_find_simple out_alias)
    find_program(${out_alias}
        NAMES ${ARGN}
    )

    if(${out_alias})
        message("-- Found ${ARGV1}: '${${out_alias}}'")
    else()
        print_fatal_error("Mandatory tool not found: ${ARGV1}")
    endif()
endmacro(tools_find_simple)

function(tools_find_python)
    if(DEFINED PYTHON3_VIRTUALENV_PATH)
        if(NOT IS_DIRECTORY "${PYTHON3_VIRTUALENV_PATH}")
            print_fatal_error("Requested Python3 virtualenv does not exist: ${PYTHON3_VIRTUALENV_PATH}")
        endif()
        set(ENV{VIRTUAL_ENV} "${PYTHON3_VIRTUALENV_PATH}")
        set(Python3_FIND_VIRTUALENV ONLY)
    endif()

    set(Python3_FIND_REGISTRY LAST)
    find_package(Python3 REQUIRED COMPONENTS Interpreter)

    if(${Python3_VERSION} VERSION_LESS 3.8)
        print_fatal_error("Expecting minimum Python version: 3.8 got: ${Python3_VERSION}")
    endif()

    set(PYTHON "${Python3_EXECUTABLE}" "-X" "pycache_prefix=${CMAKE_BINARY_DIR}/pycache" PARENT_SCOPE)
endfunction(tools_find_python)

function(tools_find_render_version)
    set(RENDER_VERSION ${PYTHON} "${CMAKE_SOURCE_DIR}/source/ci/render_version.py" PARENT_SCOPE)
endfunction(tools_find_render_version)

macro(tools_find_all)
    tools_find_python()
    tools_find_render_version()
endmacro(tools_find_all)
