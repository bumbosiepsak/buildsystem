include_guard(GLOBAL)

include(validate)

# Returns current directory leaf (B in /A/B/CMakeLists.txt)
# Out: out_leaf - leaf directory name
function(get_current_list_dir_leaf out_leaf)
    string(REPLACE "/" ";" split_path "${CMAKE_CURRENT_LIST_DIR}")
    list(REVERSE split_path)
    list(GET split_path 0 dir_leaf)
    set(${out_leaf} ${dir_leaf} PARENT_SCOPE)
endfunction(get_current_list_dir_leaf)

# Returns directory parent
# Out: out_parent - parent directory name
# Out: in_dir - directory, which parent is produced
function(get_dir_parent out_parent in_dir)
    string(REPLACE "/" ";" split_path "${in_dir}")
    list(LENGTH split_path split_path_length)
    math(EXPR split_path_length "${split_path_length}-1")
    list(REMOVE_AT split_path ${split_path_length})
    list(JOIN split_path "/" dir_parent)
    set(${out_parent} ${dir_parent} PARENT_SCOPE)
endfunction(get_dir_parent)

# Returns current directory parent (B in /A/B/CMakeLists.txt)
# Out: out_parent - parent directory name
macro(get_current_list_dir_parent out_parent)
    get_dir_parent(${out_parent} "${CMAKE_CURRENT_LIST_DIR}")
endmacro(get_current_list_dir_parent)

# Returns current binary directory parent
# Out: out_parent - parent directory name
macro(get_current_binary_dir_parent out_parent)
    get_dir_parent(${out_parent} "${CMAKE_CURRENT_BINARY_DIR}")
endmacro(get_current_binary_dir_parent)

# Returns a list of objects derived from given OBJECT library target
# In: ARGN list of object target names
# Out: out_target_objects list of generator expressions
function(get_target_objects out_target_objects)
    foreach(target_name ${ARGN})
        list(APPEND target_objects "$<TARGET_OBJECTS:${target_name}>")
    endforeach()

    set(${out_target_objects} ${target_objects} PARENT_SCOPE)
endfunction(get_target_objects)

# Returns if current target hardware matches given targets list
# In: ARGN target names list
# Out: out_matches - 0 or 1
function(get_matches_current_target_hardware out_matches)
    set(${out_matches} 0 PARENT_SCOPE)

    foreach(target_name ${ARGN}) # 'list find' is just to irregular for this
        if(target_name STREQUAL ${TARGET_HARDWARE})
            set(${out_matches} 1 PARENT_SCOPE)
            return()
        endif()
    endforeach()
endfunction(get_matches_current_target_hardware)

# Returns if current target hardware is real or ephemeral
# Out: out_is_hardware_real - 0 or 1
function(get_is_hardware_real out_is_hardware_real)
    validate_variable_set(TARGET_HARDWARE)

    if(TARGET_HARDWARE STREQUAL "none")
        set(${out_is_hardware_real} 0 PARENT_SCOPE)
    else()
        set(${out_is_hardware_real} 1 PARENT_SCOPE)
    endif()
endfunction(get_is_hardware_real)

# Fixes botched-up signature of CMake's "string()". Makes input argument optional.
# In: in_operation string operation to be applied
# In: out_value output variable name
# In: ARGN optional string to be transformed
function(get_string in_operation out_value)
    if(DEFINED ARGV2)
        string(${in_operation} ${ARGV2} result)
    endif()
    set(${out_value} ${result} PARENT_SCOPE)
endfunction(get_string)

# Converts paths list to absolute
# In: ARGN file paths
# Out: out_path
function(get_absolute_file_paths out_paths)
    foreach(filename ${ARGN})
        get_filename_component(f ${filename} ABSOLUTE)

        list(APPEND p ${f})
    endforeach()

    set(${out_paths} ${p} PARENT_SCOPE)
endfunction(get_absolute_file_paths)

# Converts list to string delimited with given separator
# In: input_list - (semicolon separated) list to be converted
# In: separator - string, which will replace default semicolons in lists
# Out: out_string - separator separated list
function(get_string_from_list out_string input_list separator)
    string(REPLACE ";" "${separator}" result "${input_list}")
    set(${out_string} "${result}" PARENT_SCOPE)
endfunction(get_string_from_list)

# Converts string delimited with given separator to a list
# In: input_string - (separator delimited) string to be converted
# In: separator - string, which will be replaced to a semicolons in string
# Out: out_list - separator separated list
function(get_list_from_string out_list input_string separator)
    string(REPLACE "${separator}" ";" result "${input_string}")
    set(${out_list} "${result}" PARENT_SCOPE)
endfunction(get_list_from_string)

# Converts a string to its hash in in_prefix with given in_length
function(get_hash out_result in_string in_length)
    string(MD5 hash "${in_string}")
    string(SUBSTRING "${hash}" 0 ${in_length} hash)
    set(${out_result} "${hash}" PARENT_SCOPE)
endfunction(get_hash out_result in_string)

# Returns a derived ID which plays well with host hardware path length limit
function(get_host_friendly_unique_id out_result in_prefix in_string)
    validate_variable_set(CMAKE_HOST_SYSTEM_NAME)

    if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
        set(length 10)
        get_hash(unique_id ${in_string} ${length})
        set(${out_result} "${in_prefix}${unique_id}" PARENT_SCOPE)
    else()
        string(REGEX REPLACE "[^a-zA-Z0-9-]" "_" unique_id ${in_string})
    endif()

    set(${out_result} "${in_prefix}${unique_id}" PARENT_SCOPE)
endfunction(get_host_friendly_unique_id)

string(ASCII 10 NEST_LIST) # NOTE: Good old line feed (not present in file paths)

# Converts a (string with nested) list to a regular list
function(get_list_from_nested_list out_list input_string)
    get_list_from_string(result ${input_string} ${NEST_LIST})
    set(${out_list} "${result}" PARENT_SCOPE)
endfunction(get_list_from_nested_list)

# Converts a list to a nested list (with delimiters different, than ;)
function(get_nested_list_from_list out_string input_list)
    get_string_from_list(result "${input_list}" "${NEST_LIST}")
    set(${out_string} "${result}" PARENT_SCOPE)
endfunction(get_nested_list_from_list)

# Splits dependencies to file and target dependencies
# REMARK: Needed for the sake of custom targets, which need file dependencies given with "DEPENDS"
# and target dependencies given with "add_dependencies()"
function(get_split_dependencies dependencies out_target_dependencies out_file_dependencies)
    foreach(dependency ${dependencies})
        if(TARGET ${dependency})
            list(APPEND target_dependencies ${dependency})
        else()
            list(APPEND file_dependencies ${dependency})
        endif()
    endforeach()

    set(${out_target_dependencies} ${target_dependencies} PARENT_SCOPE)
    set(${out_file_dependencies} ${file_dependencies} PARENT_SCOPE)
endfunction(get_split_dependencies)

function(get_regexes_from_globs out_regexes)
    string(ASCII 10 UNPRINTABLE) # NOTE: Good old line feed (not present in file paths)

    foreach(glob ${ARGN})
        string(REGEX REPLACE "([.+|$()^])" "[\\1]" glob "${glob}") # NOTE: Make special regex chars explicit
        string(REPLACE "?" "." glob "${glob}")
        string(REPLACE "**" "${UNPRINTABLE}" glob "${glob}")
        string(REPLACE "*" "[^/]*?" glob "${glob}") # NOTE: Lazy /text between path separators/
        string(REPLACE "${UNPRINTABLE}" ".*" glob "${glob}") # NOTE: Eager everything

        set(regexes ${regexes} "${glob}")
    endforeach()
    set("${out_regexes}" ${regexes} PARENT_SCOPE)
endfunction(get_regexes_from_globs)

