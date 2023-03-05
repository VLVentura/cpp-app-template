include_guard()

macro(format_code)
  # Search for the clang-format program
  find_program(CLANG_FORMAT_EXECUTABLE
              NAMES clang-format-15 clang-format-14 clang-format-13 clang-format-12
                    clang-format-11 clang-format-10
              PATHS /usr/bin /usr/local/bin /opt/local/bin)

  # Check if clang-format was found
  if(CLANG_FORMAT_EXECUTABLE)
    message(STATUS "Found clang-format: ${CLANG_FORMAT_EXECUTABLE}")
  else()
    message(FATAL_ERROR "clang-format not found.")
  endif()

  file(GLOB_RECURSE src_files 
    ${CMAKE_SOURCE_DIR}/src/*.h ${CMAKE_SOURCE_DIR}/src/*.cpp
    ${CMAKE_SOURCE_DIR}/tests/*.h ${CMAKE_SOURCE_DIR}/tests/*.cpp
    ${CMAKE_SOURCE_DIR}/fuzz_tests/*.h ${CMAKE_SOURCE_DIR}/fuzz_tests/*.cpp)

  foreach(file ${src_files})
    execute_process(
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
      COMMAND ${CLANG_FORMAT_EXECUTABLE} -i --style=file ${file})
  endforeach()
endmacro()
