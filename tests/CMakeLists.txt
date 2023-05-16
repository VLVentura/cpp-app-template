find_package(GTest)
include(GoogleTest)
include(Dart)

include(${CMAKE_SOURCE_DIR}/cmake/Tests.cmake)
include(${CMAKE_SOURCE_DIR}/cmake/CodeCoverage.cmake)

set(ALL_TESTS)
set(GCOVR_ADDITIONAL_ARGS --delete --print-summary)

add_test_target(
    calculator_test 
    calculator_test.cpp 
    ${CMAKE_SOURCE_DIR}/src/math/calculator.cpp
)

setup_target_for_coverage_gcovr_html(
    NAME CodeCoverage
    DEPENDENCIES ${ALL_TESTS}
    EXECUTABLE ctest --test-dir ${CMAKE_BINARY_DIR}
    BASE_DIRECTORY ${CMAKE_SOURCE_DIR}/src
    EXCLUDE ${CMAKE_SOURCE_DIR}/src/main.cpp
)