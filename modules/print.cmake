include_guard(GLOBAL)

include(colors)

# Prints anything you desire as fatal
# In: anything
macro(print_fatal_error)
    message(FATAL_ERROR "${ColorBoldRed}FATAL: ${ARGN}${ColorReset}")
endmacro (print_fatal_error)

# Prints anything you desire in as a warning
# In: anything
macro(print_warning)
    message(WARNING "${ColorBoldGreen}WARNING: ${ARGN}${ColorReset}")
endmacro(print_warning)

# Prints anything you desire
# In: anything
macro(print_anything)
    message("${ColorGreen}DIAGNOSTICS: ${ARGN}${ColorReset}")
endmacro(print_anything)

# Prints all include directories added to current target
# In: tag to be added to current entry, e.g. print_all_include_paths("point 1")
macro(print_all_include_paths)
    message("${ColorGreen}DIAGNOSTICS: ${ARGN}: ALL_INCLUDE_PATHS: ${ALL_INCLUDE_PATHS}${ColorReset}")
endmacro(print_all_include_paths)

# Prints all source files added to current target
# In: tag to be added to current entry, e.g. print_all_source_files("point 1")
macro(print_all_source_files)
    message("${ColorGreen}DIAGNOSTICS: ${ARGN}: ALL_SOURCE_FILES: ${ALL_SOURCE_FILES}${ColorReset}")
endmacro(print_all_source_files)

# Prints all user interface files added to current target
# In: tag to be added to current entry, e.g. print_all_user_interface_files("point 1")
macro(print_all_user_interface_files)
    message("${ColorGreen}DIAGNOSTICS: ${ARGN}: ALL_USER_INTERFACE_FILES: ${ALL_USER_INTERFACE_FILES}${ColorReset}")
endmacro(print_all_user_interface_files)

# Prints all resource files added to current target
# In: tag to be added to current entry, e.g. print_all_resource_files("point 1")
macro(print_all_resource_files)
    message("${ColorGreen}DIAGNOSTICS: ${ARGN}: ALL_RESOURCE_FILES: ${ALL_RESOURCE_FILES}${ColorReset}")
endmacro(print_all_resource_files)

# Prints all translation files added to current target
# In: tag to be added to current entry, e.g. print_all_translation_files("point 1")
macro(print_all_translation_files)
    message("${ColorGreen}DIAGNOSTICS: ${ARGN}: ALL_TRANSLATION_FILES: ${ALL_TRANSLATION_FILES}${ColorReset}")
endmacro(print_all_translation_files)

# Prints all subdirectory targets added to current target
# In: tag to be added to current entry, e.g. print_all_subdirectory_targets("point 1")
macro(print_all_subdirectory_targets)
    message("${ColorGreen}DIAGNOSTICS: ${ARGN}: ALL_SUBDIRECTORY_TARGETS: ${ALL_SUBDIRECTORY_TARGETS}${ColorReset}")
endmacro(print_all_subdirectory_targets)

# Prints all dependencies of current target
# In: tag to be added to current entry, e.g. print_all_dependencies("point 1")
macro(print_all_dependencies)
    message("${ColorGreen}DIAGNOSTICS: ${ARGN}: ALL_DEPENDENCIES: ${ALL_DEPENDENCIES}${ColorReset}")
endmacro(print_all_dependencies)

# Prints all properties of given target
# In: target Inspected target
function(print_target_properties target)
    execute_process(COMMAND ${CMAKE_COMMAND} --help-property-list OUTPUT_VARIABLE CMAKE_PROPERTY_LIST)

    string(REGEX REPLACE ";" "\\\\;" CMAKE_PROPERTY_LIST "${CMAKE_PROPERTY_LIST}")
    string(REGEX REPLACE "\n" ";" CMAKE_PROPERTY_LIST "${CMAKE_PROPERTY_LIST}")

    if(NOT TARGET ${target})
        print_fatal_error("No target named '${target}'")
        return()
    endif()

    foreach (prop ${CMAKE_PROPERTY_LIST})
        string(REPLACE "<CONFIG>" "${CMAKE_BUILD_TYPE}" prop ${prop})

        if(prop STREQUAL "LOCATION" OR prop MATCHES "^LOCATION_" OR prop MATCHES "_LOCATION$")
            continue()
        endif()

        get_property(propval TARGET ${target} PROPERTY ${prop} SET)
        if(propval)
            get_target_property(propval ${target} ${prop})
            message("${ColorGreen}DIAGNOSTICS: target: '${target}' property: '${prop}' value: '${propval}'${ColorReset}")
        endif()
    endforeach(prop)
endfunction(print_target_properties)
