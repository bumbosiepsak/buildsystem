# This is a sample for CMakeLists.txt file handling subdirectories with code.

# Mandatory first line
add_target()

# Header files only needed, if QT used
add_source_files(
    *.cpp *.h
)

# You can print diagnostic information. See libs/cmake/print.cmake for reference
#print_all_source_files("funky place")

# If QT user interface files present here
add_user_interface_files(*.ui)

# Source subdirectories can be nested
add_source_subdirectories(other-kitch)

# Mandatory last line
add_this_subdirectory()
