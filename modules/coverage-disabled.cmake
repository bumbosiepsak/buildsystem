include_guard(GLOBAL)

function(coverage_add_excluded_sources)
endfunction(coverage_add_excluded_sources)

function(coverage_define_capture_target)
endfunction(coverage_define_capture_target)

function(coverage_exclude_files)
endfunction(coverage_exclude_files)

function(coverage_initialize)
    add_custom_target(coverage_baseline)
endfunction(coverage_initialize)

function(coverage_finalize)
    add_custom_target(coverage_render
        COMMENT "Coverage: rendering reports"
        COMMAND ${CMAKE_COMMAND} -E echo "FAILED: Coverage reports not present in this build configuration"
        COMMAND ${CMAKE_COMMAND} -E false
    )

    add_custom_target(coverage_clean)
endfunction(coverage_finalize)

