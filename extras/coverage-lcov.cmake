include_guard(GLOBAL)

include(get)
include(print)
include(tools)

set(COVERAGE_PLUGIN_LCOV_DEPFILE ${CMAKE_CURRENT_LIST_FILE})

function(coverage_lcov_find_tools)
    tools_find_simple(GENHTML_PATH genhtml genhtml.perl genhtml.bat)
    tools_find_simple(LCOV_PATH lcov lcov.bat lcov.exe lcov.perl)
    tools_find_simple(LCOV_COBERTURA_PATH lcov_cobertura lcov_cobertura.exe)

    if(NOT COVERAGE_ANALYZER_TOOL)
        print_fatal_error("Undefined COVERAGE_ANALYZER_TOOL variable - expected to come from your toolchain file")
    endif()

    tools_find_simple(GCOV_PATH "${COVERAGE_ANALYZER_TOOL}")
    tools_find_simple(CPPFILT "${CMAKE_CPPFILT}") # NOTE: This line asserts c++filt presence (needed by genhtml --demangle-cpp)

    execute_process(
        COMMAND ${LCOV_PATH} --version
        RESULT_VARIABLE exit_code
        OUTPUT_VARIABLE output
        ERROR_VARIABLE error
    )

    if(NOT exit_code EQUAL 0)
        print_fatal_error("Detecting lcov version failed: ${output} ${error}")
    endif()

    string(REGEX REPLACE "lcov: LCOV version ([0-9.]+).*" "\\1" lcov_version "${output}")

    if(NOT lcov_version)
        print_fatal_error("Unexpected lcov version string: ${output}")
    endif()

    set(LCOV_PATH "${LCOV_PATH}" PARENT_SCOPE)
    set(LCOV_VERSION ${lcov_version} PARENT_SCOPE)

    set(LCOV "${LCOV_PATH}"
        --base-directory "${CMAKE_SOURCE_DIR}"
        --directory "${CMAKE_BINARY_DIR}"
        --gcov-tool "${GCOV_PATH}"
        --rc lcov_branch_coverage=1
        --no-external
        --quiet
        PARENT_SCOPE
    )

    set(GENHTML "${GENHTML_PATH}"
        --prefix "${CMAKE_SOURCE_DIR}"
        --demangle-cpp
        --legend
        --show-details
        --num-spaces 4
        PARENT_SCOPE
    )

    set(LCOV_COBERTURA "${LCOV_COBERTURA_PATH}"
        --base-dir "${CMAKE_SOURCE_DIR}"
        --demangle
        PARENT_SCOPE
    )
endfunction(coverage_lcov_find_tools)

# Adds lcov coverage support
# Remark: invoke this function in scope common to all usages (e.g. on the project declaration level)
# Remark: requires presence of COVERAGE_ANALYZER_TOOL variable set to gcov/llvm-cov/etc by the toolchain file
macro(coverage_lcov_support_enable)
    cmake_parse_arguments(ARGS
        ""
        ""
        ""
        ${ARGN}
    )

    if(COVERAGE_TOOL)
        print_fatal_error("Only one coverage tool should be used at once. lcov conflicts with ${COVERAGE_TOOL}")
    endif()

    if(BUILD_SUBTYPE STREQUAL "coverage" AND CMAKE_SYSTEM_NAME STREQUAL "Linux")
        set(COVERAGE_SUPPORT 1)
        set(COVERAGE_TOOL "lcov")

        coverage_lcov_find_tools()

        set(COVERAGE_INTERNAL_DIRECTORY "${COVERAGE_WORKSPACE_DIRECTORY}/lcov_internal")
        set(COVERAGE_LCOV_VERSION_WITH_EXCLUDES "1.14")

        function(coverage_lcov_get_excluded_sources_arguments out_arguments excluded_sources)
            if(LCOV_VERSION VERSION_GREATER_EQUAL "${COVERAGE_LCOV_VERSION_WITH_EXCLUDES}")
                foreach(excluded_source ${excluded_sources})
                    set(excluded_sources_arguments ${excluded_sources_arguments} --exclude "${excluded_source}")
                endforeach()
            endif()
            set("${out_arguments}" ${excluded_sources_arguments} PARENT_SCOPE)
        endfunction(coverage_lcov_get_excluded_sources_arguments)

        function(coverage_lcov_get_exclude_command out_command tracefile excluded_sources)
            set(tracefile_unfiltered "${tracefile}.unfiltered")
            set(exclude_command
                COMMAND ${CMAKE_COMMAND} -E rename "${tracefile}" "${tracefile_unfiltered}"
                COMMAND ${LCOV}
                    --output-file "${tracefile}"
                    --remove "${tracefile_unfiltered}" ${excluded_sources}
                COMMAND ${CMAKE_COMMAND} -E remove -f "${tracefile_unfiltered}"
                PARENT_SCOPE
            )
        endfunction(coverage_lcov_get_exclude_command)

        function(coverage_get_command_baseline out_command out_dependees out_tracefiles excluded_sources)
            set(tracefile "${COVERAGE_INTERNAL_DIRECTORY}/tracefile_baseline.txt")

            coverage_lcov_get_excluded_sources_arguments(excluded_sources_arguments "${excluded_sources}")

            if(NOT excluded_sources_arguments)
                coverage_lcov_get_exclude_command(exclude_command "${tracefile}" "${excluded_sources}")
            endif()

            set(${out_command}
                COMMAND ${CMAKE_COMMAND} -E remove_directory "${COVERAGE_INTERNAL_DIRECTORY}"
                COMMAND ${CMAKE_COMMAND} -E make_directory "${COVERAGE_INTERNAL_DIRECTORY}"
                COMMAND ${LCOV}
                    --zerocounters
                COMMAND ${LCOV}
                    --capture
                    --initial
                    --output-file "${tracefile}"
                    --test-name "baseline"
                    ${excluded_sources_arguments}
                ${exclude_command}
                PARENT_SCOPE
            )
            set("${out_tracefiles}" "${tracefile}" PARENT_SCOPE)
            set("${out_dependees}" "${COVERAGE_PLUGIN_LCOV_DEPFILE}" PARENT_SCOPE)
        endfunction(coverage_get_command_baseline)

        function(coverage_get_command_capture out_command out_dependees out_tracefiles excluded_sources tag)
            set(tracefile "${COVERAGE_INTERNAL_DIRECTORY}/tracefile_capture_${tag}.txt")

            coverage_lcov_get_excluded_sources_arguments(excluded_sources_arguments "${excluded_sources}")

            if(NOT excluded_sources_arguments)
                coverage_lcov_get_exclude_command(exclude_command "${tracefile}" "${excluded_sources}")
            endif()

            set(${out_command}
                COMMAND ${CMAKE_COMMAND} -E make_directory "${COVERAGE_INTERNAL_DIRECTORY}"
                COMMAND ${LCOV}
                    --capture
                    --output-file "${tracefile}"
                    --test-name "${tag}"
                    ${excluded_sources_arguments}
                ${exclude_command}
                COMMAND ${LCOV}
                    --zerocounters
                PARENT_SCOPE
            )
            set("${out_tracefiles}" "${tracefile}" PARENT_SCOPE)
            set("${out_dependees}" "${COVERAGE_PLUGIN_LCOV_DEPFILE}" PARENT_SCOPE)
        endfunction(coverage_get_command_capture)

        function(coverage_get_command_render out_command out_byproducts baseline tracefiles excluded_sources)
            set(tracefile_summary "${COVERAGE_INTERNAL_DIRECTORY}/tracefile_summary.txt")
            set(run_lcov_merge_tracefiles "${FRAMEWORK_LIB_PATH}/extras/scripts/run_lcov_merge_tracefiles.cmake")
            set(run_lcov_summarize_tracefiles "${FRAMEWORK_LIB_PATH}/extras/scripts/run_lcov_summarize_tracefiles.cmake")
            set(run_renderer_for_human "${FRAMEWORK_LIB_PATH}/extras/scripts/run_genhtml.cmake")
            set(run_renderer_for_cobertura "${FRAMEWORK_LIB_PATH}/extras/scripts/run_lcov_cobertura.cmake")

            # NOTE: Calling CMake requires list separator escaping
            get_string_from_list(arg_lcov "${LCOV}" "$<SEMICOLON>")
            get_string_from_list(arg_tracefiles "${tracefiles}" "$<SEMICOLON>")
            get_string_from_list(arg_renderer_for_human "${GENHTML}" "$<SEMICOLON>")
            get_string_from_list(arg_renderer_for_cobertura "${LCOV_COBERTURA}" "$<SEMICOLON>")

            set(${out_command}
                COMMAND ${CMAKE_COMMAND} -E make_directory "${COVERAGE_INTERNAL_DIRECTORY}"
                COMMAND ${CMAKE_COMMAND} -E remove_directory "${COVERAGE_REPORTS_DIRECTORY}"
                COMMAND ${CMAKE_COMMAND} -E make_directory "${COVERAGE_REPORTS_DIRECTORY}"
                COMMAND ${CMAKE_COMMAND} # NOTE: Using a wrapper script, as bare lcov rejects empty tracefiles
                    "-DLCOV=${arg_lcov}"
                    "-DFRAMEWORK_LIB_PATH=${FRAMEWORK_LIB_PATH}"
                    "-DOUTPUT_FILE=${tracefile_summary}"
                    "-DTRACEFILES=${arg_tracefiles}"
                    -P "${run_lcov_merge_tracefiles}"
                COMMAND ${CMAKE_COMMAND} # NOTE: Using a wrapper script to discover tests, which truly completed
                    "-DLCOV=${LCOV_PATH}" # NOTE: Using raw LCOV to strip the "--silent" arg
                    "-DFRAMEWORK_LIB_PATH=${FRAMEWORK_LIB_PATH}"
                    "-DOUTPUT_DIRECTORY=${COVERAGE_REPORTS_DIRECTORY}"
                    "-DTRACEFILES=${arg_tracefiles}$<SEMICOLON>${tracefile_summary}"
                    -P "${run_lcov_summarize_tracefiles}"
                COMMAND ${CMAKE_COMMAND}
                    "-DRENDERER=${arg_renderer_for_human}"
                    "-DFRAMEWORK_LIB_PATH=${FRAMEWORK_LIB_PATH}"
                    "-DOUTPUT_DIRECTORY=${COVERAGE_REPORTS_DIRECTORY}"
                    "-DRENDERING=index.html"
                    "-DBASELINE=${baseline}"
                    "-DTRACEFILES=${arg_tracefiles}"
                    "-DTRACEFILE_SUMMARY=${tracefile_summary}"
                    -P "${run_renderer_for_human}"
                COMMAND ${CMAKE_COMMAND}
                    "-DRENDERER=${arg_renderer_for_cobertura}"
                    "-DFRAMEWORK_LIB_PATH=${FRAMEWORK_LIB_PATH}"
                    "-DOUTPUT_DIRECTORY=${COVERAGE_REPORTS_DIRECTORY}"
                    "-DRENDERING=index.xml"
                    "-DBASELINE=${baseline}"
                    "-DTRACEFILES=${arg_tracefiles}"
                    "-DTRACEFILE_SUMMARY=${tracefile_summary}"
                    -P "${run_renderer_for_cobertura}"
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
endmacro(coverage_lcov_support_enable)
