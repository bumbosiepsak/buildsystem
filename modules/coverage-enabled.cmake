include_guard(GLOBAL)

include(dict)

set(COVERAGE_MODULE_DEPFILE ${CMAKE_CURRENT_LIST_FILE})
set(COVERAGE_BASELINE_DEPFILE "coverage_baseline.d")

# Supplementary -------------------------------------------------------------

function(coverage_add_capture_tags)
    dict(APPEND COVERAGE CAPTURE_TAGS ${ARGN})
endfunction(coverage_add_capture_tags)

macro(coverage_get_capture_tags tags)
    dict(GET COVERAGE CAPTURE_TAGS ${tags})
endmacro(coverage_get_capture_tags)

function(coverage_add_excluded_sources)
    dict(APPEND COVERAGE EXCLUDED_SOURCES ${ARGN})
endfunction(coverage_add_excluded_sources)

macro(coverage_get_excluded_sources files)
    dict(GET COVERAGE EXCLUDED_SOURCES ${files})
endmacro(coverage_get_excluded_sources)

macro(coverage_get_capture_target_name out_target_name tag)
    set(${out_target_name} coverage_capture_${tag})
endmacro(coverage_get_capture_target_name)

macro(coverage_get_capture_depfile out_depfile tag)
    set(${out_depfile} "coverage_capture_${tag}.d")
endmacro(coverage_get_capture_depfile)

function(coverage_define_baseline_target)
    add_custom_command(
        COMMENT "Coverage: capturing baseline"
        OUTPUT "${COVERAGE_BASELINE_DEPFILE}"
        VERBATIM
    )
    add_custom_target(coverage_baseline
        DEPENDS
            "${COVERAGE_BASELINE_DEPFILE}"
            "${COVERAGE_MODULE_DEPFILE}"
    )
endfunction(coverage_define_baseline_target)

function(coverage_define_render_target)
    coverage_get_excluded_sources(excluded_sources)

    coverage_get_capture_tags(tags)

    foreach(tag ${tags})
        coverage_get_capture_target_name(coverage_capture "${tag}")

        coverage_get_command_capture(
            capture_command
            dependees
            tracefiles
            "${excluded_sources}"
            "${tag}"
        )

        coverage_get_capture_depfile(coverage_capture_depfile "${tag}")

        set(all_tracefiles ${all_tracefiles} ${tracefiles})
        set(all_capture_depfiles ${all_capture_depfiles} "${coverage_capture_depfile}")

        add_custom_command(
            COMMENT "Coverage: capturing counters"
            OUTPUT "${coverage_capture_depfile}"
            BYPRODUCTS ${tracefiles}
            ${capture_command}
            COMMAND ${CMAKE_COMMAND} -E touch "${coverage_capture_depfile}"
            DEPENDS ${dependees}
            VERBATIM
            APPEND
        )
    endforeach()

    coverage_get_command_baseline(
        baseline_command
        baseline_dependees
        baseline_tracefile
        "${excluded_sources}"
    )

    add_custom_command(
        OUTPUT "${COVERAGE_BASELINE_DEPFILE}"
        BYPRODUCTS ${baseline_tracefile}
        COMMAND ${CMAKE_COMMAND} -E remove -f ${baseline_tracefile} ${all_tracefiles}
        ${baseline_command}
        COMMAND ${CMAKE_COMMAND} -E touch "${COVERAGE_BASELINE_DEPFILE}"
        DEPENDS ${baseline_dependees}
        VERBATIM
        APPEND
    )

    coverage_get_command_render(
        render_command
        byproducts
        "${baseline_tracefile}"
        "${all_tracefiles}"
        "${excluded_sources}"
    )

    add_custom_target(coverage_render
        COMMENT "Coverage: rendering reports"
        BYPRODUCTS ${byproducts}
        ${render_command}
        VERBATIM
    )

    add_dependencies(summarize coverage_render)

    set_property(TARGET coverage_render
        APPEND PROPERTY ADDITIONAL_CLEAN_FILES ${byproducts}
    )

    # NOTE: Defined here, as all necessary data is already computed
    add_custom_target(coverage_clean
        COMMENT "Coverage: cleaning"
        COMMAND ${CMAKE_COMMAND} -E remove_directory "${COVERAGE_WORKSPACE_DIRECTORY}" # NOTE: Brutal, yet effective
        COMMAND ${CMAKE_COMMAND} -E remove -f
            "${COVERAGE_BASELINE_DEPFILE}"
            "${coverage_render_depfile}"
            ${all_capture_depfiles}
        VERBATIM
    )
endfunction(coverage_define_render_target)

# Public --------------------------------------------------------------------

# Adds coverage capture targets for their companion driver test targets (run_utest, run_mtest, etc).
# Each run of such target results in a capture action, which adds a statistics page to the final report
# Out: out_name name of this target needed as a dependency of its driver target
# In: tag name/tag to base this target name on (must be globally unique)
function(coverage_define_capture_target out_name tag)
    if(COVERAGE_SUPPORT)
        coverage_add_capture_tags("${tag}")

        coverage_get_capture_target_name(coverage_capture "${tag}")
        coverage_get_capture_depfile(coverage_capture_depfile "${tag}")

        add_custom_command(
            COMMENT "Coverage: capturing counters"
            OUTPUT "${coverage_capture_depfile}"
            VERBATIM
        )
        add_custom_target(${coverage_capture}
            DEPENDS
                "${coverage_capture_depfile}"
                "${COVERAGE_BASELINE_DEPFILE}"
                "${COVERAGE_MODULE_DEPFILE}"
        )
        add_dependencies(${coverage_capture} coverage_baseline)

        set(${out_name} ${coverage_capture} PARENT_SCOPE)
    endif()
endfunction(coverage_define_capture_target)

# Excludes source files from the coverage report
# In: ARGV Excluded source file paths, relative to current list directory
function(coverage_exclude_files)
    foreach(file ${ARGN})
        set(excluded_sources "${excluded_sources}" "${CMAKE_CURRENT_LIST_DIR}/${file}")
    endforeach()
    coverage_add_excluded_sources(${excluded_sources})
endfunction(coverage_exclude_files)

# Module startup interface --------------------------------------------------

function(coverage_initialize)
    dict(COVERAGE)
    coverage_define_baseline_target()
endfunction(coverage_initialize)

function(coverage_finalize)
    coverage_define_render_target()
endfunction(coverage_finalize)
