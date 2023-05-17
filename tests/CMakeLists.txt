find_package(GTest)
include(GoogleTest)
include(Dart)

include(${CMAKE_SOURCE_DIR}/cmake/Tests.cmake)
include(${CMAKE_SOURCE_DIR}/cmake/CodeCoverage.cmake)

set(GCOV_EXECUTABLE gcov)
if(CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
    find_program(LLVM_COV_PATH llvm-cov)
    if(NOT GCOV_PATH)
        message(FATAL_ERROR "llvm-cov not found! Aborting...")
    endif()
    set(GCOV_EXECUTABLE "${LLVM_COV_PATH} gcov")
endif()

set(ALL_TESTS)
set(GCOVR_ADDITIONAL_ARGS --delete --print-summary --gcov-executable "${GCOV_EXECUTABLE}")

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