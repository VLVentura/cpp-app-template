include_guard()

macro(download_additional_cmake_modules)
    include(FetchContent)

    FetchContent_Declare(
        additional_cmake_modules 
        GIT_REPOSITORY https://github.com/bilke/cmake-modules.git
        GIT_TAG 877bab9dd1b17468c5d939cacaa2ad7ba99d1977 # last update on master
        DOWNLOAD_EXTRACT_TIMESTAMP TRUE
    )
    FetchContent_GetProperties(additional_cmake_modules)
    if(NOT additional_cmake_modules_POPULATED)
        FetchContent_Populate(additional_cmake_modules)
    endif()
endmacro()

function(include_cmake_module module_name)
    include(${additional_cmake_modules_SOURCE_DIR}/${module_name}.cmake)
endfunction()
