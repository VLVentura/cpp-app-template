include_guard()

function(install_conan_packages)
  if (ENABLE_LOCAL_BUILD_MODE)
    message(STATUS "Local build mode is ON, to disable it use `-DENABLE_LOCAL_BUILD_MODE:BOOL=OFF`.")
    set (CONAN_FILE conanfile.local.txt)
  else()
    message(STATUS "Local build mode is OFF, to enable it use `-DENABLE_LOCAL_BUILD_MODE:BOOL=ON`.")
    set (CONAN_FILE conanfile.txt)
  endif()

  execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${CONAN_DIRECTORY})
  execute_process(
    COMMAND 
    conan install ${CMAKE_CURRENT_SOURCE_DIR}/${CONAN_FILE} --install-folder ${CONAN_DIRECTORY} --build=missing --profile:build default)
endfunction()

macro(setup_conan)
    set(CONAN_CMAKE_SILENT_OUTPUT TRUE)
    install_conan_packages()
    list(APPEND CMAKE_MODULE_PATH ${CONAN_DIRECTORY})
endmacro()

macro(find_packages)
  foreach(package ${ARGN})
      find_package(${package})
  endforeach()
endmacro()

