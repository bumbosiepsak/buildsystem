include_guard(GLOBAL)

include(get)
include(print)

set(EXTRAS_DIR ${CMAKE_CURRENT_LIST_DIR}) # Fetch the "real" dir path of the current file

function(qt4_validate_qmake)
    if(NOT QT_QMAKE_EXECUTABLE)
        print_fatal_error("Finding qmake for Qt4 failed")
    endif()
endfunction(qt4_validate_qmake)

function(qt4_support_setup)
    if(NOT DEFINED QT_QMAKE_EXECUTABLE)
        find_program(QT_QMAKE_EXECUTABLE NAMES qmake qmake.exe)

        get_matches_current_target_hardware(not_doing_crosscompilation ${HOST_HARDWARE})

        if(${not_doing_crosscompilation})
            qt4_validate_qmake()
        else() # QT libraries are missing for host in SDK (should be fixed)
            find_program(QT_QMAKE_EXECUTABLE_REALPATH NAMES qmake qmake.exe CMAKE_FIND_ROOT_PATH_BOTH)
            qt4_validate_qmake()

            set(QT_QMAKE_EXECUTABLE_DIR "${CMAKE_BINARY_DIR}/qmake-custom")

            configure_file(
                "${EXTRAS_DIR}/qt4.conf"
                "${QT_QMAKE_EXECUTABLE_DIR}/qt.conf"
                @ONLY
            )

            get_filename_component(
                QT_QMAKE_EXECUTABLE_NAME
                "${QT_QMAKE_EXECUTABLE_REALPATH}"
                NAME
            )

            file(COPY "${QT_QMAKE_EXECUTABLE_REALPATH}"
                DESTINATION "${QT_QMAKE_EXECUTABLE_DIR}/${QT_QMAKE_EXECUTABLE_NAME}"
            )

            set(QT_QMAKE_EXECUTABLE "${QT_QMAKE_EXECUTABLE_DIR}/${QT_QMAKE_EXECUTABLE_NAME}"
                CACHE PATH "qmake executable customised for current target hardware"
            )
        endif()
    endif()
endfunction(qt4_support_setup)

# Enables Qt4 support for given sub-packages
# In COMPONENTS: list of required Qt4 components (e.g. QtCore, QtGui etc.)
# Remark: invoke this function in scope common to all usages (e.g. on the project declaration level)
macro(qt4_support_enable)
    cmake_parse_arguments(ARGS
        ""
        ""
        "COMPONENTS"
        ${ARGN}
    )

    get_is_hardware_real(is_hardware_real)

    if(is_hardware_real)
        set(QT_SUPPORT 1)
        qt4_support_setup()
        find_package(Qt4 REQUIRED COMPONENTS ${ARGS_COMPONENTS})

        set(INCLUDE_WHAT_YOU_USE_MAPPING_FILES ${INCLUDE_WHAT_YOU_USE_MAPPING_FILES}
            "include-what-you-use/qt4.imp"
        )
    endif()
endmacro(qt4_support_enable)
