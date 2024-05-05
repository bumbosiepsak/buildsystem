# This is a template for CMakeLists.txt file for mid-level project (like "libs")
# The intent of a mid-level project is to be able to build individual sub-projects with injected toolchains
# Customise and place this file in your project's root.
# Order of commands in this file DOES MATTER.

cmake_minimum_required(VERSION 3.13.4 FATAL_ERROR)
cmake_policy(VERSION 3.13.4)

include(main)

# Your mid-level project name goes here. Replace 'libs' with your name, matching the directory name
project(spacewalk IMPLICIT_SDK_DIR) # You NEED to use a magic "IMPLICIT_SDK_DIR" string here to force the mid-level mode

# See 'breathing' subdirectory for what needs to sit in there
add_project_subdirectories(breathing)

project_end()
