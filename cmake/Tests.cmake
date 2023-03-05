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
endfunction()
