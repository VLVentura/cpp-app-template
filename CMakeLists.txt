cmake_minimum_required(VERSION 3.16)

# C compiler
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED TRUE)
set(CMAKE_C_EXTENSIONS ON)

# C++ compiler
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED TRUE)
set(CMAKE_CXX_EXTENSIONS ON)

# Both developer and user mode
set(ENABLE_CACHE_DEFAULT ON)
set(ENABLE_CONAN_DEFAULT OFF)

# Developer mode
option(ENABLE_DEVELOPER_MODE "Enable 'developer mode'" TRUE)
option(ENABLE_LOCAL_BUILD_MODE "Enable 'local build mode'" TRUE)
set(ENABLE_COVERAGE_DEVELOPER_DEFAULT ON)
set(CMAKE_UTILITIES_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/cmake)

# Sanitizers
set(ENABLE_SANITIZER_LEAK_DEVELOPER_DEFAULT ON)
set(ENABLE_SANITIZER_MEMORY_DEVELOPER_DEFAULT ON)
set(ENABLE_SANITIZER_THREAD_DEVELOPER_DEFAULT OFF)

# Set output directories from targets
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/out/$<CONFIG>/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/out/$<CONFIG>/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/out/$<CONFIG>/bin)

# Download aminya project options
include(${CMAKE_UTILITIES_DIRECTORY}/DownloadProjectOptions.cmake)
download_project_options()

project(
    TemplateProject
    VERSION 1.0.0
    DESCRIPTION "Template project."
    LANGUAGES C CXX
)

include(${_project_options_SOURCE_DIR}/src/DynamicProjectOptions.cmake)
dynamic_project_options(
    CPPCHECK_OPTIONS
    -i${PROJECT_SOURCE_DIR}/build/
)

target_compile_features(project_options INTERFACE cxx_std_${CMAKE_CXX_STANDARD})

# Conan setup
set(CONAN_DIRECTORY ${CMAKE_BINARY_DIR}/conan/)
include(${CMAKE_UTILITIES_DIRECTORY}/Packages.cmake)
setup_conan()

# Adding third_party that is not in conan center or it is an inside project
set(THIRD_PARTY_PATH ${CMAKE_SOURCE_DIR}/third_party)
include(${CMAKE_UTILITIES_DIRECTORY}/ThirdParty.cmake)
add_third_parties()

# Adding the src:
include_directories(src)
add_subdirectory(src)

# Adding the tests:
option(ENABLE_TESTING "Enable the tests" ON)
if(ENABLE_TESTING)
    enable_testing()

    include(${CMAKE_UTILITIES_DIRECTORY}/ExtraCmakeModules.cmake)
    download_additional_cmake_modules()

    message(STATUS "Building Tests.")
    add_subdirectory(tests)
endif()

option(ENABLE_FUZZING "Enable the fuzz tests" OFF)
if(ENABLE_FUZZING)
    message(STATUS "Building Fuzz Tests, using fuzzing sanitizer https://www.llvm.org/docs/LibFuzzer.html")
    add_subdirectory(fuzz_tests)
endif()
