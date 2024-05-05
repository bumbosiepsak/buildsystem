include("${FRAMEWORK_LIB_PATH}/modules/execute_command.cmake")

execute_command("${FRAMEWORK_LIB_PATH}"
    COMMAND ${RENDERER}
        "${TRACEFILE_SUMMARY}"
        --output "${OUTPUT_DIRECTORY}/${RENDERING}"
    SILENT
)
