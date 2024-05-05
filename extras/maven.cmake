include_guard(GLOBAL)

include(get)
include(print)
include(tools)

# Composes a list of options for feeding properties files
function(get_maven_properties_files_options properties_files_options)
    set(options)
    foreach(maven_properties_file ${MAVEN_PROPERTIES_FILES})
        list(APPEND options --properties-file "${maven_properties_file}")
    endforeach()
    set(${properties_files_options} ${options} PARENT_SCOPE)
endfunction(get_maven_properties_files_options)

# Finds the nearest pom.xml file and its related build directory
function(get_maven_pom_xml_file pom_xml_path build_directory)
    set(pom_xml_directory "${CMAKE_CURRENT_LIST_DIR}")
    set(binary_directory "${CMAKE_CURRENT_BINARY_DIR}")

    while(NOT EXISTS "${pom_xml_directory}/pom.xml")
        get_dir_parent(pom_xml_directory "${pom_xml_directory}")
        get_dir_parent(binary_directory "${binary_directory}")

        if("${pom_xml_directory}" STREQUAL "${CMAKE_SOURCE_DIR}")
            print_fatal_error("Could not find the pom.xml file in any parent of: ${CMAKE_CURRENT_LIST_DIR}")
        endif()
    endwhile()

    set(${pom_xml_path} "${pom_xml_directory}/pom.xml" PARENT_SCOPE)
    set(${build_directory} "${binary_directory}" PARENT_SCOPE)
endfunction(get_maven_pom_xml_file pom_xml_path)

# Composes the Maven command base part
function(get_maven_command command)
    get_maven_properties_files_options(properties_files_options)
    get_maven_pom_xml_file(pom_xml_path build_directory)

    if(NOT COLOR_OUTPUT)
        set(color_option "--batch-mode")
    endif()

    set(${command}
        ${PYTHON} "${FRAMEWORK_LIB_PATH}/extras/scripts/run_maven.py"
            --mvn-path "${MVN}"
            --file "${pom_xml_path}"
            --define "buildDirectory=${build_directory}"
            --define "maven.repo.local=${MAVEN_REPOSITORY}"
            ${properties_files_options}
            ${color_option}
        PARENT_SCOPE
    )
endfunction(get_maven_command)

# Adds a local Maven repository in given location
# In repository: disk path to repository location
function(add_maven_repository repository)
    if(NOT EXISTS ${repository})
        file(MAKE_DIRECTORY ${repository})
    endif()

    set(MAVEN_REPOSITORY ${repository} PARENT_SCOPE)
endfunction(add_maven_repository)

macro(add_maven_target name)
    add_target(${name})

    set(MAVEN_PROPERTIES_TARGETS)
    set(MAVEN_PROPERTIES_FILES)

    add_custom_target(${CURRENT_TARGET_MAIN} ALL)
endmacro(add_maven_target)

# Adds a Maven sub-target
# In name: sub-target name
# In maven_stage: defines Maven stage to be associated with this sub-target
# In COMMENT: defines the message printed during sub-target build
# In DEPENDS: adds dependencies of this sub-target
# In OPTIONS: extra Maven options to be used during this sub-target build
function(add_maven_subtarget name maven_stage)
    cmake_parse_arguments(ARGS
        ""
        "COMMENT"
        "DEPENDS;OPTIONS"
        ${ARGN}
    )

    get_split_dependencies("${ARGS_DEPENDS}" target_dependencies file_dependencies)
    get_maven_command(maven_command)
    add_custom_target(${name}
        COMMENT "${ARGS_COMMENT}"
        COMMAND ${maven_command} ${ARGS_OPTIONS} ${maven_stage}
        VERBATIM
        DEPENDS
            ${file_dependencies}
    )

    add_dependencies(${name} ${MAVEN_PROPERTIES_TARGETS} ${target_dependencies})
endfunction(add_maven_subtarget)

# Adds a Maven test target
# In: parent_test_target parent target, reflecting the test type (utest, mtest, ptest etc)
function(add_maven_test_target parent_test_target maven_stage)
    cmake_parse_arguments(ARGS
        ""
        "COMMENT"
        "DEPENDS;OPTIONS"
        ${ARGN}
    )

    add_test_target(${parent_test_target})

    get_maven_command(maven_command)
    add_test_freeform(
        COMMAND ${maven_command} ${ARGS_OPTIONS} ${maven_stage}
        DEPENDS ${ARGS_DEPENDS}
    )
endfunction(add_maven_test_target)

# Adds a Maven properties file (to be consumed by the properties plugin)
# In cmake_template: path to properties file, which can be a CMake template
# Remark: The template is processed twice: once via CMake templating and once via VersionTool templating
function(add_maven_properties cmake_template)
    get_filename_component(properties_basename ${cmake_template} NAME_WE)

    set(properties_configured "${CMAKE_CURRENT_BINARY_DIR}/${properties_basename}-configured.properties")
    set(properties_generated "${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>/${properties_basename}-generated.properties")
    set(properties_new "${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>/${properties_basename}-new.properties")
    set(properties_current "${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>/${properties_basename}.properties")

    configure_file(
        "${cmake_template}"
        "${properties_configured}"
        NEWLINE_STYLE UNIX
        @ONLY
    )

    file(GENERATE
        OUTPUT "${properties_generated}"
        INPUT "${properties_configured}"
    )

    get_host_friendly_unique_id(target_name "zz" "${properties_current}")
    add_custom_target(${target_name}
        COMMENT ${CMAKE_COMMAND} -E echo "Generating the properties file: ${properties_current}"
        COMMAND ${RENDER_VERSION}
            --generated-file "${properties_new}"
            --template-file "${properties_generated}"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different "${properties_new}" "${properties_current}"
        COMMAND ${CMAKE_COMMAND} -E remove -f "${properties_new}"
    )

    set_property(
        TARGET ${target_name}
        APPEND PROPERTY ADDITIONAL_CLEAN_FILES
            "${properties_configured}"
            "${properties_generated}"
            "${properties_new}"
            "${properties_current}"
    )

    set(MAVEN_PROPERTIES_TARGETS ${MAVEN_PROPERTIES_TARGETS} "${target_name}" PARENT_SCOPE)
    set(MAVEN_PROPERTIES_FILES ${MAVEN_PROPERTIES_FILES} "${properties_current}" PARENT_SCOPE)
endfunction(add_maven_properties)

# Enables Maven support
# Remark: invoke this function in scope common to all usages (e.g. on the project declaration level)
macro(maven_support_enable)
    get_is_hardware_real(is_hardware_real)

    if(is_hardware_real)
        set(MAVEN_SUPPORT 1)
        tools_find_simple(MVN mvn mvn.cmd)
    endif()
endmacro(maven_support_enable)
