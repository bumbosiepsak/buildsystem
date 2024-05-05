# This is a template for CMakeLists.txt file for mid-level project (like "libs" or "maxwell-core")
# Customise and place this file in your project's root.
# Order of commands in this file DOES MATTER.

cmake_minimum_required(VERSION 3.13.4 FATAL_ERROR)
cmake_policy(VERSION 3.13.4)

include(main)

# Your mid-level project name goes here. Replace 'libs' with your name, matching the directory name
project(libs IMPLICIT_SDK_DIR)

# Intentionally placed after commandline parsing (for proper CMAKE_TOOLCHAIN_FILE processing)
# ENABLED_LANGUAGES is being set by the toolchain file
project(libs LANGUAGES ${ENABLED_LANGUAGES})

# See 'breathing' subdirectory for what needs to sit in there
add_project_subdirectories(breathing)

project_end()
