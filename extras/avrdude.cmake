include_guard(GLOBAL)

include(tools)

# Enables AvrDude support
# In COMPONENTS:
# Remark: invoke this function in scope common to all usages (e.g. on the project declaration level)
macro(avrdude_support_enable)
    cmake_parse_arguments(ARGS
        ""
        ""
        "COMPONENTS;DIRECTIVES"
        ${ARGN}
    )

    get_is_hardware_real(is_hardware_real)

    if(is_hardware_real)
        set(AVRDUDE_SUPPORT 1)

        tools_find_simple(AVR_UPLOAD avrdude avrdude.exe)

        set(AVR_UPLOAD_OPTIONS
            -p ${AVR_MCU}
            -c ${AVR_UPLOAD_PROGRAMMER}
            -b ${AVR_UPLOAD_BAUDRATE}
            -P ${AVR_UPLOAD_PORT}
            -v
        )

        function(add_deploy_targets)
            add_custom_target(
                deploy_flash_${CURRENT_TARGET_MAIN}
                COMMAND ${AVR_UPLOAD}
                    ${AVR_UPLOAD_OPTIONS}
                    -U "flash:w:$<TARGET_FILE:${CURRENT_TARGET_MAIN}>_flash.hex"
                COMMENT "Deploying FLASH of ${CURRENT_TARGET_MAIN} to ${AVR_MCU} using ${AVR_UPLOAD_PROGRAMMER}"
                VERBATIM
            )
            add_dependencies(deploy deploy_flash_${CURRENT_TARGET_MAIN})

            add_custom_target(
                deploy_eeprom_${CURRENT_TARGET_MAIN}
                COMMAND ${AVR_UPLOAD}
                    ${AVR_UPLOAD_OPTIONS}
                    -U "eeprom:w:$<TARGET_FILE:${CURRENT_TARGET_MAIN}>_eeprom.hex:i"
                COMMENT "Deploying EEPROM of ${CURRENT_TARGET_MAIN} to ${AVR_MCU} using ${AVR_UPLOAD_PROGRAMMER}"
                VERBATIM
            )
#            add_dependencies(deploy deploy_eeprom_${CURRENT_TARGET_MAIN}) FIXME: Not supported by all boards
        endfunction(add_deploy_targets)

        add_custom_target(
            get_status
            ${AVR_UPLOAD}
                ${AVR_UPLOAD_OPTIONS}
                -n
                -v
            COMMENT "Getting status of ${AVR_MCU} attached to ${AVR_UPLOAD_PORT}"
        )

        add_custom_target(
            get_fuses
            ${AVR_UPLOAD}
                ${AVR_UPLOAD_OPTIONS}
                -n
                -U lfuse:r:-:b
                -U hfuse:r:-:b
            COMMENT "Getting fuses of ${AVR_MCU} attached to ${AVR_UPLOAD_PORT}"
        )

        add_custom_target(
            set_fuses
            ${AVR_UPLOAD}
                ${AVR_UPLOAD_OPTIONS}
                -U lfuse:w:${FUSE_L}:m
                -U hfuse:w:${FUSE_H}:m
            COMMENT "Setting fuses of ${AVR_MCU} attached to ${AVR_UPLOAD_PORT} to ${FUSE_H}:${FUSE_H}"
        )

        file(TO_NATIVE_PATH "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/oscillator_callibration.txt" OSCILLATOR_CALLIBRATION)

        add_custom_target(
            get_calibration
            ${AVR_UPLOAD}
                ${AVR_UPLOAD_OPTIONS}
                -U "calibration:r:${OSCILLATOR_CALLIBRATION}:r"
            COMMENT "Getting internal oscillator calibration status of ${AVR_MCU} attached to ${AVR_UPLOAD_PORT} to ${OSCILLATOR_CALLIBRATION}"
        )

#        add_custom_target(
#            set_calibration
#            ${AVR_UPLOAD}
#                ${AVR_UPLOAD_OPTIONS}
#                -U calibration:w:${AVR_MCU}_calib.hex
#            COMMENT "Setting internal oscillator calibration status of ${AVR_MCU} attached to ${AVR_UPLOAD_PORT}"
#        )
    else()
        function(add_deploy_targets)
        endfunction(add_deploy_targets)
    endif()
endmacro(avrdude_support_enable)
