include_guard()

include(cmake/StaticAnalyzers.cmake)

function(add_test_target target_name)
    add_executable(${target_name} ${ARGN})

    target_link_libraries(
        ${target_name} 
        PRIVATE 
            project_options 
            project_warnings
    )
    target_link_system_libraries(
        ${target_name}
        PRIVATE
            GTest::gtest_main
    )
    
    # target_compile_options(
    #     ${target_name} PRIVATE -Wno-global-constructors)

    # target_disable_static_analysis(${target_name})

    gtest_discover_tests(${target_name})
    list(APPEND ${ALL_TESTS} ${target_name})
endfunction()

function(enable_coverage project_name)
  if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
    target_compile_options(${project_name} INTERFACE --coverage -O0 -g)
    target_link_libraries(${project_name} INTERFACE --coverage)
  endif()
endfunction()
