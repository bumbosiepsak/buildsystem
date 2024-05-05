
# Auto-generated CMake find script for libraries built from source

set(libname @target_name@)

STRING(TOUPPER "${libname}" LIBNAME)

find_library(${LIBNAME}_LIBRARIES ${libname})

include(FindPackageHandleStandardArgs)

FIND_PACKAGE_HANDLE_STANDARD_ARGS(${libname}
    DEFAULT_MSG
    ${LIBNAME}_LIBRARIES
)

if(${LIBNAME}_FOUND AND NOT TARGET ${LIBNAME})
    add_library(${LIBNAME} INTERFACE IMPORTED)
    set_target_properties(${LIBNAME} PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${${LIBNAME}_INCLUDE_DIRS}" @interface_include_directories@
        INTERFACE_LINK_LIBRARIES "${LIBNAME}_LIBRARIES" @interface_link_libraries@
    )
endif()
