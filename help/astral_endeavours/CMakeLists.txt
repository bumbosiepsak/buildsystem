# This is a sample file for defining top level projects

cmake_minimum_required(VERSION 3.13.4 FATAL_ERROR)
cmake_policy(VERSION 3.13.4)

# Must append the path, where "main.cmake" is, so that you can include it directly
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/source/cmake/modules")

include(main)

# Define toolchains for your project here
toolchain_configure(
    FOR_HOST_HARDWARE "linux_x86_64" # The hardware you're compiling on (derived from what uname returns)
    FOR_TARGET_HARDWARE "linux_x86_64" # The hardware you're compiling for (selected with -DH=... option)
    FOR_TOOLCHAIN_TYPE "gcc" # The toolchain type you're compiling with (selected with -DT=... option)
    WITH_FILE "build-on-linux_x86_64-for-linux_x86_64-gcc8" # The toolchain file to be used for settings above
)

toolchain_configure(
    FOR_HOST_HARDWARE "windows_amd64"
    FOR_TARGET_HARDWARE "windows_amd64"
    FOR_TOOLCHAIN_TYPE "msvc"
    WITH_FILE "build-on-windows_amd64-for-windows_amd64-msvc142"
)

# Conventions is also a toolchain
toolchain_configure(
    FOR_HOST_HARDWARE "windows_amd64"
    FOR_TARGET_HARDWARE "none" # Conventions must apply to hardware named "none"
    FOR_TOOLCHAIN_TYPE "conventions"
    WITH_FILE "build-on-anything-for-none-conventions"
)

# This sets up your project.
# Must be placed after toolchains declarations (so that the toolchain file gets properly ingested)
project(astral_endeavours # Replace 'astral_endeavours' with your project name
        SDK_DIR_A1001 # Environment variable name, containing (optional) SDK path for astral_endeavours
)

# Define conventions you want to apply to your project
conventions_define(
    file_encoding # Convention name. apply_file_encoding.py and check_file_encoding.py scripts must exist
    DESCRIPTION "Text files are encoded in UTF-8"
    FOR_FILES ** # You can use universal globs and concrete paths here
)

conventions_define(
    format_cpp
    DESCRIPTION "C++ source code is formatted by a machine"
    FOR_FILES **/*.c **/*.cc **/*.cpp **/*.h **/*.hpp
)

conventions_define(
    format_json
    DESCRIPTION "JSON source code is formatted by a machine"
    FOR_FILES **/*.json # You can include here or in local CMakeList.txt, using conventions_include_files()
    EXCLUDING_FILES **/botched_up_forever.json # You can exclude here or locally, using conventions_exclude_files()
)

# Needed, if Boost is being used in the project
boost_support_enable(
    COMPONENTS chrono
               date_time
               filesystem
               graph
               iostreams
               program_options
               regex
               serialization
               signals
               system
               thread
)

# Needed, if OpenCV is being used in the project
opencv_support_enable(
    COMPONENTS opencv_core opencv_imgproc opencv_imgcodecs
)

# Needed, if Qt4 is being used in the project
qt4_support_enable(
    COMPONENTS QtCore
               QtGui
               QtNetwork
               QtXml
               QtXmlPatterns
               QtSql
               QtTest
)

# All subprojects listed here
add_project_subdirectories(libs spacewalk)

project_end() # Mandatory at the end, does some final setup
