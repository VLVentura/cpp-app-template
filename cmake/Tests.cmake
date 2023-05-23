include_guard()

include(cmake/StaticAnalyzers.cmake)
include(${CMAKE_SOURCE_DIR}/cmake/PackageProject.cmake)

function(add_test_target)
    set(options "")
    set(oneValueArgs TEST_TARGET_NAME TEST_TARGET_SRC)
    set(multiValueArgs TEST_DEPENDENCIES TEST_EXTRA_PACKAGES TEST_LIBRARIES_NAME)
    cmake_parse_arguments(ARGUMENTS "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    add_executable(${ARGUMENTS_TEST_TARGET_NAME} ${ARGUMENTS_TEST_TARGET_SRC} ${ARGUMENTS_TEST_DEPENDENCIES})

    target_link_libraries(
        ${ARGUMENTS_TEST_TARGET_NAME}
        PRIVATE 
            project_options 
            project_warnings
    )

    target_find_dependencies(
        ${ARGUMENTS_TEST_TARGET_NAME}
        PRIVATE
            ${ARGUMENTS_TEST_EXTRA_PACKAGES}
    )

    target_link_system_libraries(
        ${ARGUMENTS_TEST_TARGET_NAME}
        PRIVATE
            GTest::gtest_main
            ${ARGUMENTS_TEST_LIBRARIES_NAME}
    )

    target_compile_options(${ARGUMENTS_TEST_TARGET_NAME} PRIVATE -Wno-global-constructors)
    gtest_discover_tests(${ARGUMENTS_TEST_TARGET_NAME})
    list(APPEND ${ALL_TESTS} ${ARGUMENTS_TEST_TARGET_NAME})
endfunction()

function(enable_coverage project_name)
  if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
    target_compile_options(${project_name} INTERFACE --coverage -O0 -g)
    target_link_libraries(${project_name} INTERFACE --coverage)
  endif()
endfunction()
