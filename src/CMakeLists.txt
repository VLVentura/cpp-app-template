# To find a specific library on the system that does not have CMake support:
#   find_library(UUID_LIBRARY uuid REQUIRED)
#
# And in target_link_libraries use as:
#   ${UUID_LIBRARY}
#
# To include directories as a system directory, use:
#   include_directories(SYSTEM ${directory})

include(${CMAKE_SOURCE_DIR}/cmake/PackageProject.cmake)

include_third_parties()

file(GLOB math math/*.cpp)

add_executable(
    main 
        main.cpp 
        ${math}
)

target_link_libraries(
    main
    PRIVATE
        project_options
        project_warnings
)

target_find_dependencies(
    main
    PRIVATE
        fmt
        spdlog
        nlohmann_json
        CLI11
        absl
        Protobuf
        Threads
)

target_link_system_libraries(
    main
    PRIVATE
        fmt::fmt
        spdlog::spdlog
        nlohmann_json::nlohmann_json
        CLI11::CLI11
        protobuf::libprotobuf
        Threads::Threads
)