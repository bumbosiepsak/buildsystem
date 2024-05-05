include_guard(GLOBAL)

include(copy)
include(get)
include(testing)

set(MODULES_DIR ${CMAKE_CURRENT_LIST_DIR}) # Fetch "real" dir path of current file

# Adding targets ------------------------------------------------------------

# Adds a target on the current level.
# In: target_name Optional target name
# Out: CURRENT_TARGET current target name (to be used in raw CMake constructs, if really necessary)
# Remark: use add_target(abcde) to define an 'abcde' library/executable
# Remark: use add_target() in subdirectories (to define and OBJECT library)
macro(add_target)
    # Inheriting ALL_INCLUDE_PATHS
    unset(ALL_SOURCE_FILES)
    unset(ALL_USER_INTERFACE_FILES)
    unset(ALL_RESOURCE_FILES)
    unset(ALL_DEPENDENCIES)
    unset(ALL_PROPERTIES)

    set(target_name ${ARGV0})

    get_current_list_dir_leaf(leaf)

    if(target_name) # Named target
        if(NOT ${target_name} STREQUAL leaf)
            print_fatal_error("Target name: '${target_name}' mismatches its directory name: '${leaf}'")
        endif()

        set(IS_CURRENT_TARGET_ENABLED 1)

        set(CURRENT_TARGET_MAIN ${target_name})

        unset(ALL_SUBTARGETS)
        unset(ALL_TRANSLATION_FILES)

        get_current_list_dir_parent(PARENT_SOURCE_INCLUDE_PATH)
        get_current_binary_dir_parent(PARENT_BINARY_INCLUDE_PATH)

        set(ALL_INCLUDE_PATHS
            ${ALL_INCLUDE_PATHS}
            ${PARENT_SOURCE_INCLUDE_PATH}
            ${PARENT_BINARY_INCLUDE_PATH}
        )
    else() # Generated target (i.e. subdirectory)
        set(CURRENT_TARGET_MAIN
            "${CURRENT_TARGET_MAIN}_${leaf}"
        )
        # Inheriting ALL_SUBTARGETS
        # Inheriting ALL_TRANSLATION_FILES
        # Inheriting IS_CURRENT_TARGET_ENABLED
    endif()

    # Hashing due to path length limit on Windows
    get_host_friendly_unique_id(CURRENT_TARGET_OBJECTS "zz" "objects_${CURRENT_TARGET_MAIN}")
    set(CURRENT_TARGET ${CURRENT_TARGET_MAIN} ${CURRENT_TARGET_OBJECTS}) # Combines both: 'main' and 'objects' target
endmacro(add_target)

# Private function: composes a test name/string from automatically generated tokens joined with glue
# Out: name Variable to set the result to
# In: glue name/string parts separator
function(get_test_target_name name glue)
    get_current_list_dir_leaf(leaf)
    if(NOT "${leaf}" STREQUAL "${PARENT_TEST_TARGET}")
        set(target_suffix "_${leaf}")
    endif()

    set(${name} "${PARENT_TEST_TARGET}${glue}${CURRENT_TARGET_UNDER_TEST}${target_suffix}" PARENT_SCOPE)
endfunction(get_test_target_name)

# Adds a test target on the current level.
# In: parent_test_target parent target, reflecting the test type (utest, mtest, ptest etc)
# Out: CURRENT_TARGET current target name (to be used in raw CMake constructs, if really necessary)
# Remark: defines a test executable.
# Remark: if your test folder is named 'utest', the target will be named utest_abcde
# Remark: if your test folder is named 'Goofy', the target will be named utest_abcde_Goofy
macro(add_test_target parent_test_target)
    set(IS_CURRENT_TARGET_ENABLED 1)

    unset(ALL_SOURCE_FILES)
    unset(ALL_PROPERTIES)

    get_current_list_dir_parent(PARENT_SOURCE_INCLUDE_PATH)
    get_current_binary_dir_parent(PARENT_BINARY_INCLUDE_PATH)

    set(ALL_INCLUDE_PATHS
        ${ALL_INCLUDE_PATHS}
        ${PARENT_SOURCE_INCLUDE_PATH}
        ${PARENT_BINARY_INCLUDE_PATH}
    )

    # Inheriting other variables from parent folder

    set(PARENT_TEST_TARGET "${parent_test_target}") # i.e. utest, mtest etc
    set(CURRENT_TARGET_UNDER_TEST ${CURRENT_TARGET_MAIN})
    get_test_target_name(CURRENT_TARGET_MAIN "_")
    # Hashing due to path length limit on Windows
    get_host_friendly_unique_id(CURRENT_TARGET_OBJECTS "zz" "objects_${CURRENT_TARGET_MAIN}")
    set(CURRENT_TARGET ${CURRENT_TARGET_MAIN} ${CURRENT_TARGET_OBJECTS}) # Combines both: 'main' and 'objects' target

endmacro(add_test_target)

# Adds a list of main targets for which the current target is excluded
# In: list of excluded targets, for which this executable will not be built
function(add_excluded_target_hardware)
    get_matches_current_target_hardware(matches_current_target_hardware ${ARGN})

    if(${matches_current_target_hardware})
        set(IS_CURRENT_TARGET_ENABLED 0 PARENT_SCOPE)
    endif()
endfunction(add_excluded_target_hardware)

# Adding/removing sources ---------------------------------------------------

# Adds extra include path to current target
# In: ARGN list of include paths, possibly relative
function(add_include_paths)
    get_absolute_file_paths(include_paths ${ARGN})

    set(ALL_INCLUDE_PATHS ${include_paths} ${ALL_INCLUDE_PATHS} PARENT_SCOPE)
endfunction(add_include_paths)

# Adds source files to current target (executable/library/test).
# In: list of GLOB expressions matching added files
# Remark: add both *.cpp and *.h files if using QT
function(add_source_files)
    file(GLOB new_files ${ARGN})

    set(ALL_SOURCE_FILES ${ALL_SOURCE_FILES} ${new_files} PARENT_SCOPE)
endfunction(add_source_files)

# Adds QT user interface files to current target (executable/library/test).
# In: list of GLOB expressions matching added files
function(add_user_interface_files)
    file(GLOB new_files ${ARGN})

    set(ALL_USER_INTERFACE_FILES ${ALL_USER_INTERFACE_FILES} ${new_files} PARENT_SCOPE)
endfunction(add_user_interface_files)

# Adds QT resource files to current target (executable/library/test).
# In: list of GLOB expressions matching added files
function(add_resource_files)
    file(GLOB new_files ${ARGN})

    set(ALL_RESOURCE_FILES ${ALL_RESOURCE_FILES} ${new_files} PARENT_SCOPE)
endfunction(add_resource_files)

# Adds QT translation files to current target (executable/library/test).
# In: list of GLOB expressions matching added files
function(add_translation_files)
    file(GLOB new_files ${ARGN})

    set(ALL_TRANSLATION_FILES ${ALL_TRANSLATION_FILES} ${new_files} PARENT_SCOPE)
endfunction(add_translation_files)

# Removes source files from current target (previously added with add_sources)
# In: list of GLOB expressions matching removed files
function(remove_source_files)
    file(GLOB removed_files ${ARGN})
    list(REMOVE_ITEM ALL_SOURCE_FILES ${removed_files})

    set(ALL_SOURCE_FILES ${ALL_SOURCE_FILES} PARENT_SCOPE)
endfunction(remove_source_files)

# Removes all tested source files from current test target
# (previously added with add_sources) and adds ones listed.
# In: list of GLOB expressions matching removed files
# Remark: useful, when some source files just can't be included in tests
# Remark: use paths relative to your current CMakeFiles.txt
macro(pick_tested_source_files)
    unset(ALL_SUBTARGETS) # Remove all compiled source files

    file(GLOB new_files ${ARGN})

    get_absolute_file_paths(ALL_SOURCE_FILES ${new_files}) # Normalise paths to avoid building twice
endmacro(pick_tested_source_files)

# Adding subdirectories -----------------------------------------------------

# Adds subdirectories (with executables/libraries) to current mid-level project
# In: list of subdirectory names matching added subdirectories
# In: GENERATE_ONLY cache variable limiting generation of makefiles to single project subfolder
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

# Adds source subdirectories to current executable/library
# In: list of subdirectory names matching added subdirectories
# Remark: not allowed to be used in tests definitions
macro(add_source_subdirectories)
    if(IS_CURRENT_TARGET_ENABLED)
        foreach(subdirectory ${ARGN})
            add_subdirectory(${subdirectory})
        endforeach()
    endif()
endmacro(add_source_subdirectories)

# Adds test source subdirectories
# In: list of subdirectory names matching added subdirectories
# Remark: not allowed to be used in tests definitions
macro(add_test_subdirectories)
    testing_tests_apply_to_setup(tests_apply_to_setup)

    if(IS_CURRENT_TARGET_ENABLED AND ${tests_apply_to_setup})
        foreach(subdirectory ${ARGN})
            add_subdirectory(${subdirectory})
        endforeach()
    endif()
endmacro(add_test_subdirectories)

# Adding dependencies -------------------------------------------------------

# Adds dependencies to current target, regardless of their type (internal/external/non-linkable/file/generated file)
# Remark: Use the DIRECTIVE keyword to insert a linker directive
# Remark: Use the GENERATED keyword to depend on a generated file
# Remark: Use the NONLINKABLE keyword to depend on a custom target or file without code
# Remark: see add_external_dependency remarks
function(add_target_dependencies)
    if(IS_CURRENT_TARGET_ENABLED)
        set(ALL_DEPENDENCIES ${ALL_DEPENDENCIES} ${ARGN} PARENT_SCOPE)
    endif()
endfunction(add_target_dependencies)

# Adds a dependency to 3'rd party libraries
# In: dependency Name of the FindLibrary.cmake module, matching added library
# Remark: you need a corresponding FindLibrary.cmake file in your CMAKE_MODULES_PATH for this to work
# Remark: you should use 'add_target_dependencies' in typical use instead
function(add_external_dependency dependency)
    if(IS_CURRENT_TARGET_ENABLED)
        find_package(${dependency} REQUIRED)

        string(TOUPPER ${dependency} dependency_upper) # This is the convention

        if(${${dependency_upper}_FOUND})  # module mode
            set(EXTERNAL_DEPENDENCY_INTERFACE ${dependency}_interface)

            if(NOT TARGET EXTERNAL_DEPENDENCY_INTERFACE)
                add_library(${EXTERNAL_DEPENDENCY_INTERFACE} INTERFACE)

                target_include_directories(${EXTERNAL_DEPENDENCY_INTERFACE}
                    INTERFACE
                        ${${dependency_upper}_INCLUDE_DIR}
                        ${${dependency_upper}_INCLUDE_DIRS}
                )

                target_link_libraries(${EXTERNAL_DEPENDENCY_INTERFACE}
                    INTERFACE
                        ${${dependency_upper}_LIBRARY}
                        ${${dependency_upper}_LIBRARIES}
                )
            endif()

            set(ALL_DEPENDENCIES ${ALL_DEPENDENCIES} ${EXTERNAL_DEPENDENCY_INTERFACE} PARENT_SCOPE)
        else()  # config mode
            set(ALL_DEPENDENCIES ${ALL_DEPENDENCIES} ${dependency} PARENT_SCOPE)
        endif()
    endif()
endfunction(add_external_dependency)

# Removes all dependencies from current (test) target
# (previously added with add_target_dependencies) and adds ones listed.
# In: list of dependencies
# Remark: useful, when some dependencies just can't be included in tests
macro(pick_target_dependencies)
    if(IS_CURRENT_TARGET_ENABLED)
        unset(ALL_DEPENDENCIES)

        add_target_dependencies(${ARGN})
    endif()
endmacro(pick_target_dependencies)

# Private function, splits dependencies to linkable targets (libraries) and non-linkable (custom targets, executables)
# In: dependency of TARGET type
function(__apply_target_dependency_transformation dependency)
    get_target_property(dependency_type ${dependency} TYPE)

    if (${dependency_type} MATCHES ".*_LIBRARY")
        set(ALL_DEPENDENCIES ${ALL_DEPENDENCIES} ${dependency} PARENT_SCOPE)
    else()
        set(ALL_NON_LINKABLE_DEPENDENCIES ${ALL_NON_LINKABLE_DEPENDENCIES} ${dependency} PARENT_SCOPE)
    endif()
endfunction(__apply_target_dependency_transformation)

# Private function, adds dependencies as non-linkable
# In: ARGV dependencies
function(__add_nonlinkable_dependencies)
    set(ALL_NON_LINKABLE_DEPENDENCIES ${ALL_NON_LINKABLE_DEPENDENCIES} ${ARGN} PARENT_SCOPE)
endfunction(__add_nonlinkable_dependencies)

# Private function, resolves internal/external/direct dependencies and build directives
# In: ALL_DEPENDENCIES Raw dependencies added with add_dependency()/add_external_dependency()
# InOut: ALL_INCLUDE_PATHS Includes supplemented with entries coming from dependency evaluation
# Out: ALL_DEPENDENCIES Transformed dependencies with external ones and directives evaluated
function(__apply_dependencies_transformations)
    set(raw_all_dependencies ${ALL_DEPENDENCIES})
    unset(ALL_DEPENDENCIES)
    unset(ALL_NON_LINKABLE_DEPENDENCIES)

    set(is_directive 0)
    set(is_generated 0)
    set(is_nonlinkable 0)
    foreach(dependency ${raw_all_dependencies})
        if(${dependency} STREQUAL DIRECTIVE)
            set(is_directive 1)
        elseif(is_directive)
            set(is_directive 0)
            add_target_dependencies(${dependency})
        elseif(${dependency} STREQUAL GENERATED)
            set(is_generated 1)
        elseif(is_generated)
            set(is_generated 0)
            add_target_dependencies(${dependency})
        elseif(${dependency} STREQUAL NONLINKABLE)
            set(is_nonlinkable 1)
        elseif(is_nonlinkable)
            set(is_nonlinkable 0)
            __add_nonlinkable_dependencies(${dependency})
        elseif(EXISTS ${dependency})
            add_target_dependencies(${dependency})
        elseif(TARGET ${dependency})
            __apply_target_dependency_transformation(${dependency})
        else()
            add_external_dependency(${dependency})
        endif()
    endforeach()

    set(ALL_INCLUDE_PATHS ${ALL_INCLUDE_PATHS} PARENT_SCOPE)
    set(ALL_DEPENDENCIES ${ALL_DEPENDENCIES} PARENT_SCOPE)
    set(ALL_NON_LINKABLE_DEPENDENCIES ${ALL_NON_LINKABLE_DEPENDENCIES} PARENT_SCOPE)
endfunction(__apply_dependencies_transformations)

# Adds non-linkable dependencies to target, if they exist
# In: target: target to be made dependent
function(__apply_non_linkable_dependencies target)
    if(ALL_NON_LINKABLE_DEPENDENCIES)
        add_dependencies(${target} ${ALL_NON_LINKABLE_DEPENDENCIES})
    endif()
endfunction(__apply_non_linkable_dependencies)

# Adding properties ---------------------------------------------------------

# Adds/appends property to target
# In: PROPERTY property key and values to be added/appended
# In: APPEND/APPEND_STRING causes the property to be appended
# Remark: Must be called before its add_executable/add_library_xxx/add_test_executable
macro(add_target_property)
    if(TARGET ${CURRENT_TARGET_MAIN})
        print_fatal_error(
            "Call to 'add_target_property' must come before 'add_executable/add_library_xxx/add_test_executable' for target: '${CURRENT_TARGET_MAIN}'"
        )
    endif()
    get_nested_list_from_list(added_target_property "${ARGN}")
    set(ALL_PROPERTIES ${ALL_PROPERTIES} ${added_target_property})
endmacro(add_target_property)

function(__apply_target_properties target)
    foreach(properties ${ALL_PROPERTIES})
        get_list_from_nested_list(properties ${properties})
        set_property(TARGET ${target}
            ${properties}
        )
    endforeach()
endfunction(__apply_target_properties)

# Copying/transforming files ------------------------------------------------

# Copy files as before making the currrent target
function(add_copy_step destination_directory source_files)
    if(IS_CURRENT_TARGET_ENABLED)
        get_host_friendly_unique_id(copy_target_name "${CURRENT_TARGET_MAIN}_cp_" "${destination_directory}_${source_files}")

        copy_target_create(${copy_target_name} ${destination_directory} ${source_files})

        add_dependencies(${copy_target_name} ${CURRENT_TARGET_OBJECTS}) # Run after "OBJECTS"
        add_dependencies(${CURRENT_TARGET_MAIN} ${copy_target_name}) # Run before "MAIN"
    endif()
endfunction(add_copy_step)

# Handling QT ---------------------------------------------------------------

# Private function, applies QT-specific file generation/transformations
# Remark: currently, macros from FindQt4.cmake are being used.
# Switch to native functions, once offered by upgraded CMake
function(__apply_qt_transformations)
    if(DEFINED QT_SUPPORT)
        QT4_WRAP_UI(
            ALL_USER_INTERFACE_FILES
            ${ALL_USER_INTERFACE_FILES}
        )

        QT4_ADD_RESOURCES(
            ALL_RESOURCE_FILES
            ${ALL_RESOURCE_FILES}
        )

        if(UPDATE_TRANSLATION_FILES) # TODO: Expose this option to the user
            set(scanned_files
                ${ALL_USER_INTERFACE_FILES}
                ${ALL_SOURCE_FILES}
            )
            QT4_CREATE_TRANSLATION(
                ALL_TRANSLATION_FILES_QM
                ${scanned_files}
                ${ALL_TRANSLATION_FILES}
            )
        else()
            QT4_ADD_TRANSLATION(
                ALL_TRANSLATION_FILES_QM
                ${ALL_TRANSLATION_FILES}
            )
        endif()

        set(ALL_TRANSLATION_FILES_QM
            ${ALL_TRANSLATION_FILES_QM}
            PARENT_SCOPE
        )

        set(ALL_SOURCE_FILES
            ${ALL_USER_INTERFACE_FILES} # Generation goes first
            ${ALL_RESOURCE_FILES}
            ${ALL_SOURCE_FILES}
            PARENT_SCOPE
        )
    endif()
endfunction(__apply_qt_transformations)

# Private function, applies QT-specific file generation/transformations
function(__apply_qt_properties target_name)
    if(DEFINED QT_SUPPORT)
        set_target_properties(${target_name} PROPERTIES
            AUTOMOC TRUE
        )

        target_compile_definitions(${target_name}
            PRIVATE -DQT_CORE_LIB # Needed by log/dbg.hpp
        )
    endif()
endfunction(__apply_qt_properties)

# Adding executables --------------------------------------------------------

# Private function: creates an object library from ALL_SOURCE_FILES excluding main
# and appends it to ALL_SUBTARGETS
macro(__apply_current_target_transformation)
    if(MAIN_FILE)
        list(REMOVE_ITEM ALL_SOURCE_FILES ${MAIN_FILE})
    endif()

    if(ALL_SOURCE_FILES) # Required to avoid "no source files in target" warning
        set(ALL_SUBTARGETS
            ${ALL_SUBTARGETS}
            ${CURRENT_TARGET_OBJECTS}
        )

        set(ALL_SUBTARGETS # Export to parent scope
            ${ALL_SUBTARGETS}
            PARENT_SCOPE
        )

        add_library(${CURRENT_TARGET_OBJECTS} OBJECT
            ${ALL_SOURCE_FILES}
        )

        target_include_directories(${CURRENT_TARGET_OBJECTS}
            PRIVATE ${ALL_INCLUDE_PATHS}
        )

        set_target_properties(${CURRENT_TARGET_OBJECTS}
            PROPERTIES
                EXCLUDE_FROM_ALL ON
                FOLDER ${INTERNAL_TARGETS_FOLDER}
        )

        __apply_qt_properties(${CURRENT_TARGET_OBJECTS})
    endif()
endmacro(__apply_current_target_transformation)

# Private function: propagates properties of the main target to subtargets/objects
function(__apply_properties_propagation)
    get_property(is_position_independent TARGET ${CURRENT_TARGET_MAIN}
        PROPERTY INTERFACE_POSITION_INDEPENDENT_CODE
    )

    foreach(subtarget ${ALL_SUBTARGETS})
        if(is_position_independent)
            set_property(TARGET ${subdirectory_target}
                PROPERTY POSITION_INDEPENDENT_CODE ON
            )
        endif()

        target_link_libraries(${subtarget}
            PRIVATE
                ${ALL_DEPENDENCIES}
        )

        __apply_non_linkable_dependencies(${subtarget})

    endforeach()
endfunction(__apply_properties_propagation)

# Adds an executable
# In: main_file main file name (to be excluded from tests)
function(add_executable_with_main main_file)
    get_filename_component(MAIN_FILE ${main_file} ABSOLUTE)

    if(NOT EXISTS ${MAIN_FILE})
        print_fatal_error("Adding executable: '${CURRENT_TARGET_MAIN}' with non-existing main file: '${main_file}'")
    endif()

    __apply_qt_transformations()

    if(IS_CURRENT_TARGET_ENABLED)

        __apply_dependencies_transformations()
        __apply_current_target_transformation()

        get_target_objects(ALL_TARGET_OBJECTS ${ALL_SUBTARGETS})

        add_executable(${CURRENT_TARGET_MAIN}
            ${MAIN_FILE}
            ${ALL_TRANSLATION_FILES_QM}
            ${ALL_TARGET_OBJECTS}
        )

        __apply_qt_properties(${CURRENT_TARGET_MAIN})

        target_include_directories(${CURRENT_TARGET_MAIN}
            PRIVATE ${ALL_INCLUDE_PATHS}
        )

        target_link_libraries(${CURRENT_TARGET_MAIN}
            PUBLIC ${ALL_DEPENDENCIES}
        )

        __apply_non_linkable_dependencies(${CURRENT_TARGET_MAIN})

        __apply_target_properties(${CURRENT_TARGET_MAIN})

        __apply_properties_propagation()

        add_dependencies(coverage_baseline ${CURRENT_TARGET_MAIN})

        if(COMMAND add_linker_script_targets)
            add_linker_script_targets(${CURRENT_TARGET_MAIN})
        endif()

        if(COMMAND add_binary_targets)
            add_binary_targets(${CURRENT_TARGET_MAIN})
        endif()
    endif()
endfunction(add_executable_with_main)

# Adding libraries ----------------------------------------------------------

# Private function: generates a Find-script.cmake for internally built libraries
function(__generate_find_script target_name)
    get_target_property(interface_link_libraries
        ${CURRENT_TARGET_MAIN}
        INTERFACE_LINK_LIBRARIES
    )

    if(interface_link_libraries)
        string(REPLACE ";" " " interface_link_libraries "${interface_link_libraries}")
    else()
        unset(interface_link_libraries)
    endif()

    get_target_property(interface_include_directories
        ${CURRENT_TARGET_MAIN}
        INTERFACE_INCLUDE_DIRECTORIES
    )

    if(interface_include_directories)
        string(REPLACE ";" " " interface_include_directories "${interface_include_directories}")
    else()
        unset(interface_include_directories)
    endif()

    configure_file(
        "${MODULES_DIR}/find_template.cmake"
        "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/find-modules/Find${target_name}.cmake"
        @ONLY
    )
endfunction(__generate_find_script)

# Private function: a library
macro(__add_library_impl type)
    __apply_qt_transformations()

    if(IS_CURRENT_TARGET_ENABLED)

        __apply_dependencies_transformations()

        if(${type} STREQUAL INTERFACE)
            set(linkage_mode INTERFACE)
            set(include_mode INTERFACE)
            set(ALL_TARGET_OBJECTS "")
        else()
            set(linkage_mode PUBLIC)
            set(include_mode PUBLIC)
            __apply_current_target_transformation()
            get_target_objects(ALL_TARGET_OBJECTS ${ALL_SUBTARGETS})
        endif()

        add_library(${CURRENT_TARGET_MAIN} ${type}
            ${ALL_TARGET_OBJECTS}
            ${ALL_TRANSLATION_FILES_QM}
        )

        __apply_qt_properties(${CURRENT_TARGET_MAIN})

        target_link_libraries(${CURRENT_TARGET_MAIN}
            ${linkage_mode}
                ${ALL_DEPENDENCIES}
        )

        __apply_non_linkable_dependencies(${CURRENT_TARGET_MAIN})

        get_current_list_dir_parent(PARENT_SOURCE_INCLUDE_PATH)
        get_current_binary_dir_parent(PARENT_BINARY_INCLUDE_PATH)

        file(RELATIVE_PATH INSTALLED_INCLUDE_PATH "${CURRENT_PROJECT_ROOT_DIR}" "${PARENT_SOURCE_INCLUDE_PATH}")

        target_include_directories(${CURRENT_TARGET_MAIN}
            INTERFACE
                $<BUILD_INTERFACE:${PARENT_SOURCE_INCLUDE_PATH}>
                $<BUILD_INTERFACE:${PARENT_BINARY_INCLUDE_PATH}>
                $<INSTALL_INTERFACE:${INSTALLED_INCLUDE_PATH}>
            ${include_mode}
                ${ALL_INCLUDE_PATHS}
        )

        __apply_target_properties(${CURRENT_TARGET_MAIN})

        __apply_properties_propagation()

        set(meaty_library_types SHARED STATIC OBJECT)
        if(${type} IN_LIST meaty_library_types)
            add_dependencies(coverage_baseline ${CURRENT_TARGET_MAIN})
        endif()

        __generate_find_script(${CURRENT_TARGET_MAIN})
    endif()
endmacro(__add_library_impl)

# Adds a library of kind chosen by parameter
function(add_library_any type)
    __add_library_impl(${type})
endfunction(add_library_any)

# Adds a dynamic library
# Remark: position-independent code is being produced
function(add_library_shared)
    __add_library_impl(SHARED)
endfunction(add_library_shared)

# Adds a static library
function(add_library_static)
    __add_library_impl(STATIC)
endfunction(add_library_static)

# Adds an object library
function(add_library_object)
    __add_library_impl(OBJECT)
endfunction(add_library_object)

# Adds an interface (header-only) library
function(add_library_interface)
    __add_library_impl(INTERFACE)
endfunction(add_library_interface)

# Adds this folder to current target and injects everything into parent target
macro(add_this_subdirectory) # Using macro in order to reach parent files
    set(ALL_TRANSLATION_FILES # ALL_TRANSLATION_FILES need to be returned "as is"
        ${ALL_TRANSLATION_FILES}
        PARENT_SCOPE # Inject ALL_TRANSLATION_FILES into parent
    )

    __apply_qt_transformations() # This might append to ALL_SOURCE_FILES

    if(ALL_SOURCE_FILES) # Required to avoid "no source files in target" warning

        __apply_dependencies_transformations()

        set(ALL_SUBTARGETS
            ${ALL_SUBTARGETS}
            ${CURRENT_TARGET_MAIN}
            PARENT_SCOPE # Inject ALL_SUBTARGETS into parent
        )

        add_library(${CURRENT_TARGET_MAIN} OBJECT
            ${ALL_SOURCE_FILES}
            # No ALL_TRANSLATION_FILES, as OBJECT libs can't handle them
            # No ALL_TARGET_OBJECTS, as OBJECT libs can't link against other OBJECT libs
        )

        set_target_properties(${CURRENT_TARGET_MAIN}
            PROPERTIES EXCLUDE_FROM_ALL ON
        )

        __apply_qt_properties(${CURRENT_TARGET_MAIN})

        target_link_libraries(${CURRENT_TARGET_MAIN}
            PUBLIC
                ${ALL_DEPENDENCIES}
        )

        __apply_non_linkable_dependencies(${CURRENT_TARGET_MAIN})

        target_include_directories(${CURRENT_TARGET_MAIN}
            PRIVATE ${ALL_INCLUDE_PATHS}
        )

        __apply_target_properties(${CURRENT_TARGET_MAIN})

    else()
        set(ALL_SUBTARGETS
            ${ALL_SUBTARGETS}
            PARENT_SCOPE # Forward ALL_SUBTARGETS into parent
        )
    endif()
endmacro(add_this_subdirectory)

# Adding test executables ---------------------------------------------------

# Private function: binds given dependencies with a parent test target and creates a CTest test
# In: COMMAND Command to be executed
# In: DEPENDS Extra dependencies
function(__bind_test)
    if(IS_CURRENT_TARGET_ENABLED)
        cmake_parse_arguments(ARGS
            ""
            ""
            "COMMAND;DEPENDS"
            ${ARGN}
        )
        add_test(
            NAME ${CURRENT_TARGET_MAIN}
            COMMAND ${ARGS_COMMAND}
            WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
        )
        add_dependencies(${PARENT_TEST_TARGET} ${ARGS_DEPENDS})

        if(SANITIZER_LIBRARY)
            # TODO: This is Linux-specific. Redesign once Windows/MSVC sanitiser works
            set_property(TEST ${CURRENT_TARGET_MAIN}
                PROPERTY ENVIRONMENT "LD_PRELOAD=${SANITIZER_LIBRARY}" "UBSAN_OPTIONS=print_stacktrace=1"
            )
        endif()

        set(RUN_CURRENT_TARGET_MAIN "run_${CURRENT_TARGET_MAIN}")

        add_custom_target(${RUN_CURRENT_TARGET_MAIN}
            ${CMAKE_CTEST_COMMAND}
                --config $<CONFIG>
                --verbose
                --tests-regex "^${CURRENT_TARGET_MAIN}"
                --exclude-regex "^${CURRENT_TARGET_MAIN}.+"
        )
        add_dependencies(${RUN_CURRENT_TARGET_MAIN} ${ARGS_DEPENDS})
    endif()
endfunction(__bind_test)

# Adds a test executable
# In: INCLUDES List of test framework include paths
# In: DEPENDS List of test framework libraries, to be linked with the test executable
# In: ARGUMENTS List of arguments to be passed to the test executable at runtime
# Remark: typically, use specific functions ('add_test_executable_gtest' etc)
function(add_test_executable)
    cmake_parse_arguments(ARGS
        ""
        ""
        "ARGUMENTS;DEPENDS;INCLUDES"
        ${ARGN}
    )
    if(IS_CURRENT_TARGET_ENABLED)
        set(ALL_DEPENDENCIES ${ALL_DEPENDENCIES} ${ARGS_DEPENDS})

        add_executable_with_main("/")

        coverage_add_excluded_sources("${CMAKE_CURRENT_SOURCE_DIR}/**")

        __bind_test(
            COMMAND "$<TARGET_FILE:${CURRENT_TARGET_MAIN}>" ${ARGS_ARGUMENTS}
            DEPENDS ${CURRENT_TARGET_MAIN}
        )
    endif()
endfunction(add_test_executable)

# Adds a test executable, basing on GTest/GMock
# Remark: the 'main' function is automatically supplied, don't write one yourself
# Remark: the 'main' function from your tested executable is being automatically removed
function(add_test_executable_gtest)
    testing_enable_gtest()

    if(COLOR_OUTPUT)
        set(color "yes")
    else()
        set(color "no")
    endif()

    add_test_executable(
        INCLUDES "${GMOCK_INCLUDE_DIRS}"
        DEPENDS ${GTEST_BOTH_LIBRARIES} ${GMOCK_LIBRARIES} pthread
        ARGUMENTS --gtest_color=${color}
    )
endfunction(add_test_executable_gtest)

# Adds a test executable, basing on QTest
# Remark: the 'main' function is automatically supplied, don't write one yourself
# Remark: the 'main' function from your tested executable is being automatically removed
function(add_test_executable_qtest)
    add_test_executable(
        INCLUDES "${QT_QTTEST_INCLUDE_DIR}"
        DEPENDS Qt4::QtTest Qt4::QtGui
    )
endfunction(add_test_executable_qtest)

# Adds a test executable, basing on Catch2
# In: ARGV Arguments passed to test invocation
function(add_test_executable_catch2)
    testing_enable_catch2()

    if(COLOR_OUTPUT)
        set(color "yes")
    else()
        set(color "no")
    endif()

    add_test_executable(
        DEPENDS Catch2::Catch2
        ARGUMENTS ${ARGV} --durations yes --use-colour ${color}
    )
endfunction(add_test_executable_catch2)

# Adds a test executable without any test framework
# Remark: you're on your own - provide all source code, including a 'main' function
# In: ARGV Arguments passed to test invocation
function(add_test_executable_handcrafted)
    add_test_executable(
        ARGUMENTS ${ARGV}
    )
endfunction(add_test_executable_handcrafted)

# Adds a freeform test with given command, dependent on current tested target
# In: COMMAND Command to be executed
# In: DEPENDS Extra dependencies (with current tested/main target implicitly included)
function(add_test_freeform)
    if(IS_CURRENT_TARGET_ENABLED)
        cmake_parse_arguments(ARGS
            ""
            ""
            "COMMAND;DEPENDS"
            ${ARGN}
        )

        set(ALL_DEPENDENCIES ${ALL_DEPENDENCIES} ${ARGS_DEPENDS} PARENT_SCOPE)

        get_split_dependencies("${ALL_DEPENDENCIES}" target_dependencies file_dependencies)

        add_custom_target(${CURRENT_TARGET_MAIN}
            DEPENDS ${file_dependencies}
        )

        add_dependencies(${CURRENT_TARGET_MAIN}
            ${CURRENT_TARGET_UNDER_TEST}
            ${target_dependencies}
        )

        __bind_test(
            COMMAND "${ARGS_COMMAND}"
            DEPENDS ${CURRENT_TARGET_MAIN} ${ALL_DEPENDENCIES}
        )
    endif()
endfunction(add_test_freeform)

# Defines a test workspace directory
# Out: directory - workspace directory path pointing to framework-chosen location
# Remark: this directory will be created by CMake and removed in target clean
function(add_test_workspace_directory directory)
    if(IS_CURRENT_TARGET_ENABLED)
        get_test_target_name(workspace_directory "/") # NOTE: Path constructed here, not target name
        set(workspace_directory "${TESTING_WORKSPACE_DIRECTORY}/${workspace_directory}")

        get_host_friendly_unique_id(target_name "zz" "${CURRENT_TARGET_MAIN}_workspace_directory")

        add_custom_target(${target_name}
            COMMENT "Creating workspace directory for: ${CURRENT_TARGET_MAIN}"
            COMMAND ${CMAKE_COMMAND} -E make_directory "${workspace_directory}"
            BYPRODUCTS
                "${workspace_directory}"
        )

        set(ALL_DEPENDENCIES ${ALL_DEPENDENCIES} ${target_name} PARENT_SCOPE)
        set("${directory}" "${workspace_directory}" PARENT_SCOPE)
    endif()
endfunction(add_test_workspace_directory)
