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
        tools_find_simple(CLANG_FORMAT
            clang-format-${ARGS_VERSION}
            clang-format
            clang-format-${ARGS_VERSION}.exe
            clang-format.exe
        )
    endif()
endmacro(clang_format_support_enable)
