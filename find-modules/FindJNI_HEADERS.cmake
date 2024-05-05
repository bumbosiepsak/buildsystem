
# NOTE: Find script for JNI headers only (if linking against full Java is not desired)

find_package(JNI)

include(FindPackageHandleStandardArgs)

find_package_handle_standard_args(JNI_HEADERS
    REQUIRED_VARS JNI_INCLUDE_DIRS
)

if(JNI_HEADERS_FOUND)
    set(JNI_HEADERS_INCLUDE_DIRS ${JNI_INCLUDE_DIRS})
    set(JNI_HEADERS_LIBRARIES "")
    set(JNI_HEADERS_FOUND ${JNI_FOUND})
endif()

if(JNI_HEADERS_FOUND AND NOT TARGET JNI_HEADERS)
    add_library(JNI_HEADERS INTERFACE IMPORTED)
    set_target_properties(JNI_HEADERS PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${JNI_HEADERS_INCLUDE_DIRS}"
    )
endif()
