
function(execute_command working_directory)
    cmake_parse_arguments(ARGS
        "SILENT;ALLOWED_TO_FAIL"
        "EXIT_CODE;OUTPUT;ERROR"
        "COMMAND"
        ${ARGN}
    )
    set(THIS_COMMAND ${ARGN})

    if(NOT ARGS_SILENT)
        execute_process(
            COMMAND ${CMAKE_COMMAND} -E echo Executing ${ARGS_COMMAND} ${ARGS_UNPARSED_ARGUMENTS}
        )
    endif()

    execute_process(
        COMMAND ${ARGS_COMMAND} ${ARGS_UNPARSED_ARGUMENTS}
        WORKING_DIRECTORY "${working_directory}"
        RESULT_VARIABLE EXIT_CODE
        OUTPUT_VARIABLE OUTPUT
        ERROR_VARIABLE ERRORS
    )

    if(EXIT_CODE AND NOT ARGS_ALLOWED_TO_FAIL)
        message(FATAL_ERROR "Command '${ARGS_COMMAND}' failed: ${EXIT_CODE} ${ERRORS}")
    endif()

    if(ARGS_EXIT_CODE)
        set(${ARGS_EXIT_CODE} ${EXIT_CODE} PARENT_SCOPE)
    endif()

    if(ARGS_OUTPUT)
        set(${ARGS_OUTPUT} ${OUTPUT} PARENT_SCOPE)
    endif()

    if(ARGS_ERROR)
        set(${ARGS_ERROR} ${ERROR} PARENT_SCOPE)
    endif()
endfunction(execute_command)
