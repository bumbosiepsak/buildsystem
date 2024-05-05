include_guard(GLOBAL)

include(print)
include(tools)

function(coverage_opencppcoverage_find_tools)
    tools_find_simple(OPENCPPCOVERAGE_PATH OpenCppCoverage.exe)

    set(OPENCPPCOVERAGE
        "${OPENCPPCOVERAGE_PATH}"
        PARENT_SCOPE
    )
endfunction(coverage_opencppcoverage_find_tools)

# Adds OpenCppCoverage coverage support
# Remark: invoke this function in scope common to all usages (e.g. on the project declaration level)
macro(coverage_opencppcoverage_support_enable)
    cmake_parse_arguments(ARGS
        ""
        ""
        ""
        ${ARGN}
    )

    if(COVERAGE_TOOL)
        print_fatal_error("Only one coverage tool should be used at once. opencppcoverage conflicts with ${COVERAGE_TOOL}")
    endif()

    if(BUILD_SUBTYPE STREQUAL "coverage" AND CMAKE_SYSTEM_NAME STREQUAL "Windows")
        set(COVERAGE_SUPPORT 1)
        set(COVERAGE_TOOL "opencppcoverage")

        coverage_opencppcoverage_find_tools()

        function(coverage_get_command_baseline)
        endfunction(coverage_get_command_baseline)

        function(coverage_get_command_capture)
        endfunction(coverage_get_command_capture)

        function(coverage_get_command_render)
        endfunction(coverage_get_command_render)
    endif()
endmacro(coverage_opencppcoverage_support_enable)
