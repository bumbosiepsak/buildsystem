include_guard(GLOBAL)

include(print)
include(tools)

set(INCLUDE_WHAT_YOU_USE_DATADIR ${CMAKE_INSTALL_FULL_DATADIR} CACHE PATH "Include-What-You-Use data directory")

function(get_include_what_you_use_options include_what_you_use_options mapping_files)
    set(options
        -Xiwyu --verbose=1
    )

    foreach(mapping_file ${mapping_files})
        if(NOT IS_ABSOLUTE "${mapping_file}")
            set(search_locations
                "${CMAKE_SOURCE_DIR}"
                "${INCLUDE_WHAT_YOU_USE_DATADIR}"
            )
            foreach(search_location ${search_locations})
                if(EXISTS "${search_location}/${mapping_file}")
                    set(mapping_file "${search_location}/${mapping_file}")
                    break()
                endif()
            endforeach()
        endif()

        if(NOT EXISTS "${mapping_file}")
            print_fatal_error("Requested Include-What-You-Use mapping file not found: ${mapping_file}")
        endif()

        list(APPEND options -Xiwyu "--mapping_file=${mapping_file}")
    endforeach()

    set(${include_what_you_use_options} ${options} PARENT_SCOPE)
endfunction(get_include_what_you_use_options)

# Enables Include-What-You-Use support for all targets
# In ENABLED: enables IWYU if set to true (e.g. for given build configuration)
# In MAPPING_FILES: extra mapping files paths. May be relative to project root or cmake/extras/include-what-you-use folder
# In OPTIONS: list of options passed to IWYU
# Remark: invoke this function in scope common to all usages (e.g. on the project declaration level)
macro(include_what_you_use_support_enable)
    cmake_parse_arguments(ARGS
        ""
        "ENABLED"
        "MAPPING_FILES;OPTIONS"
        ${ARGN}
    )

    if(ARGS_ENABLED)
        include(GNUInstallDirs)

        tools_find_simple(INCLUDE_WHAT_YOU_USE include-what-you-use iwyu)

        get_include_what_you_use_options(include_what_you_use_options "${ARGS_MAPPING_FILES}")

        if(NOT CMAKE_C_INCLUDE_WHAT_YOU_USE)
            set(CMAKE_C_INCLUDE_WHAT_YOU_USE ${INCLUDE_WHAT_YOU_USE} ${ARGS_OPTIONS} ${include_what_you_use_options})
        endif()

        if(NOT CMAKE_CXX_INCLUDE_WHAT_YOU_USE)
            set(CMAKE_CXX_INCLUDE_WHAT_YOU_USE ${INCLUDE_WHAT_YOU_USE} ${ARGS_OPTIONS} ${include_what_you_use_options})
        endif()
    endif()
endmacro(include_what_you_use_support_enable)
