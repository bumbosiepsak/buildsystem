include_guard(GLOBAL)

include(get)

function(opencv_define_directives directives)
    if(directives)
        list(LENGTH directives directives_length)
        math(EXPR directives_length "${directives_length}-1")

        foreach(directive_name_index RANGE 0 ${directives_length} 2)
            math(EXPR directive_value_index "${directive_name_index}+1")

            if(directive_value_index GREATER directives_length)
                print_fatal_error("Expecting an even amount of OpenCV DIRECTIVES (key/value pairs)")
            endif()

            list(GET directives ${directive_name_index} directive_name)
            list(GET directives ${directive_value_index} directive_value)

            set("${directive_name}" "${directive_value}" CACHE INTERNAL "FindOpenCV directive" FORCE)
        endforeach()
    endif()
endfunction(opencv_define_directives)

# Enables OpenCV support for given sub-packages
# In COMPONENTS: list of required OpenCV components (e.g. opencv_core, opencv_imgcodecs etc.)
# In DIRECTIVES: list of key/value pairs controlling the discovery process (see docs of FindOpenCV.cmake)
# Remark: invoke this function in scope common to all usages (e.g. on the project declaration level)
macro(opencv_support_enable)
    cmake_parse_arguments(ARGS
        ""
        ""
        "COMPONENTS;DIRECTIVES"
        ${ARGN}
    )
    if(OpenCV_STATIC IN_LIST ARGS_DIRECTIVES)
        set(opencv_static ON)
    else()
        set(opencv_static OFF)
    endif()

    set(OpenCV_STATIC ${opencv_static} CACHE INTERNAL "Selects static OpenCV libraries" FORCE)

    get_is_hardware_real(is_hardware_real)

    if(is_hardware_real)
        set(OPENCV_SUPPORT 1)
        find_package(OpenCV CONFIG REQUIRED COMPONENTS ${ARGS_COMPONENTS})

        set(INCLUDE_WHAT_YOU_USE_MAPPING_FILES ${INCLUDE_WHAT_YOU_USE_MAPPING_FILES}
            "${FRAMEWORK_LIB_PATH}/extras/include-what-you-use/opencv.imp"
        )
    endif()
endmacro(opencv_support_enable)
