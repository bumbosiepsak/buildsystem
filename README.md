# CMake build system
This brief cheatsheet describes the API exposed by the build system.
For examples of how to use it, see `source/cmake/help`, where a sample project resides.

## Defining projects

### `project`
Defines a top-level or mid-level project.
* In: `name` - Project name
* In: `env_sdk_dir` - Name of the (optionally filled) enviromnemt variable containing the SDK root directory.
Provide the `IMPLICIT_SDK_DIR` tag to define a mid-level project

## Defining toolchains

### `toolchain_configure`
Defines a mapping between command-line options and a toolchain file.  
* In: `FOR_HOST_HARDWARE` - lowercase platform_processor string corresponding to the hardware you're building on  
* In: `FOR_TARGET_HARDWARE` - lowercase platform_processor string corresponding to the hardware you're building for  
* In: `FOR_TOOLCHAIN_TYPE` - arbitrary string identifying the toolchain type (e.g. gcc, msvc, etc)  
* In: `WITH_FILE` - name of the toolchain file (no extension), residing in the cmake/toolchains folder  

## Defining convention checks

### `conventions_define`
Defines a new coding convention.  
* In: `name` - name of the convention. Acts as a key and corresponding check_xxx/apply/xxx scripts must be present in the cmake/conventions folder  
* In: `DESCRIPTION` - Textual description of the convention  
* In: `FOR_FILES` - list of universal globs/filenames, relative to the current list directory  
* In: `EXCLUDING_FILES` - list of universal globs/filenames, relative to the current list directory  

### `conventions_include_files`
Defines extra files/globs to conform to the given convention.   
* In: `name` - name of the convention to which to append extra files  
* In: `list` - of universal globs/filenames, relative to the current list directory  

### `conventions_exclude_files`
Excludes files/globs from conforming to the given convention.  
* In: `name` - name of the convention from which to exclude extra files  
* In: `ARGN` - list of universal globs/filenames, relative to the current list directory  

## Adding targets

### `add_target`
Adds a target on the current level.  
* In: `target_name` - Optional target name  
* Out: `CURRENT_TARGET` - current target name (to be used in raw CMake constructs, if really necessary)  
> Remark: use add_target(abcde) to define an 'abcde' library/executable  
> Remark: use add_target() in subdirectories (to define and OBJECT library)  

### `add_test_target`
Adds a test target on the current level.  
* In: `parent_test_target` - parent target, reflecting the test type (utest, mtest, ptest etc)  
* Out: `CURRENT_TARGET` - current target name (to be used in raw CMake constructs, if really necessary)  
> Remark: defines a test executable.  
> Remark: if your test folder is named 'utest', the target will be named utest_abcde  
> Remark: if your test folder is named 'Goofy', the target will be named utest_abcde_Goofy  

### `add_excluded_main_targets`
Adds a list of main targets for which the current target is excluded.
* In: `ARGN` - list of excluded targets, for which this executable will not be built

## Adding/removing sources

### `add_include_paths`
Adds extra include path to current target.
* In: `ARGN` - list of include paths, possibly relative

### `add_source_files`
Adds source files to current target (executable/library/test).
* In: `ARGN` - list of GLOB expressions matching added files
> Remark: add both *.cpp and *.h files if using QT  

### `add_user_interface_files`
Adds QT user interface files to current target (executable/library/test).
* In: `ARGN` - list of GLOB expressions matching added files

### `add_resource_files`
Adds QT resource files to current target (executable/library/test).
* In: `ARGN` - list of GLOB expressions matching added files

### `add_translation_files`
Adds QT translation files to current target (executable/library/test).
* In: `ARGN` - list of GLOB expressions matching added files

### `remove_source_files`
Removes source files from current target (previously added with add_sources).
* In: `ARGN` - list of GLOB expressions matching removed files

### `pick_tested_source_files`
Removes all tested source files from current test target (previously added with add_sources) and adds ones listed.
* In: `ARGN` - list of GLOB expressions matching removed files
> Remark: useful, when some source files just can't be included in tests  
> Remark: use paths relative to your current CMakeFiles.txt  

## Adding subdirectories

### `add_project_subdirectories`
Adds subdirectories (with executables/libraries) to current mid-level project.
* In: `ARGN` - list of subdirectory names matching added subdirectories
* In: `GENERATE_ONLY` - cache variable limiting generation of makefiles to single project subfolder

### `add_source_subdirectories`
Adds source subdirectories to current executable/library.
* In: `ARGN` - list of subdirectory names matching added subdirectories
> Remark: not allowed to be used in tests definitions  

### `add_test_subdirectories`
Adds test source subdirectories.
* In: `ARGN` - list of subdirectory names matching added subdirectories
> Remark: not allowed to be used in tests definitions  

## Adding dependencies

### `add_target_dependencies`
# Adds dependencies to current target, regardless of their type (internal/external/non-linkable/file/generated file).
> Remark: Use the DIRECTIVE keyword to insert a linker directive
> Remark: Use the GENERATED keyword to depend on a generated file
> Remark: Use the NONLINKABLE keyword to depend on a custom target or file without code
> Remark: see add_external_dependency remarks
> Remark: see add_external_dependency/add_internal_dependency remarks  

### `pick_target_dependencies`
Removes all dependencies from current (test) target (previously added with add_target_dependencies) and adds ones listed.
* In: `ARGN` - list of dependencies
> Remark: useful, when some dependencies just can't be included in tests  

### `add_external_dependency`
Adds a dependency to 3'rd party libraries.
* In: `dependency` - Name of the FindLibrary.cmake module, matching added library
> Remark: you need a corresponding FindLibrary.cmake file in your CMAKE_MODULES_PATH for this to work  
> Remark: you should use 'add_target_dependencies' in typical use instead  

### `add_target_property`
Adds/appends property to target
* In: PROPERTY property key and values to be added/appended 
* In: APPEND/APPEND_STRING causes the property to be appended
> Remark: Must be called before its add_executable/add_library_xxx/add_test_executable

## Copying extra files

### `copy_target_create`
Copies files in a (custom) target.
> Remark: Supports globs  

### `add_copy_step`
Copies files to any directory after compiling the objects, but before linking.
> Remark: Supports globs  

## Handling Boost

### `boost_support_enable`
Enables Boost support for given sub-packages.
* In COMPONENTS: list of required Boost components (e.g. system, serialization etc.)
* In DIRECTIVES: list of key/value pairs controlling the discovery process (see docs of FindBoost.cmake)
> Remark: Linking against non-header-only Boost libs required via imported targets (e.g. Boost::system, Boost::serialization etc.)
> Remark: invoke this function in scope common to all usages (e.g. on the project declaration level)

## Handling Clang-Tidy

### `clang_tidy_support_enable`
Enables Clang-Tidy support
* In ENABLED: enables Clang-Tidy if set to true (e.g. for given build configuration)
* In OPTIONS: list of options passed to Clang-Tidy
* In VERSION: optionally sets Clang-Tidy version
> Remark: It might be most convenient to pass configuration via the default .clang-tidy file
> Remark: invoke this function in scope common to all usages (e.g. on the project declaration level)

## Handling Include-What-You-Use

### `include_what_you_use_support_enable`
Enables Include-What-You-Use support for all targets
* In ENABLED: enables IWYU if set to true (e.g. for given build configuration)
* In MAPPING_FILES: extra mapping files paths. May be relative to project root or cmake/extras/include-what-you-use folder
* In OPTIONS: list of options passed to IWYU
> Remark: invoke this function in scope common to all usages (e.g. on the project declaration level)

## Handling OpenCV

### `opencv_support_enable`
Enables OpenCV support for given sub-packages.
* In COMPONENTS: list of required OpenCV components (e.g. opencv_core, opencv_imgcodecs etc.)
* In DIRECTIVES: list of key/value pairs controlling the discovery process (see docs of FindOpenCV.cmake)
> Remark: invoke this function in scope common to all usages (e.g. on the project declaration level)  

## Handling QT

### `qt4_support_enable`
Enables QT support for given sub-packages
* In COMPONENTS: list of required Qt4 components (e.g. QtCore, QtGui etc.)
> Remark: invoke this function in scope common to all usages (e.g. on the project declaration level)  

## Adding executables

### `add_executable_with_main`
Adds an executable.
* In: `main_file` - main file name (to be excluded from tests)

## Adding libraries

### `add_library_any`
Adds a static/dynamic library.
> Remark: use 'add_library_shared/add_library_static' in typical situations  

### `add_library_shared`
Adds a dynamic library.
> Remark: position-independent code is being produced  

### `add_library_static`
Adds a static library.

### `add_library_object`
Adds an object library.

### `add_library_interface`
Adds an interface (header-only) library.

### `add_this_subdirectory`
Adds this folder to current target and injects everything into parent target.

## Adding test executables

### `add_test_executable`
Adds a unit test executable.
* In: `INCLUDES` - List of test framework include paths
* In: `DEPENDS` - List of test framework libraries, to be linked with the test executable
* In: `ARGUMENTS` - List of arguments to be passed to the test executable at runtime
> Remark: typically, use specific functions ('add_test_executable_gtest' etc)  

### `add_test_executable_gtest`
Adds a unit test executable, basing on GTest/GMock.
> Remark: the 'main' function is automatically supplied, don't write one yourself  
> Remark: the 'main' function from your tested executable is being automatically removed  

### `add_test_executable_qtest`
Adds a unit test executable, basing on QTest.
> Remark: the 'main' function is automatically supplied, don't write one yourself  
> Remark: the 'main' function from your tested executable is being automatically removed  

### `add_test_executable_catch2`
Adds a test executable, basing on Catch2.
* In: `ARGV` - Arguments passed to test invocation

### `add_test_executable_handcrafted`
Adds a unit test executable without any test framework.
> Remark: you're on your own - provide all source code, including a 'main' function  
* In: `ARGV` - Arguments passed to test invocation

### `add_test_freeform`
Adds a freeform test with given command, dependent on current tested target.
* In: `COMMAND` - Command to be executed
* In: `DEPENDS` - Extra dependencies (with current tested/main target implicitly included)

### `add_test_workspace_directory`
Defines a test workspace directory
> Remark: this directory will be created by CMake and removed in target clean
* Out: `directory` - workspace directory path pointing to framework-chosen location

## Defining test coverage reports

### `coverage_lcov_support_enable`
Adds lcov coverage support
> Remark: invoke this function in scope common to all usages (e.g. on the project declaration level)
> Remark: requires presence of COVERAGE_ANALYZER_TOOL variable set to gcov/llvm-cov/etc by the toolchain file

### `coverage_gcovr_support_enable`
Adds gcovr coverage support
> Remark: invoke this function in scope common to all usages (e.g. on the project declaration level)
> Remark: requires presence of COVERAGE_ANALYZER_TOOL variable set to gcov/llvm-cov/etc by the toolchain file

### `coverage_exclude_files`
Excludes source files from the coverage report
* In: `ARGV` - Excluded source file paths, relative to current list directory

## Installation

### `export_files`
Adds files to be installed in specified directory.
> Remark: regexp can be passed for multiple files  

### `export_directories`
Adds directiories (with files inside it) to be installed.
> Remark: copies directories tree  
> Remark: pattern can be passed, if not all files from dir have to be installed  
> Remark: can copy current dir by giving it EXPORT_CURRENT_DIR param  

### `export_target`
Adds current target to 'install' target.
* In: `target` - target to be exported
> Remark: each target type (lib/binary) can have separate directory to be installed  
> Remark: this function also creates script which helps with further import  
