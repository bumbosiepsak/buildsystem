include("${FRAMEWORK_LIB_PATH}/modules/execute_command.cmake")

foreach(tracefile ${TRACEFILES})
    get_filename_component(summary_file "${tracefile}" NAME)

    if(EXISTS "${tracefile}")
        execute_command("${FRAMEWORK_LIB_PATH}"
            COMMAND ${LCOV} --summary "${tracefile}" --rc lcov_branch_coverage=1
            ERROR_FILE "${OUTPUT_DIRECTORY}/${summary_file}"
            SILENT
        )
    endif()
endforeach()
