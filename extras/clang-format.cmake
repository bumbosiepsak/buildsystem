include_guard(GLOBAL)

include(print)
include(tools)

# Enables Clang-Format support
# In ENABLED: enables Clang-Format if set to true (e.g. for given build configuration)
# In OPTIONS: list of options passed to Clang-Format
# In VERSION: optionally sets Clang-Format version
# Remark: It might be most convenient to pass configuration via the default .clang-format file
# Remark: invoke this function in scope common to all usages (e.g. on the project declaration level)
macro(clang_format_support_enable)
    cmake_parse_arguments(ARGS
        ""
        "ENABLED;VERSION"
        "OPTIONS"
        ${ARGN}
    )

    if(ARGS_ENABLED)
        # NOTE: "clang-format" without suffixes needs to be the default for the sake of consumption by scripts
        # and due to its inherent format instability between versions.
        tools_find_simple(CLANG_FORMAT
            clang-format
            clang-format.exe
        )

        if(NOT ${CLANG_FORMAT_VERSION} VERSION_EQUAL ${ARGS_VERSION})
            print_fatal_error("Expecting clang-format version: ${ARGS_VERSION} got: ${CLANG_FORMAT_VERSION}")
        endif()
    endif()
endmacro(clang_format_support_enable)
