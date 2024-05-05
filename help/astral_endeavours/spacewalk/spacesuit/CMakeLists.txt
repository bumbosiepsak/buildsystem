add_include_paths(mocks) # Needed for inclusion of "mocks"

# Optional: you can generate files (with absolute paths to test input) this way
configure_file(files/TestFilesPath.h.in ${CMAKE_BINARY_DIR}/files/TestFilesPath.h)

add_test_subdirectories(utest mocks)
