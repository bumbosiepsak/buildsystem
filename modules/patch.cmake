include_guard(GLOBAL)

# There's some kind of bug in CMake, which makes CACHE variables vanishing in toolchain file:
# http://stackoverflow.com/questions/28613394/check-cmake-cache-variable-in-toolchain-file
# http://stackoverflow.com/questions/19854613/cmake-toolchain-include-multiple-files
# We patch it for now by storing their values in the environment
function(patch_toolchain_file_variable name)
    if(${name})
        set(ENV{__${name}__} "${${name}}")
    else()
        set(${name} "$ENV{__${name}__}" PARENT_SCOPE)
    endif()
endfunction(patch_toolchain_file_variable)
