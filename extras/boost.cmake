include_guard(GLOBAL)

include(get)
include(print)

function(boost_validate_for_quirks)
    set(consequences "Detecting Boost will most likely stumble - revise your toolchain file")

    if(NOT CMAKE_CXX_COMPILER_ID)
        print_warning("CMAKE_CXX_COMPILER_ID not defined. ${consequences}")
    endif()
    if(NOT CMAKE_CXX_COMPILER_VERSION)
        print_warning("CMAKE_CXX_COMPILER_VERSION not defined. ${consequences}")
    endif()
    if(MSVC AND NOT MSVC_VERSION)
        print_warning("MSVC_VERSION not defined. ${consequences}")
    endif()
endfunction(boost_validate_for_quirks)

function(boost_define_directives directives)
    if(directives)
        list(LENGTH directives directives_length)
        math(EXPR directives_length "${directives_length}-1")

        foreach(directive_name_index RANGE 0 ${directives_length} 2)
            math(EXPR directive_value_index "${directive_name_index}+1")

            if(directive_value_index GREATER directives_length)
                print_fatal_error("Expecting an even amount of Boost DIRECTIVES (key/value pairs)")
            endif()

            list(GET directives ${directive_name_index} directive_name)
            list(GET directives ${directive_value_index} directive_value)

            set("${directive_name}" "${directive_value}" CACHE INTERNAL "FindBoost directive" FORCE)
        endforeach()
    endif()
endfunction(boost_define_directives)

function(boost_strip_component_prefixes out_components components)
    if(NOT components)
        print_fatal_error("Expecting a non-empty COMPONENTS list of Boost libraries")
    endif()

    foreach(component ${components})
        string(REGEX REPLACE "^(Boost::)?(.+)" "\\2" component "${component}")
        set(stripped_components ${stripped_components} "${component}")
    endforeach()

    set("${out_components}" ${stripped_components} PARENT_SCOPE)
endfunction(boost_strip_component_prefixes)


# Enables Boost support for given sub-packages
# In COMPONENTS: list of required Boost components (e.g. system, serialization etc.)
# In DIRECTIVES: list of key/value pairs controlling the discovery process (see docs of FindBoost.cmake)
# Remark: Linking against non-header-only Boost libs required via imported targets (e.g. Boost::system, Boost::serialization etc.)
# Remark: invoke this function in scope common to all usages (e.g. on the project declaration level)
macro(boost_support_enable)
    cmake_parse_arguments(ARGS
        ""
        ""
        "COMPONENTS;DIRECTIVES"
        ${ARGN}
    )

    get_is_hardware_real(is_hardware_real)

    if(is_hardware_real)
        set(BOOST_SUPPORT 1)

        boost_validate_for_quirks()
        boost_strip_component_prefixes(components "${ARGS_COMPONENTS}")
        boost_define_directives("${ARGS_DIRECTIVES}")

        find_package(Boost REQUIRED COMPONENTS ${components})

        if(${Boost_VERSION_STRING} VERSION_LESS "1.64")
            set(INCLUDE_WHAT_YOU_USE_MAPPING_FILES ${INCLUDE_WHAT_YOU_USE_MAPPING_FILES}
                "include-what-you-use/boost-all-private.imp"
                "include-what-you-use/boost-all.imp"
            )
        else()
            set(INCLUDE_WHAT_YOU_USE_MAPPING_FILES ${INCLUDE_WHAT_YOU_USE_MAPPING_FILES}
                "include-what-you-use/boost-1.64-all.imp"
                "include-what-you-use/boost-1.64-all-private.imp"
            )
        endif()
    endif()
endmacro(boost_support_enable)
