find_package(GTest)
include(GoogleTest)
include(Dart)

include(${CMAKE_UTILITIES_DIRECTORY}/Tests.cmake)

add_test_target(
    calculator_test 
    calculator_test.cpp 
    ${CMAKE_SOURCE_DIR}/src/math/calculator.cpp
)