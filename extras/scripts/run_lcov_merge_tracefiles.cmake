include("${FRAMEWORK_LIB_PATH}/modules/execute_command.cmake")

foreach(tracefile ${TRACEFILES})
    if(EXISTS "${tracefile}")
        set(tracefiles_arguments ${tracefiles_arguments} --add-tracefile "${tracefile}")
    endif()
endforeach()

if(NOT tracefiles_arguments)
    message(FATAL_ERROR "No tracefiles found. Capture coverage first")
endif()

execute_command("${FRAMEWORK_LIB_PATH}"
    COMMAND ${LCOV} --output-file "${OUTPUT_FILE}" ${tracefiles_arguments}
    SILENT
)
