find_package(GTest)
include(GoogleTest)
include(Dart)

include(${CMAKE_UTILITIES_DIRECTORY}/Tests.cmake)
include(${CMAKE_UTILITIES_DIRECTORY}/ExtraCmakeModules.cmake)
include_cmake_module(CodeCoverage)

add_test_target(calculator_test calculator_test.cpp ${CMAKE_SOURCE_DIR}/src/math/calculator.cpp)

set(GCOVR_ADDITIONAL_ARGS --delete --print-summary)
setup_target_for_coverage_gcovr_html(
    NAME CodeCoverage
    DEPENDENCIES calculator_test
    EXECUTABLE ctest -C ${CMAKE_BINARY_DIR}
    BASE_DIRECTORY ${CMAKE_SOURCE_DIR}/src
    EXCLUDE ${CMAKE_SOURCE_DIR}/src/main.cpp
)