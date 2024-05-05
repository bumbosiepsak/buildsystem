include_guard(GLOBAL)

include(CMakeParseArguments)

# Adds files to be installed in specified directory
# Remark: regexp can be passed for multiple files
function(export_files export_directory)
    file(GLOB files ${ARGN})
    install(
        FILES ${files}
        DESTINATION ${export_directory}
    )
endfunction()

# Adds directiories (with files inside it) to be installed
# Remark: copies directories tree
# Remark: pattern can be passed, if not all files from dir have to be installed
# Remark: can copy current dir by giving it EXPORT_CURRENT_DIR param
function(export_directories)
    cmake_parse_arguments(EXPORT_DIRECTORIES
        "EXPORT_CURRENT_DIR"
        "DESTINATION"
        "DIRECTORIES;FILE_PATTERNS"
        ${ARGN}
    )

    install(
        DIRECTORY ${EXPORT_DIRECTORIES_DIRECTORIES}
        DESTINATION ${EXPORT_DIRECTORIES_DESTINATION}
        FILES_MATCHING PATTERN ${EXPORT_DIRECTORIES_FILE_PATTERNS}
    )

    if(${EXPORT_DIRECTORIES_EXPORT_CURRENT_DIR})
        export_files(
            ${EXPORT_DIRECTORIES_DESTINATION}
            ${EXPORT_DIRECTORIES_FILE_PATTERNS}
        )
    endif()
endfunction()

# Adds current target to 'install' target
# In: target - target to be exported
# Remark: each target type (lib/binary) can have separate directory to be installed
# Remark: this function also creates script which helps with further import
function(export_target target)
    if(IS_CURRENT_TARGET_ENABLED)
        install(
            TARGETS ${target}
            EXPORT ${target}-config
            RUNTIME DESTINATION sbin
            LIBRARY DESTINATION usr/lib
            ARCHIVE DESTINATION usr/lib
        )
        install(
            EXPORT ${target}-config
            DESTINATION usr/share/cmake/${target}
        )
    endif()
endfunction()
