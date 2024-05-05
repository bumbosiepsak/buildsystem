include_guard(GLOBAL)

cmake_minimum_required(VERSION 3.13.4 FATAL_ERROR)
cmake_policy(VERSION 3.13.4)
cmake_policy(SET CMP0022 NEW) # INTERFACE_LINK_LIBRARIES

set(MAIN_CMAKE_DIR ${CMAKE_CURRENT_LIST_DIR}) # Fetch "real" dir path of current file

include(toolchain)

macro(project_get_is_main is_main)
    if(${CMAKE_CURRENT_LIST_DIR} STREQUAL ${CMAKE_SOURCE_DIR})
        set(${is_main} 1)
    else()
        set(${is_main} 0)
    endif()
endmacro(project_get_is_main)

macro(main_set_project_root_dir)
    set(CURRENT_PROJECT_ROOT_DIR ${CMAKE_SOURCE_DIR})
endmacro(main_set_project_root_dir)

macro(main_set_paths)
    get_filename_component(FRAMEWORK_LIB_PATH "${MAIN_CMAKE_DIR}/.." ABSOLUTE)

    set(FRAMEWORK_LIB_PATH ${FRAMEWORK_LIB_PATH} CACHE PATH "Path to CMake buildsystem framework files" FORCE)

    list(APPEND CMAKE_MODULE_PATH
        "${FRAMEWORK_LIB_PATH}/find-modules"
        "${TOOLCHAIN_DEFINITIONS_DIRECTORY}"  # NOTE: So that toolchain files can include/inherit each other
        "${FRAMEWORK_LIB_PATH}/toolchains"
    )

    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
endmacro(main_set_paths)

macro(main_set_defaults)
    set_property(GLOBAL PROPERTY USE_FOLDERS ON)
    set(INTERNAL_TARGETS_FOLDER "zuletzt_interne_ziele") # Cool, starts with letter "z" to land at the end
endmacro(main_set_defaults)

function(main_load_extras)
    file(GLOB extras_modules "${FRAMEWORK_LIB_PATH}/extras/*.cmake"
        LIST_DIRECTORIES false
    )

    foreach(extras_module ${extras_modules})
        message("-- Loading extra module: '${extras_module}'")
        include("${extras_module}")
    endforeach()
endfunction(main_load_extras)

macro(project name env_sdk_dir)

    main_set_project_root_dir()

    # If this is the main project definition (either run by human or e.g. Yocto)
    project_get_is_main(is_main_project)

    if(is_main_project)
        include(colors)
        include(print)
        include(patch)
        include(tools)
        include(get)
        include(copy)
        include(validate)
        include(commandline)
        include(testing)
        include(coverage)
        include(add)
        include(export)
        include(conventions)
        include(targets)

        main_set_defaults()
        main_set_paths()

        commandline_set_defaults()

        commandline_set_color_output()

        if(env_sdk_dir STREQUAL "IMPLICIT_SDK_DIR")
            commandline_set_build_type(relwithdebinfo) # Release build by default
            commandline_set_toolchain_file("build-with-injected-toolchain.cmake")
        else()
            commandline_set_sdk_dir(${S} ${env_sdk_dir})
            commandline_set_target_hardware(${H})
            commandline_set_toolchain_type(${T})
            commandline_set_build_type(${B})
            commandline_deduce_toolchain_file()
        endif()

        coverage_instatiate()
        add_instatiate()
        conventions_instatiate()
        export_instatiate()

        include("${CMAKE_TOOLCHAIN_FILE}") # NOTE: Needed to populate ENABLED_LANGUAGES
    endif()

    tools_find_all()

    _project(${name} LANGUAGES ${ENABLED_LANGUAGES})

    if(is_main_project)
        main_load_extras()

        toolchain_discover_sanitizer_library(SANITIZER_LIBRARY "${SANITIZER_LIBRARY_DISCOVERY_OPTION}")
        targets_initialize()
        coverage_initialize()
        testing_initialize()
        conventions_initialize()
    endif()
endmacro(project)

macro(project_end)
    project_get_is_main(is_main_project)

    if(is_main_project)
        conventions_finalize()
        testing_finalize()
        coverage_finalize()
        targets_finalize()
    endif()
endmacro(project_end)
