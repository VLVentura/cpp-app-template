include_guard()

function(add_test_target target_name)
    add_executable(${target_name} ${ARGN})
    
    target_link_libraries(
        ${target_name} PRIVATE project_options project_warnings GTest::gtest_main)
    target_compile_options(
        ${target_name} PRIVATE -Wno-global-constructors)
    
    include(${_project_options_SOURCE_DIR}/src/StaticAnalyzers.cmake)
    target_disable_static_analysis(${target_name})

    gtest_discover_tests(${target_name})

    if(NOT ${USE_GCOVR_TOOL})
        include(${CMAKE_UTILITIES_DIRECTORY}/ExtraCmakeModules.cmake)
        include_cmake_module(CodeCoverage)

        set(GCOVR_ADDITIONAL_ARGS --delete --print-summary)
        setup_target_for_coverage_gcovr_html(
            NAME ${target_name}_coverage
            DEPENDENCIES ${target_name}
            EXECUTABLE ctest -C ${CMAKE_BINARY_DIR}
            BASE_DIRECTORY ${CMAKE_SOURCE_DIR}/src
            EXCLUDE ${CMAKE_SOURCE_DIR}/src/main.cpp
        )
    endif()
endfunction()
