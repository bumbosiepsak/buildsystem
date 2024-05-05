include_guard(GLOBAL)

function(dict_init name)
    add_library("${name}" INTERFACE IMPORTED)
endfunction(dict_init)

function(dict_set name key)
    set_property(TARGET "${name}" PROPERTY "INTERFACE_${key}" ${ARGN})
endfunction(dict_set)

function(dict_delete name key)
    dict_set("${name}" "${key}")
endfunction(dict_delete)

macro(dict_get name key out_value)
    get_property(${out_value} TARGET "${name}" PROPERTY "INTERFACE_${key}")
endmacro(dict_get)

macro(dict_get_return name key out_value)
    set(${out_value} ${${out_value}} PARENT_SCOPE)
endmacro(dict_get_return)

function(dict_append name key)
    set_property(TARGET "${name}" APPEND PROPERTY "INTERFACE_${key}" ${ARGN})
endfunction(dict_append)

# (Global) dictionary type
function(dict)
    cmake_parse_arguments(OP
        "GET;SET;APPEND;DELETE"
        ""
        ""
        ${ARGN}
    )

    if(OP_GET)
        dict_get(${OP_UNPARSED_ARGUMENTS})
        dict_get_return(${OP_UNPARSED_ARGUMENTS})
    elseif(OP_SET)
        dict_set(${OP_UNPARSED_ARGUMENTS})
    elseif(OP_APPEND)
        dict_append(${OP_UNPARSED_ARGUMENTS})
    elseif(OP_DELETE)
        dict_delete(${OP_UNPARSED_ARGUMENTS})
    else()
        dict_init(${OP_UNPARSED_ARGUMENTS})
    endif()
endfunction(dict)
