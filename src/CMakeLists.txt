find_packages(fmt spdlog nlohmann_json CLI11 Threads)
include_third_parties()

# To find a specific library on the system that does not have CMake support:
#   find_library(UUID_LIBRARY uuid REQUIRED)
#
# And in target_link_libraries use as:
#   ${UUID_LIBRARY}
#
# To include directories as a system directory, use:
#   include_directories(SYSTEM ${directory})

file(GLOB math math/*.cpp)

add_executable(
    main
        main.cpp
        ${math})
target_link_libraries(
    main
    PRIVATE project_options
            project_warnings
    PRIVATE fmt::fmt 
            spdlog::spdlog
            Threads::Threads
)