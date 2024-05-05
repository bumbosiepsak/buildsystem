include_guard(GLOBAL)

include(print)
include(tools)

# Enables ST-LINK support
# In COMPONENTS:
# Remark: invoke this function in scope common to all usages (e.g. on the project declaration level)
macro(stlink_support_enable)
    cmake_parse_arguments(ARGS
        ""
        ""
        "COMPONENTS;DIRECTIVES"
        ${ARGN}
    )

    get_is_hardware_real(is_hardware_real)

    if(is_hardware_real)
        if(TARGET add_deploy_targets)
            print_fatal_error("Conflicting deployment methods specified: stlink and some other")
        endif()

        set(STLINK_SUPPORT 1)

        tools_find_simple(ST_FLASH st-flash st-flash.exe)

        set(deploy_upload_options
            --reset
            --format ihex
        )

        function(add_deploy_targets)
            add_custom_target(
                deploy_${CURRENT_TARGET_MAIN}
                COMMAND ${ST_FLASH}
                    ${deploy_upload_options}
                    write "$<TARGET_FILE:${CURRENT_TARGET_MAIN}>.hex"
                COMMENT "Deploying ${CURRENT_TARGET_MAIN} to ${ARM_CHIP_NAME}"
                VERBATIM
            )
            add_dependencies(deploy deploy_${CURRENT_TARGET_MAIN})
        endfunction(add_deploy_targets)

        add_custom_target(
            erase
            COMMAND ${ST_FLASH}
                ${deploy_upload_options}
                erase
            COMMENT "Erasing ${ARM_CHIP_NAME}"
            VERBATIM
        )

        set(stlink_output_file "${CMAKE_CURRENT_BINARY_DIR}/read.hex")

        add_custom_target(
            read
            COMMAND ${ST_FLASH}
                ${deploy_upload_options}
                read "${stlink_output_file}" "${ARM_FLASH_ORIGIN}" "${ARM_FLASH_SIZE}k"
            BYPRODUCTS "${stlink_output_file}"
            COMMENT "Reading connected board to ${stlink_output_file}"
            VERBATIM
        )
    else()
        function(add_deploy_targets)
        endfunction(add_deploy_targets)
    endif()
endmacro(stlink_support_enable)
