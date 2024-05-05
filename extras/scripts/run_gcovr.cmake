include("${FRAMEWORK_LIB_PATH}/modules/execute_command.cmake")

if(COVERAGE_FORMAT STREQUAL HUMAN)
    set(test_tags "")

    foreach(tracefile ${TRACEFILES})
        if(EXISTS "${tracefile}")
            string(REGEX REPLACE ".*tracefile_capture_(.+)[.]json" "\\1" tag "${tracefile}")
            string(APPEND test_tags "${tag} ")
        endif()
    endforeach()

    set(format_args
        --html-title "${test_tags}"
        --html
        --html-details
    )
else()
    set(format_args
        --xml
    )
endif()

execute_command("${FRAMEWORK_LIB_PATH}"
    COMMAND ${GCOVR}
        --output "${OUTPUT_DIRECTORY}/${RENDERING}"
        --add-tracefile "${TRACEFILE_SUMMARY}"
        ${format_args}
    SILENT
)
