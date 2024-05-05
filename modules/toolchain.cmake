include_guard(GLOBAL)

include(print)
include(tools)

# Adds a hardware name to known and allowed hardware names
macro(toolchain_register_hardware_name hardware_name)
    set(target_hardware_names
        "auto"
        "${TARGET_HARDWARE_NAMES}"
        "${hardware_name}"
    )
    list(REMOVE_ITEM target_hardware_names "")
    list(REMOVE_DUPLICATES target_hardware_names)
    set(TARGET_HARDWARE_NAMES "${target_hardware_names}" PARENT_SCOPE)
endmacro(toolchain_register_hardware_name)

# Adds a toolchain type name to known and allowed toolchain names
macro(toolchain_register_toolchain_type_name toolchain_type_name)
    set(toolchain_type_names
        "${TOOLCHAIN_TYPE_NAMES}"
        "${toolchain_type_name}"
    )
    list(REMOVE_ITEM toolchain_type_names "")
    list(REMOVE_DUPLICATES toolchain_type_names)
    set(TOOLCHAIN_TYPE_NAMES "${toolchain_type_names}" PARENT_SCOPE)
endmacro(toolchain_register_toolchain_type_name)

#
# In: Named argument FOR_HOST_HARDWARE - subkey specifying the machine you're building on
function(toolchain_define)
    cmake_parse_arguments(VALUE
        ""
        "DEFINITIONS_DIRECTORY"
        ""
        ${ARGN}
    )

    set(TOOLCHAIN_DEFINITIONS_DIRECTORY ${VALUE_DEFINITIONS_DIRECTORY} PARENT_SCOPE)
endfunction(toolchain_define)

# Sets a target to toolchain mapping. The ${toolchain}.cmake must exist in the 'toolchains' folder
# In: Named argument FOR_HOST_HARDWARE - subkey specifying the machine you're building on
# In: Named argument FOR_TARGET_HARDWARE - subkey specifying the machine you're building for
# In: Named argument FOR_TOOLCHAIN_TYPE - subkey specifying the toolchain label you want to use
# In: Named argument WITH_FILE - toolchain filename base to be used as CMAKE_TOOLCHAIN_FILE for the composite key above
function(toolchain_configure)
    cmake_parse_arguments(VALUE
        ""
        "FOR_HOST_HARDWARE;FOR_TARGET_HARDWARE;FOR_TOOLCHAIN_TYPE;WITH_FILE"
        ""
        ${ARGN}
    )

    set(toolchain_key
        "TOOLCHAIN_ON_${VALUE_FOR_HOST_HARDWARE}_FOR_${VALUE_FOR_TARGET_HARDWARE}_WITH_${VALUE_FOR_TOOLCHAIN_TYPE}"
    )

    set(${toolchain_key} ${VALUE_WITH_FILE} PARENT_SCOPE)

    toolchain_register_hardware_name(${VALUE_FOR_HOST_HARDWARE})
    toolchain_register_hardware_name(${VALUE_FOR_TARGET_HARDWARE})
    toolchain_register_toolchain_type_name(${VALUE_FOR_TOOLCHAIN_TYPE})
endfunction(toolchain_configure)

# Returns the toolchain name previously registered with toolchain_configure()
# In: host_hardware - subkey specifying the machine you're building on
# In: target_hardware - subkey specifying the machine you're building for
# In: toolchain_type - subkey specifying the toolchain label you want to use
# Out: toolchain_filename - toolchain filename base to be used as CMAKE_TOOLCHAIN_FILE for the composite key above
function(toolchain_get toolchain_filename host_hardware target_hardware toolchain_type)
    set(toolchain_key "${TOOLCHAIN_ON_${host_hardware}_FOR_${target_hardware}_WITH_${toolchain_type}}")

    if(NOT toolchain_key)
        print_fatal_error("Toolchain not defined for ${host_hardware}/${target_hardware}/${toolchain_type}. Use 'toolchain_configure()'")
    endif()

    set(${toolchain_filename} "${toolchain_key}.cmake" PARENT_SCOPE)
endfunction(toolchain_get)

# Returns the name of the current host operating system (i.e. the one you're building on)
# Out: result_name - Normalised name
function(toolchain_host_os_name result_name)
    cmake_host_system_information(RESULT os QUERY OS_NAME)
    string(TOLOWER "${os}" os)
    set(${result_name} "${os}" PARENT_SCOPE)
endfunction(toolchain_host_os_name)

# Returns the name of the current host platform name (i.e. the one you're building on)
# Out: result_name - Normalised name
function(toolchain_host_platform_name result_name)
    cmake_host_system_information(RESULT platform QUERY OS_PLATFORM)
    string(TOLOWER "${platform}" platform)
    set(${result_name} "${platform}" PARENT_SCOPE)
endfunction(toolchain_host_platform_name)

# Returns the name of the current host hardware (i.e. the one you're building on)
# Out: result_name - Normalised name
function(toolchain_host_hardware_name result_name)
    toolchain_host_os_name(host_os)
    toolchain_host_platform_name(host_platform)
    set(${result_name} "${host_os}_${host_platform}" PARENT_SCOPE)
endfunction(toolchain_host_hardware_name)

# Returns the path to the sanitizer library for the current toolchain
# Out: sanitizer_library - discovered library path
# In: sanitizer_library_discovery_option - toolchain-specific compiler option set in the toolchain file
function(toolchain_discover_sanitizer_library sanitizer_library sanitizer_library_discovery_option)
    set(library)
    if(sanitizer_library_discovery_option)
        execute_process(
            COMMAND ${CMAKE_CXX_COMPILER} "${sanitizer_library_discovery_option}"
            RESULT_VARIABLE exit_code
            OUTPUT_VARIABLE library
            ERROR_VARIABLE errors
        )

        if(exit_code)
            print_fatal_error("Discovering sanitizer library failed: ${exit_code} ${errors}")
        endif()

        string(STRIP ${library} library)
    endif()

    set(${sanitizer_library} ${library} PARENT_SCOPE)
endfunction(toolchain_discover_sanitizer_library)
