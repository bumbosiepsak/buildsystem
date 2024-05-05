include_guard(GLOBAL)

include(get)

# Instantiate hardware-specific project traversal and processing
macro(export_instatiate)
    get_is_hardware_real(is_hardware_real)

    if(is_hardware_real)
        include(conventions-for-hardware-real)
    else()
        include(conventions-for-hardware-none)
    endif()
endmacro(export_instatiate)
