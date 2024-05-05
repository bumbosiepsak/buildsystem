include_guard(GLOBAL)

include(add)
include(get)
include(print)
include(tools)

# Creates a target for generating a JNI header and appends it to current target's dependencies
# In: CLASS - path to Java file containing the interface prototype
# In: HEADER - path to generated C++ header file
function(jni_header_generate)
    cmake_parse_arguments(ARGS
        ""
        "CLASS;HEADER"
        ""
        ${ARGN}
    )

    if(IS_CURRENT_TARGET_ENABLED)
        get_filename_component(header_directory ${ARGS_HEADER} DIRECTORY)

        string(REGEX REPLACE ".*/src/main/java/(.*)[.]java" "\\1" header_new "${ARGS_CLASS}")
        set(class_file "${CMAKE_CURRENT_BINARY_DIR}/${header_new}.class")
        string(REPLACE "/" "_" header_new "${header_new}")
        set(header_new "${header_directory}/${header_new}.h")
        set(header_current "${ARGS_HEADER}")

        get_host_friendly_unique_id(target_name "zz" "${header_current}")
        add_custom_target(${target_name}
            COMMENT "Generating JNI header: ${header_current}"
            COMMAND ${JAVAC} -h "${header_directory}" -d "${CMAKE_CURRENT_BINARY_DIR}" "${ARGS_CLASS}"
            COMMAND ${CMAKE_COMMAND} -E copy_if_different "${header_new}" "${header_current}"
            COMMAND ${CMAKE_COMMAND} -E remove -f "${header_new}"
            BYPRODUCTS
                "${header_new}"
                "${class_file}"
                "${header_current}"
        )

        set(ALL_DEPENDENCIES ${ALL_DEPENDENCIES} ${target_name} PARENT_SCOPE)
    endif()
endfunction(jni_header_generate)

# Enables JNI support
# Remark: invoke this function in scope common to all usages (e.g. on the project declaration level)
macro(jni_support_enable)
    get_is_hardware_real(is_hardware_real)

    if(is_hardware_real)
        set(JNI_SUPPORT 1)
        tools_find_simple(JAVAC javac javac.exe)

        set(INCLUDE_WHAT_YOU_USE_MAPPING_FILES ${INCLUDE_WHAT_YOU_USE_MAPPING_FILES}
            "${FRAMEWORK_LIB_PATH}/extras/include-what-you-use/jni.imp"
        )
    endif()
endmacro(jni_support_enable)
