include_guard()

macro(download_project_options)
    include(FetchContent)

    FetchContent_Declare(
        _project_options 
        URL https://github.com/aminya/project_options/archive/refs/tags/v0.26.2.zip
        DOWNLOAD_EXTRACT_TIMESTAMP TRUE
    )
    FetchContent_GetProperties(_project_options)
    if(NOT _project_options_POPULATED)
        FetchContent_Populate(_project_options)
    endif()

    include(${_project_options_SOURCE_DIR}/Index.cmake)
endmacro()
