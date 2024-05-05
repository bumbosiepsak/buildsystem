include_guard(GLOBAL)

include(get)

# Copy files in a custom target step
# In: copy_target_name - name of the target that performs the copy
# In: destination_directory - destination directory
# In: source_files - source filenames (including GLOBs)
function(copy_target_create copy_target_name destination_directory source_files)
    file(GLOB source_files ${source_files})
    get_absolute_file_paths(source_files ${source_files})

    if(NOT EXISTS ${destination_directory})
        file(MAKE_DIRECTORY ${destination_directory})
    endif()

    foreach(source_file ${source_files})
        get_filename_component(source_filename ${source_file} NAME)

        set(destination_file "${destination_directory}/${source_filename}")

        list(APPEND
            destination_files
            ${destination_file}
        )

        add_custom_command(
            OUTPUT ${destination_file}
            COMMAND ${CMAKE_COMMAND} -E copy ${source_file} ${destination_file}
            DEPENDS ${source_files}
        )
    endforeach()

    add_custom_target(${copy_target_name}
        DEPENDS ${destination_files}
    )
endfunction(copy_target_create)
