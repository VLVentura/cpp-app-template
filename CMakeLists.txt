cmake_minimum_required(VERSION 3.16)

# C compiler
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED TRUE)
set(CMAKE_C_EXTENSIONS ON)

# C++ compiler
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED TRUE)
set(CMAKE_CXX_EXTENSIONS ON)

# Set output directories from targets
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/out/$<CONFIG>/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/out/$<CONFIG>/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/out/$<CONFIG>/bin)

project(
    TemplateProject
    VERSION 1.0.0
    DESCRIPTION "Template project."
    LANGUAGES C CXX
)

# Setup project configurations
include(cmake/ProjectOptions.cmake)
setup_options()
global_options()
local_options()

# Conan setup
set(CONAN_CMAKE_SILENT_OUTPUT TRUE)

set(CONAN_FILE "conanfile.txt" CACHE STRING "Conanfile to search for packages")
set(CONAN_DIRECTORY ${CMAKE_BINARY_DIR}/conan/)

message(STATUS "Conanfile: ${CONAN_FILE}")

include(cmake/conan.cmake)
conan_cmake_install(
    PATH_OR_REFERENCE 
        ${CMAKE_SOURCE_DIR}/${CONAN_FILE}
    INSTALL_FOLDER 
        ${CONAN_DIRECTORY}
    BUILD 
        missing
    PROFILE_BUILD 
        default
    SETTINGS_HOST
        build_type=${CMAKE_BUILD_TYPE}
)
list(APPEND CMAKE_MODULE_PATH ${CONAN_DIRECTORY})

# Adding third_party that is not in conan center or it is an inside project
set(THIRD_PARTY_PATH ${CMAKE_SOURCE_DIR}/third_party)
include(cmake/ThirdParty.cmake)
add_third_parties()

# Adding the src:
include_directories(src)
add_subdirectory(src)

# Adding the tests:
option(ENABLE_TESTING "Enable the tests" ON)
if(ENABLE_TESTING)
    enable_testing()
    message(STATUS "Building Tests.")
    add_subdirectory(tests)
endif()

option(ENABLE_FUZZING "Enable the fuzz tests" OFF)
if(ENABLE_FUZZING)
    message(STATUS "Building Fuzz Tests, using fuzzing sanitizer https://www.llvm.org/docs/LibFuzzer.html")
    add_subdirectory(fuzz_tests)
endif()
