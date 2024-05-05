include_guard(GLOBAL)

include(copy)
include(get)

macro(add_target)
    set(IS_CURRENT_TARGET_ENABLED 1)
endmacro(add_target)

macro(add_test_target parent_test_target)
endmacro(add_test_target)

function(add_excluded_target_hardware)
    get_matches_current_target_hardware(matches_current_target_hardware ${ARGN})

    if(${matches_current_target_hardware})
        set(IS_CURRENT_TARGET_ENABLED 0 PARENT_SCOPE)
    endif()
endfunction(add_excluded_target_hardware)

function(add_include_paths)
endfunction(add_include_paths)

function(add_source_files)
endfunction(add_source_files)

function(add_user_interface_files)
endfunction(add_user_interface_files)

function(add_resource_files)
endfunction(add_resource_files)

function(add_translation_files)
endfunction(add_translation_files)

macro(remove_source_files)
endmacro(remove_source_files)

macro(pick_tested_source_files)
endmacro(pick_tested_source_files)

macro(add_project_subdirectories)
    if(DEFINED GENERATE_ONLY)
        set(generate_only ${GENERATE_ONLY})
        unset(GENERATE_ONLY)
        add_subdirectory(${generate_only})
    else()
        foreach(subdirectory ${ARGN})
            add_subdirectory(${subdirectory})
        endforeach()
    endif()
endmacro(add_project_subdirectories)

macro(add_source_subdirectories)
    if(IS_CURRENT_TARGET_ENABLED)
        foreach(subdirectory ${ARGN})
            add_subdirectory(${subdirectory})
        endforeach()
    endif()
endmacro(add_source_subdirectories)

macro(add_test_subdirectories)
    if(IS_CURRENT_TARGET_ENABLED)
        foreach(subdirectory ${ARGN})
            add_subdirectory(${subdirectory})
        endforeach()
    endif()
endmacro(add_test_subdirectories)

macro(add_target_dependencies)
endmacro(add_target_dependencies)

macro(pick_target_dependencies)
endmacro(pick_target_dependencies)

function(add_target_property)
endfunction(add_target_property)

function(add_copy_step destination_directory source_files)
endfunction(add_copy_step)

function(add_executable_with_main main_file)
endfunction(add_executable_with_main)

function(add_library_any type)
endfunction(add_library_any)

function(add_library_shared)
endfunction(add_library_shared)

function(add_library_static)
endfunction(add_library_static)

function(add_library_object)
endfunction(add_library_object)

function(add_library_interface)
endfunction(add_library_interface)

macro(add_this_subdirectory)
endmacro(add_this_subdirectory)

function(add_test_executable test_framework_includes test_framework_libs arguments)
endfunction(add_test_executable)

function(add_test_executable_gtest)
endfunction(add_test_executable_gtest)

function(add_test_executable_qtest)
endfunction(add_test_executable_qtest)

function(add_test_executable_catch2)
endfunction(add_test_executable_catch2)

function(add_test_executable_handcrafted)
endfunction(add_test_executable_handcrafted)

function(add_test_freeform)
endfunction(add_test_freeform)

macro(add_test_workspace_directory directory)
endmacro(add_test_workspace_directory)
