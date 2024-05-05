include_guard(GLOBAL)

include(get)

set(COVERAGE_WORKSPACE_DIRECTORY "${TESTING_TEST_REPORTS_DIRECTORY}/coverage")
set(COVERAGE_REPORTS_DIRECTORY "${COVERAGE_WORKSPACE_DIRECTORY}/report")

# Instantiate hardware-specific project traversal and processing
macro(coverage_instatiate)
    get_is_hardware_real(is_hardware_real)

    if(is_hardware_real AND BUILD_SUBTYPE STREQUAL "coverage")
        include(coverage-enabled)
    else()
        include(coverage-disabled)
    endif()
endmacro(coverage_instatiate)
