# This is a template for CMakeLists.txt file handling GTest/GMock unit test.
# Customise and place this file in a folder named "utest", in your executable/library main folder.
# Order of commands in this file DOES MATTER.

# Mandatory first line (here adds to utest - mtest, ptest and mantest possible)
add_test_target(utest)

# Optional: this will remove all your tested sources and use only specified below
# Remark: you don't need this section, if your tests compile fine with all tested source files
# Remark: 'pick_tested_source_files' must go before 'add_source_files'
pick_tested_source_files(../Abc.cpp ../Def.cpp)

# You can print diagnostic information. See libs/cmake/print.cmake for reference
#print_all_source_files("funky place")

# This will capture your test sources. ATTENTION: file with (GTest/QTest) 'main' function not needed
add_source_files(
    *.cpp */*.cpp */*/*.cpp
)

# Optional: this will add extra dependencies to your tested dependencies
add_target_dependencies(log)

# Optional: this will remove all dependencies and add ones specified
pick_target_dependencies(log)

# This will create a unit test executable, named xyz-utest (where xyz is your main executable/library name)
add_test_executable_gtest()

# Alternatively, if QTest used
#add_test_executable_qtest()

# Alternatively, if handcrafted test binary used (without any test framework, with own 'main')
#add_test_executable_handcrafted()
