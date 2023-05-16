include_guard()

include(cmake/StaticAnalyzers.cmake)
include(cmake/Utilities.cmake)

macro(add_third_parties)
    foreach(third_party ${ARGN})
        add_subdirectory(${THIRD_PARTY_PATH}/${third_party})
    endforeach()

    get_all_targets(TARGETS)
    foreach(target ${TARGETS})
        target_disable_static_analysis(${target})
    endforeach()
endmacro()

macro(include_third_parties)
    foreach(include_directory ${ARGN})
        include_directories(SYSTEM ${THIRD_PARTY_PATH}/${include_directory})
    endforeach()
endmacro()

