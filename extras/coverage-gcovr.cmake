include_guard(GLOBAL)

include(get)
include(print)
include(tools)

set(COVERAGE_PLUGIN_GCOVR_DEPFILE ${CMAKE_CURRENT_LIST_FILE})

function(coverage_gcovr_find_tools)
    tools_find_simple(GCOVR_PATH gcovr)

    if(NOT COVERAGE_ANALYZER_TOOL)
        print_fatal_error("Undefined COVERAGE_ANALYZER_TOOL variable - expected to come from your toolchain file")
    endif()

    tools_find_simple(GCOV_PATH "${COVERAGE_ANALYZER_TOOL}")

    set(GCOVR "${GCOVR_PATH}"
        --root "${CMAKE_SOURCE_DIR}"
        --gcov-executable "${GCOV_PATH}"
        --source-encoding "UTF-8"
        PARENT_SCOPE
    )
endfunction(coverage_gcovr_find_tools)

# Adds gcovr coverage support
# Remark: invoke this function in scope common to all usages (e.g. on the project declaration level)
macro(coverage_gcovr_support_enable)
    cmake_parse_arguments(ARGS
        ""
        ""
        ""
        ${ARGN}
    )

    if(COVERAGE_TOOL)
        print_fatal_error("Only one coverage tool should be used at once. gcovr conflicts with ${COVERAGE_TOOL}")
    endif()

    if(BUILD_SUBTYPE STREQUAL "coverage")
        set(COVERAGE_SUPPORT 1)
        set(COVERAGE_TOOL "gcovr")

        coverage_gcovr_find_tools()

        set(COVERAGE_INTERNAL_DIRECTORY "${COVERAGE_WORKSPACE_DIRECTORY}/gcovr_internal")

        function(coverage_get_command_baseline out_command out_dependees out_tracefiles excluded_sources)
            set(${out_command}
                COMMAND ${CMAKE_COMMAND} -E remove_directory "${COVERAGE_INTERNAL_DIRECTORY}"
                COMMAND ${CMAKE_COMMAND} -E make_directory "${COVERAGE_INTERNAL_DIRECTORY}"
                PARENT_SCOPE
            )
            set("${out_dependees}" "${COVERAGE_PLUGIN_GCOVR_DEPFILE}" PARENT_SCOPE)
        endfunction(coverage_get_command_baseline)

        function(coverage_get_command_capture out_command out_dependees out_tracefiles excluded_sources tag)
            set(tracefile "${COVERAGE_INTERNAL_DIRECTORY}/tracefile_capture_${tag}.json")

            foreach(excluded_source ${excluded_sources})
                get_regexes_from_globs(excluded_source "${excluded_source}")
                set(excluded_sources_arguments ${excluded_sources_arguments} --exclude "${excluded_source}")
            endforeach()

            set(${out_command}
                COMMAND ${CMAKE_COMMAND} -E make_directory "${COVERAGE_INTERNAL_DIRECTORY}"
                COMMAND ${GCOVR}
                    --output "${tracefile}"
                    --delete
                    --json
                    ${excluded_sources_arguments}
                    "${CMAKE_BINARY_DIR}" # gcovr argument: "search_paths"
                PARENT_SCOPE
            )
            set("${out_tracefiles}" "${tracefile}" PARENT_SCOPE)
            set("${out_dependees}" "${COVERAGE_PLUGIN_GCOVR_DEPFILE}" PARENT_SCOPE)
        endfunction(coverage_get_command_capture)

    function(coverage_get_command_render out_command out_byproducts baseline tracefiles excluded_sources)
            set(tracefile_summary "${COVERAGE_INTERNAL_DIRECTORY}/tracefile_summary.json")
            set(run_gcovr_merge_tracefiles "${FRAMEWORK_LIB_PATH}/extras/scripts/run_gcovr_merge_tracefiles.cmake")
            set(run_gcovr_summarize_tracefiles "${FRAMEWORK_LIB_PATH}/extras/scripts/run_gcovr_summarize_tracefiles.cmake")
            set(run_gcovr "${FRAMEWORK_LIB_PATH}/extras/scripts/run_gcovr.cmake")

            get_string_from_list(arg_gcovr "${GCOVR}" "$<SEMICOLON>")
            get_string_from_list(arg_tracefiles "${tracefiles}" "$<SEMICOLON>")

            set(${out_command}
                COMMAND ${CMAKE_COMMAND} -E make_directory "${COVERAGE_INTERNAL_DIRECTORY}"
                COMMAND ${CMAKE_COMMAND} -E remove_directory "${COVERAGE_REPORTS_DIRECTORY}"
                COMMAND ${CMAKE_COMMAND} -E make_directory "${COVERAGE_REPORTS_DIRECTORY}"
                COMMAND ${CMAKE_COMMAND} # NOTE: Using a wrapper script, as bare gcovr rejects empty tracefiles
                    "-DGCOVR=${arg_gcovr}"
                    "-DFRAMEWORK_LIB_PATH=${FRAMEWORK_LIB_PATH}"
                    "-DOUTPUT_FILE=${tracefile_summary}"
                    "-DTRACEFILES=${arg_tracefiles}"
                    -P "${run_gcovr_merge_tracefiles}"
                COMMAND ${CMAKE_COMMAND} # NOTE: Using a wrapper script to discover tests, which truly completed
                    "-DGCOVR=${arg_gcovr}"
                    "-DFRAMEWORK_LIB_PATH=${FRAMEWORK_LIB_PATH}"
                    "-DOUTPUT_DIRECTORY=${COVERAGE_REPORTS_DIRECTORY}"
                    "-DTRACEFILES=${arg_tracefiles}$<SEMICOLON>${tracefile_summary}"
                    -P "${run_gcovr_summarize_tracefiles}"
                COMMAND ${CMAKE_COMMAND}
                    "-DGCOVR=${arg_gcovr}"
                    "-DFRAMEWORK_LIB_PATH=${FRAMEWORK_LIB_PATH}"
                    "-DOUTPUT_DIRECTORY=${COVERAGE_REPORTS_DIRECTORY}"
                    "-DRENDERING=index.html"
                    "-DTRACEFILES=${arg_tracefiles}"
                    "-DTRACEFILE_SUMMARY=${tracefile_summary}"
                    "-DCOVERAGE_FORMAT=HUMAN"
                    -P "${run_gcovr}"
                COMMAND ${CMAKE_COMMAND}
                    "-DGCOVR=${arg_gcovr}"
                    "-DFRAMEWORK_LIB_PATH=${FRAMEWORK_LIB_PATH}"
                    "-DOUTPUT_DIRECTORY=${COVERAGE_REPORTS_DIRECTORY}"
                    "-DRENDERING=index.xml"
                    "-DTRACEFILES=${arg_tracefiles}"
                    "-DTRACEFILE_SUMMARY=${tracefile_summary}"
                    "-DCOVERAGE_FORMAT=COBERTURA"
                    -P "${run_gcovr}"
                PARENT_SCOPE
            )

            set("${out_byproducts}"
                "${COVERAGE_INTERNAL_DIRECTORY}"
                "${COVERAGE_REPORTS_DIRECTORY}"
                "${tracefile_summary}"
                PARENT_SCOPE
            )
        endfunction(coverage_get_command_render)
    endif()
endmacro(coverage_gcovr_support_enable)
