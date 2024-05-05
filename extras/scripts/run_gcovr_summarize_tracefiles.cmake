include("${FRAMEWORK_LIB_PATH}/modules/execute_command.cmake")

foreach(tracefile ${TRACEFILES})
    get_filename_component(summary_file "${tracefile}" NAME_WE)

    if(EXISTS "${tracefile}")
        execute_command("${FRAMEWORK_LIB_PATH}"
            COMMAND ${GCOVR} --print-summary --add-tracefile "${tracefile}"
            OUTPUT_FILE "${OUTPUT_DIRECTORY}/${summary_file}.txt"
            SILENT
        )
    endif()
endforeach()
