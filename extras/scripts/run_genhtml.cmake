include("${FRAMEWORK_LIB_PATH}/modules/execute_command.cmake")

set(test_tags "")

foreach(tracefile ${TRACEFILES})
    if(EXISTS "${tracefile}")
        string(REGEX REPLACE ".*tracefile_capture_(.+)[.]txt" "\\1" tag "${tracefile}")
        string(APPEND test_tags "${tag} ")
    endif()
endforeach()

execute_command("${FRAMEWORK_LIB_PATH}"
    COMMAND ${RENDERER}
        --output-directory "${OUTPUT_DIRECTORY}"
        --baseline-file "${BASELINE}"
        --title "${test_tags}"
        "${TRACEFILE_SUMMARY}"
    SILENT
)
