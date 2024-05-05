
if(NOT TARGET ld)
    add_library(ld INTERFACE IMPORTED)

    if(CMAKE_DL_LIBS)
        set_target_properties(ld PROPERTIES
            INTERFACE_LINK_LIBRARIES "${CMAKE_DL_LIBS}"
        )
    endif()
endif()
