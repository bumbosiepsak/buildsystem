# This is a sample for CMakeLists.txt file handling GTest/GMock unit test.
# Customise and place this file in your executable main folder.
# Order of commands in this file DOES MATTER.

# Mandatory first line. Executable will be named "libbreathing.so/.a"
add_target(breathing)

# You can exclude building this target from a particular main target (e.g. if there is a x86 lib lacking for it)
add_excluded_target_hardware("host")

add_source_files(
    /abc/def/ghy.cpp # Absolute paths work
    sticky/goey.cpp # Relative paths work
    *.cpp # Globbing expressions work
    *.h # Header files needed, if QT is being used
)

# Needed, if QT iterface files are being used
add_user_interface_files(*.ui)

# Needed, if QT resource files are being used
add_resource_files(*.qrc)

# Needed, if QT translation files are being used
add_translation_files(*.ts)

# Dependencies to other libraries
add_target_dependencies(
    libglory zmq # The dependency needs a "Find-module.cmake" file: built-in, or custom in cmake/find-modules
)

# You can use hierarchical approach. Use 'add_source_subdirectories' and let these folders handle themselves
# Remark: place folders in order of dependence
add_source_subdirectories(mouthpiece)

# Mandatory last line
# If building a shared/dynamic library:
add_library_shared()

# Mandatory last line
# If building a static library:
#add_library_static()

# Subdirectory with tests
# Remark: this needs to go after 'add_library_shared/add_library_static'
add_test_subdirectories(utest)

# You can include/exclude files locally from a particular convention check
conventions_exclude_files(
    format_cpp want_it_bad.cpp # Paths are always anchored in current list directory
)
