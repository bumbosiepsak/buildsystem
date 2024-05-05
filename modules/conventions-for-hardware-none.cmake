include_guard(GLOBAL)

include(get)
include(dict)
include(print)

# Includes files (relative globs) applicable to given convention
function(conventions_include_files convention_name)
    foreach(file ${ARGN})
        dict(APPEND CONVENTIONS "${convention_name}_INCLUDED" "${CMAKE_CURRENT_LIST_DIR}/${file}")
    endforeach()
endfunction(conventions_include_files)

# Excludes files (relative globs) not applicable to given convention
function(conventions_exclude_files convention_name)
    foreach(file ${ARGN})
        dict(APPEND CONVENTIONS "${convention_name}_EXCLUDED" "${CMAKE_CURRENT_LIST_DIR}/${file}")
    endforeach()
endfunction(conventions_exclude_files)

# Excludes files (relative globs) not applicable to all registered conventions
function(conventions_exclude_files_from_all)
    dict(GET CONVENTIONS CONVENTION_NAMES convention_names)
    foreach(convention_name ${convention_names})
        foreach(file ${ARGN})
            dict(APPEND CONVENTIONS "${convention_name}_EXCLUDED" "${CMAKE_CURRENT_LIST_DIR}/${file}")
        endforeach()
    endforeach()
endfunction(conventions_exclude_files_from_all)

# Collects all convention names
function(conventions_register convention_name)
    dict(APPEND CONVENTIONS CONVENTION_NAMES "${convention_name}")
endfunction(conventions_register)

# Sets the convention description
function(conventions_set_description convention_name description)
    dict(SET CONVENTIONS ${convention_name}_DESCRIPTION "${description}")
endfunction(conventions_set_description)

# Defines a new convention
# In: convention_name - name e.g. format_cpp
# In: DESCRIPTION - convention description
# In: FOR_FILES - file globs to be checked
# In: EXCLUDING_FILES - file globs to be excluded from checks
function(conventions_define convention_name)
    cmake_parse_arguments(DETAIL
        ""
        "DESCRIPTION"
        "FOR_FILES;EXCLUDING_FILES"
        ${ARGN}
    )

    conventions_register(${convention_name})
    conventions_include_files(${convention_name} "${DETAIL_FOR_FILES}")
    conventions_exclude_files(${convention_name} "${DETAIL_EXCLUDING_FILES}")
    conventions_set_description(${convention_name} "${DETAIL_DESCRIPTION}")
endfunction(conventions_define)

function(conventions_get_verdict_filename out_filename parent_target_name)
    set("${out_filename}" "${parent_target_name}.txt" PARENT_SCOPE)
endfunction(conventions_get_verdict_filename)

function(conventions_get_reset_verdict_target_name out_target_name parent_target_name)
    set("${out_target_name}" "${parent_target_name}_reset_verdict" PARENT_SCOPE)
endfunction(conventions_get_reset_verdict_target_name)

function(conventions_define_reset_verdict_target parent_target_name)
    conventions_get_reset_verdict_target_name(reset_verdict_target_name ${parent_target_name})
    conventions_get_verdict_filename(verdict_file ${parent_target_name})

    add_custom_target(${reset_verdict_target_name}
        COMMENT "Resetting convention verdict"
        COMMAND ${CMAKE_COMMAND} -E remove -f "${verdict_file}"
    )

    set_property(
        TARGET ${reset_verdict_target_name}
        APPEND PROPERTY ADDITIONAL_CLEAN_FILES "${verdict_file}"
    )
endfunction(conventions_define_reset_verdict_target)

# Defines the target/command for given type/direction and convention
# Out: parent_target_file_dependencies - list of parent target dependencies (of "file" type) this target will append itself to
# In: file - file to be inspected
# In: convention_type - type e.g. apply, check
# In: convention_names - list of convention names to be applied, e.g. "format_cpp;format_space_indents"
function(conventions_define_command parent_target_file_dependencies file convention_type convention_names)
    get_host_friendly_unique_id(target_name "zz" "${convention_type}_${file}")
    set(dependency_file "d/${target_name}.d")

    set(parent_target_name conventions_${convention_type})
    conventions_get_verdict_filename(verdict_file ${parent_target_name})

    add_custom_command(
        OUTPUT "${dependency_file}"
        COMMAND ${PYTHON} "${FRAMEWORK_LIB_PATH}/conventions/run_all.py"
            --type "${convention_type}"
            --names "${convention_names}"
            --file "${CMAKE_SOURCE_DIR}/${file}"
            --output "${CMAKE_CURRENT_BINARY_DIR}/${dependency_file}"
            --verdict "${CMAKE_CURRENT_BINARY_DIR}/${verdict_file}"
        DEPENDS "${file}"
        COMMENT "Running ${parent_target_name} on ${file}"
        VERBATIM
    )

    set(${parent_target_file_dependencies} ${${parent_target_file_dependencies}} "${dependency_file}" PARENT_SCOPE)
endfunction(conventions_define_command)

function(conventions_define_parent_target parent_target_name parent_target_file_dependencies comment)
    conventions_get_reset_verdict_target_name(reset_verdict_target_name ${parent_target_name})
    conventions_get_verdict_filename(verdict_file ${parent_target_name})

    add_custom_target(${parent_target_name}
        COMMENT "${comment}"
        COMMAND ${PYTHON} "${FRAMEWORK_LIB_PATH}/conventions/conventions_verdict.py"
            --verdict "${CMAKE_CURRENT_BINARY_DIR}/${verdict_file}"
        COMMAND ${CMAKE_COMMAND} -E echo "DONE: ${comment}"
        DEPENDS ${parent_target_file_dependencies}
    )

    add_dependencies(${parent_target_name} ${reset_verdict_target_name})
endfunction(conventions_define_parent_target)

function(conventions_serialise_globs out_string indcluded_excluded convention_names)
    foreach(convention_name ${convention_names})
        dict(GET CONVENTIONS "${convention_name}_${indcluded_excluded}" globs)
        get_nested_list_from_list(globs "${globs}")
        set(all_globs "${all_globs}" "${globs}")
    endforeach()
    list(REMOVE_AT all_globs 0)

    set("${out_string}" "${all_globs}" PARENT_SCOPE)
endfunction(conventions_serialise_globs)

function(conventions_resolve_relationships out_relationships)
    dict(GET CONVENTIONS CONVENTION_NAMES convention_names)
    conventions_serialise_globs(globs_included INCLUDED "${convention_names}")
    conventions_serialise_globs(globs_excluded EXCLUDED "${convention_names}")

    execute_process(
        COMMAND ${PYTHON} "${FRAMEWORK_LIB_PATH}/conventions/resolve_relationships.py"
            --source-dir "${CMAKE_SOURCE_DIR}"
            --convention-names "${convention_names}"
            --globs-included "${globs_included}"
            --globs-excluded "${globs_excluded}"
        RESULT_VARIABLE exit_code
        OUTPUT_VARIABLE relationships
        ERROR_VARIABLE exit_message
        ENCODING UTF8
    )

    if(NOT exit_code EQUAL 0)
        print_fatal_error("Resolving conventions relationships failed: ${exit_message}")
    endif()

    set("${out_relationships}" ${relationships} PARENT_SCOPE)
endfunction(conventions_resolve_relationships)

macro(conventions_get_relationship relationship file convention_names)
    get_list_from_nested_list(relationship ${relationship})

    list(GET relationship 0 "${file}")
    list(SUBLIST relationship 1 -1 ${convention_names})
endmacro(conventions_get_relationship)

function(conventions_initialize)
    dict(CONVENTIONS)
endfunction(conventions_initialize)

function(conventions_finalize)
    conventions_define_reset_verdict_target(conventions_apply)
    conventions_define_reset_verdict_target(conventions_check)

    conventions_resolve_relationships(relationships)

    foreach(relationship ${relationships})
        conventions_get_relationship(${relationship} file convention_names)
        conventions_define_command(conventions_apply_file_dependencies "${file}" apply "${convention_names}")
        conventions_define_command(conventions_check_file_dependencies "${file}" check "${convention_names}")
    endforeach()

    conventions_define_parent_target(conventions_apply "${conventions_apply_file_dependencies}" "Conventions application")
    conventions_define_parent_target(conventions_check "${conventions_check_file_dependencies}" "Conventions check")
endfunction(conventions_finalize)
