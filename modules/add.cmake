include_guard(GLOBAL)

include(get)

# Instantiate hardware-specific project traversal and processing
macro(add_instatiate)
    get_is_hardware_real(is_hardware_real)

    if(is_hardware_real)
        include(add-for-hardware-real)
    else()
        include(add-for-hardware-none)
    endif()
endmacro(add_instatiate)
