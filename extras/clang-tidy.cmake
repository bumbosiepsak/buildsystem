include_guard(GLOBAL)

include(print)
include(tools)

# Enables Clang-Tidy support
# In ENABLED: enables Clang-Tidy if set to true (e.g. for given build configuration)
# In OPTIONS: list of options passed to Clang-Tidy
# In VERSION: optionally sets Clang-Tidy version
# Remark: It might be most convenient to pass configuration via the default .clang-tidy file
# Remark: invoke this function in scope common to all usages (e.g. on the project declaration level)
macro(clang_tidy_support_enable)
    cmake_parse_arguments(ARGS
        ""
        "ENABLED;VERSION"
        "OPTIONS"
        ${ARGN}
    )

    if(ARGS_ENABLED)
        tools_find_simple(CLANG_TIDY
            clang-tidy-${ARGS_VERSION}
            clang-tidy
            clang-tidy-${ARGS_VERSION}.exe
            clang-tidy.exe
        )

        if(NOT CMAKE_C_CLANG_TIDY)
            set(CMAKE_C_CLANG_TIDY ${CLANG_TIDY} ${ARGS_OPTIONS})
        endif()

        if(NOT CMAKE_CXX_CLANG_TIDY)
            set(CMAKE_CXX_CLANG_TIDY ${CLANG_TIDY} ${ARGS_OPTIONS})
        endif()
    endif()
endmacro(clang_tidy_support_enable)
