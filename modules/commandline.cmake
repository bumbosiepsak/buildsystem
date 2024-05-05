include_guard(GLOBAL)

include(get)
include(print)
include(toolchain)

function(commandline_force_crosscompiling)
    if(NOT S) # SDK_DIR
        set(S NOTFOUND PARENT_SCOPE)
    endif()
endfunction(commandline_force_crosscompiling)

macro(commandline_set_color_output_default)
    set(COLOR_OUTPUT YES CACHE BOOL "Colored console usage")
endmacro(commandline_set_color_output_default)

macro(commandline_set_color_output)
    if(COLOR_OUTPUT)
        set(ENV{CLICOLOR_FORCE} 1)
    else()
        set(ENV{CLICOLOR} 0)
    endif()
    message("-- Using colors in console output (COLOR_OUTPUT): ${COLOR_OUTPUT}")
endmacro(commandline_set_color_output)

function(commandline_set_generator)
    message("-- Using generator (G): ${CMAKE_GENERATOR}")
endfunction(commandline_set_generator)

macro(commandline_set_sdk_dir_default)
    set(SDK_DIR "/" CACHE PATH "Path to SDK")

    if(NOT S)
        set(S NOTFOUND PARENT_SCOPE)
    endif()
endmacro(commandline_set_sdk_dir_default)

function(commandline_set_sdk_dir sdk_dir env_sdk_dir_name)
    set(env_sdk_dir "$ENV{${env_sdk_dir_name}}") # Needed here due to CMake quirks

    if(sdk_dir) # First try: take from commandline, if given
        if(NOT EXISTS "${sdk_dir}")
            print_fatal_error("Invalid SDK root directory provided via '-DS=...' option: '${sdk_dir}'")
            return()
        endif()
    elseif(env_sdk_dir) # Second try: take from environment, if given
        if(EXISTS "${env_sdk_dir}")
            set(sdk_dir "${env_sdk_dir}")
        else()
            print_fatal_error("Invalid SDK root directory provided via '${env_sdk_dir_name}' environment variable: '${env_sdk_dir}'")
            return()
        endif()
    elseif(EXISTS "${SDK_DIR}") # Third try: take cached
        set(sdk_dir "${SDK_DIR}")
    else()
        print_fatal_error("Unresolved SDK root directory. Provide via '-DS=...' option or '${env_sdk_dir_name}' environment variable")
        return()
    endif()

    set(SDK_DIR "${sdk_dir}" CACHE PATH "Path to SDK" FORCE) # Cache new value

    message("-- Using SDK directory (S|SDK_DIR): '${SDK_DIR}'")
endfunction(commandline_set_sdk_dir)

macro(commandline_set_host_hardware_default)
    toolchain_host_hardware_name(host_hardware)

    set(HOST_HARDWARE ${host_hardware} CACHE STRING "Current host hardware" FORCE) # Cache new value

    message("-- Using host hardware (inferred): ${HOST_HARDWARE}")
endmacro(commandline_set_host_hardware_default)

macro(commandline_set_target_hardware_default)
    list(GET TARGET_HARDWARE_NAMES 0 target_hardware_default)
    set(TARGET_HARDWARE "${target_hardware_default}" CACHE STRING "Target system")
    set_property(CACHE TARGET_HARDWARE PROPERTY STRINGS ${TARGET_HARDWARE_NAMES})

    if(NOT H) # CMake quirks require this
        set(H NOTFOUND PARENT_SCOPE)
    endif()
endmacro(commandline_set_target_hardware_default)

function(commandline_set_target_hardware target_hardware)
    if(target_hardware)
        string(TOLOWER "${target_hardware}" target_hardware)
    else()
        set(target_hardware ${TARGET_HARDWARE}) # Take cached
    endif()

    if("${target_hardware}" STREQUAL "auto")
        set(target_hardware "${HOST_HARDWARE}")
    endif()

    if(NOT "${target_hardware}" IN_LIST TARGET_HARDWARE_NAMES)
        get_string_from_list(target_hardware_names "${TARGET_HARDWARE_NAMES}" "|")
        print_fatal_error("Invalid target hardware (H|TARGET_HARDWARE): '${target_hardware}'. Provide: {${target_hardware_names}}")
        return()
    endif()

    set(TARGET_HARDWARE ${target_hardware} CACHE STRING "Current target hardware" FORCE) # Cache new value

    message("-- Using target hardware (H|TARGET_HARDWARE): ${TARGET_HARDWARE}")
endfunction(commandline_set_target_hardware)

macro(commandline_set_build_type_default)
    set(BUILD_TYPE "debug" CACHE STRING "Build type")
    set_property(CACHE BUILD_TYPE PROPERTY STRINGS
        "debug"
        "release"
        "address"
        "memory"
        "coverage"
        "thread"
        "leak"
        "undefined"
        "relwithdebinfo"
        "minsizerel"
    )

    set(BUILD_SUBTYPE "" CACHE STRING "Build sub-type")
    mark_as_advanced(FORCE BUILD_SUBTYPE)

    if(NOT B) # CMake quirks require this
        set(B NOTFOUND PARENT_SCOPE)
    endif()
endmacro(commandline_set_build_type_default)

function(commandline_set_build_type build_type)
    if(build_type)
        string(TOLOWER "${build_type}" b)
    else()
        set(b ${BUILD_TYPE}) # Take cached
    endif()

    set(build_subtype "")

    if(b STREQUAL "debug")
        set(b_normalised "Debug")
    elseif(b STREQUAL "release")
        set(b_normalised "Release")
    elseif(b STREQUAL "address")
        set(build_subtype ${b})
        set(b_normalised "Debug")
    elseif(b STREQUAL "memory")
        set(build_subtype ${b})
        set(b_normalised "Debug")
    elseif(b STREQUAL "coverage")
        set(build_subtype ${b})
        set(b_normalised "Debug")
    elseif(b STREQUAL "thread")
        set(build_subtype ${b})
        set(b_normalised "Debug")
    elseif(b STREQUAL "leak")
        set(build_subtype ${b})
        set(b_normalised "Debug")
    elseif(b STREQUAL "undefined")
        set(build_subtype ${b})
        set(b_normalised "Debug")
    elseif(b STREQUAL "relwithdebinfo")
        set(b_normalised "RelWithDebInfo")
    elseif(b STREQUAL "minsizerel")
        set(b_normalised "MinSizeRel")
    else()
        get_property(build_types CACHE BUILD_TYPE PROPERTY STRINGS)
        get_string_from_list(build_types "${build_types}" "|")
        print_fatal_error("Invalid build type (B|BUILD_TYPE): '${build_type}'. Provide: {${build_types}}")
        return()
    endif()

    set(BUILD_TYPE ${b} CACHE STRING "Build type" FORCE) # Cache new value
    set(BUILD_SUBTYPE ${build_subtype} CACHE STRING "Build sub-type" FORCE) # Cache new value

    set(CMAKE_BUILD_TYPE ${b_normalised} CACHE STRING "Build type" FORCE)

    message("-- Using build type (B|BUILD_TYPE): ${BUILD_TYPE}")
endfunction(commandline_set_build_type)

macro(commandline_set_toolchain_type_default)
    list(GET TOOLCHAIN_TYPE_NAMES 0 toolchain_type_default)
    set(TOOLCHAIN_TYPE "${toolchain_type_default}" CACHE STRING "Toolchain type")
    set_property(CACHE TOOLCHAIN_TYPE PROPERTY STRINGS ${TOOLCHAIN_TYPE_NAMES})

    if(NOT T) # CMake quirks require this
        set(T NOTFOUND PARENT_SCOPE)
    endif()
endmacro(commandline_set_toolchain_type_default)

function(commandline_set_toolchain_type toolchain_type)
    if(toolchain_type)
        string(TOLOWER "${toolchain_type}" toolchain_type)
    else()
        set(toolchain_type ${TOOLCHAIN_TYPE}) # Take cached
    endif()

    set(TOOLCHAIN_TYPE ${toolchain_type} CACHE STRING "Current toolchain type" FORCE) # Cache new value

    message("-- Using toolchain type (T|TOOLCHAIN_TYPE): ${TOOLCHAIN_TYPE}")
endfunction(commandline_set_toolchain_type)

function(commandline_set_defaults)
    commandline_set_color_output_default()
    commandline_set_generator()
    commandline_set_sdk_dir_default()
    commandline_set_host_hardware_default()
    commandline_set_target_hardware_default()
    commandline_set_toolchain_type_default()
    commandline_set_build_type_default()

    # replace cache var to regular for consistent purpose
    if(DEFINED GENERATE_ONLY)
        set(GENERATE_ONLY ${GENERATE_ONLY} PARENT_SCOPE)
        unset(GENERATE_ONLY CACHE)
    endif()
endfunction(commandline_set_defaults)

function(commandline_set_toolchain_file toolchain_filename)
    set(CMAKE_TOOLCHAIN_FILE "${TOOLCHAIN_DEFINITIONS_DIRECTORY}/${toolchain_filename}")

    if(EXISTS "${CMAKE_TOOLCHAIN_FILE}")
        message("-- Using toolchain file (computed): '${CMAKE_TOOLCHAIN_FILE}'")
    else()
        print_fatal_error("Unimplemented toolchain. Could not find: '${CMAKE_TOOLCHAIN_FILE}'")
        return()
    endif()

    set(CMAKE_TOOLCHAIN_FILE ${CMAKE_TOOLCHAIN_FILE} PARENT_SCOPE)
endfunction(commandline_set_toolchain_file)

function(commandline_deduce_toolchain_file)
    toolchain_get(toolchain_filename ${HOST_HARDWARE} ${TARGET_HARDWARE} ${TOOLCHAIN_TYPE})
    commandline_set_toolchain_file("${toolchain_filename}")

    set(CMAKE_TOOLCHAIN_FILE ${CMAKE_TOOLCHAIN_FILE} PARENT_SCOPE)
endfunction(commandline_deduce_toolchain_file)
