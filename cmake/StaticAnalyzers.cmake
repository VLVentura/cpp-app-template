macro(enable_cppcheck WARNINGS_AS_ERRORS CPPCHECK_OPTIONS)
  find_program(CPPCHECK cppcheck)
  if(CPPCHECK)

    if(CMAKE_GENERATOR MATCHES ".*Visual Studio.*")
      set(CPPCHECK_TEMPLATE "vs")
    else()
      set(CPPCHECK_TEMPLATE "gcc")
    endif()

    if("${CPPCHECK_OPTIONS}" STREQUAL "")
      # Enable all warnings that are actionable by the user of this toolset
      # style should enable the other 3, but we'll be explicit just in case
      set(CMAKE_CXX_CPPCHECK
          ${CPPCHECK}
          --template=${CPPCHECK_TEMPLATE}
          --enable=style,performance,warning,portability
          --inline-suppr
          # We cannot act on a bug/missing feature of cppcheck
          --suppress=cppcheckError
          --suppress=internalAstError
          # if a file does not have an internalAstError, we get an unmatchedSuppression error
          --suppress=unmatchedSuppression
          # noisy and incorrect sometimes
          --suppress=passedByValue
          # ignores code that cppcheck thinks is invalid C++
          --suppress=syntaxError
          --suppress=preprocessorErrorDirective
          --inconclusive
          # ignores code from third_party directory
          -i ${PROJECT_SOURCE_DIR}/build/)
    else()
      # if the user provides a CPPCHECK_OPTIONS with a template specified, it will override this template
      set(CMAKE_CXX_CPPCHECK ${CPPCHECK} --template=${CPPCHECK_TEMPLATE} ${CPPCHECK_OPTIONS})
    endif()

    if(NOT
       "${CMAKE_CXX_STANDARD}"
       STREQUAL
       "")
      set(CMAKE_CXX_CPPCHECK ${CMAKE_CXX_CPPCHECK} --std=c++${CMAKE_CXX_STANDARD})
    endif()
    if(${WARNINGS_AS_ERRORS})
      list(APPEND CMAKE_CXX_CPPCHECK --error-exitcode=2)
    endif()
  else()
    message(${WARNING_MESSAGE} "cppcheck requested but executable not found")
  endif()
endmacro()

macro(enable_clang_tidy target WARNINGS_AS_ERRORS)

  find_program(CLANGTIDY clang-tidy)
  if(CLANGTIDY)
    if(NOT
       CMAKE_CXX_COMPILER_ID
       MATCHES
       ".*Clang")

      get_target_property(TARGET_PCH ${target} INTERFACE_PRECOMPILE_HEADERS)

      if("${TARGET_PCH}" STREQUAL "TARGET_PCH-NOTFOUND")
        get_target_property(TARGET_PCH ${target} PRECOMPILE_HEADERS)
      endif()

      if(NOT ("${TARGET_PCH}" STREQUAL "TARGET_PCH-NOTFOUND"))
        message(
          SEND_ERROR
            "clang-tidy cannot be enabled with non-clang compiler and PCH, clang-tidy fails to handle gcc's PCH file")
      endif()
    endif()

    # construct the clang-tidy command line
    set(CLANG_TIDY_OPTIONS
        ${CLANGTIDY}
        -extra-arg=-Wno-unknown-warning-option
        -extra-arg=-Wno-ignored-optimization-argument
        -extra-arg=-Wno-unused-command-line-argument
        -p)
    # set standard
    if(NOT
       "${CMAKE_CXX_STANDARD}"
       STREQUAL
       "")
      if("${CLANG_TIDY_OPTIONS_DRIVER_MODE}" STREQUAL "cl")
        set(CLANG_TIDY_OPTIONS ${CLANG_TIDY_OPTIONS} -extra-arg=/std:c++${CMAKE_CXX_STANDARD})
      else()
        set(CLANG_TIDY_OPTIONS ${CLANG_TIDY_OPTIONS} -extra-arg=-std=c++${CMAKE_CXX_STANDARD})
      endif()
    endif()

    # set warnings as errors
    if(${WARNINGS_AS_ERRORS})
      list(APPEND CLANG_TIDY_OPTIONS -warnings-as-errors=*)
    endif()

    message("Also setting clang-tidy globally")
    set(CMAKE_CXX_CLANG_TIDY ${CLANG_TIDY_OPTIONS})
  else()
    message(${WARNING_MESSAGE} "clang-tidy requested but executable not found")
  endif()
endmacro()

macro(enable_include_what_you_use)
  find_program(INCLUDE_WHAT_YOU_USE include-what-you-use)
  if(INCLUDE_WHAT_YOU_USE)
    set(CMAKE_CXX_INCLUDE_WHAT_YOU_USE ${INCLUDE_WHAT_YOU_USE})
  else()
    message(${WARNING_MESSAGE} "include-what-you-use requested but executable not found")
  endif()
endmacro()

# Disable clang-tidy for target
macro(target_disable_clang_tidy TARGET)
  find_program(CLANGTIDY clang-tidy)
  if(CLANGTIDY)
    set_target_properties(${TARGET} PROPERTIES C_CLANG_TIDY "")
    set_target_properties(${TARGET} PROPERTIES CXX_CLANG_TIDY "")
  endif()
endmacro()

# Disable cppcheck for target
macro(target_disable_cpp_check TARGET)
  find_program(CPPCHECK cppcheck)
  if(CPPCHECK)
    set_target_properties(${TARGET} PROPERTIES C_CPPCHECK "")
    set_target_properties(${TARGET} PROPERTIES CXX_CPPCHECK "")
  endif()
endmacro()

# Disable vs analysis for target
macro(target_disable_vs_analysis TARGET)
  if(CMAKE_GENERATOR MATCHES "Visual Studio")
    set_target_properties(
      ${TARGET}
      PROPERTIES VS_GLOBAL_EnableMicrosoftCodeAnalysis false VS_GLOBAL_CodeAnalysisRuleSet ""
                 VS_GLOBAL_EnableClangTidyCodeAnalysis ""
    )
  endif()
endmacro()

# Disable include-what-you-use for target
macro(target_disable_include_what_you_use TARGET)
  find_program(INCLUDE_WHAT_YOU_USE include-what-you-use)
  if(INCLUDE_WHAT_YOU_USE)
    set_target_properties(${TARGET} PROPERTIES C_INCLUDE_WHAT_YOU_USE "")
    set_target_properties(${TARGET} PROPERTIES CXX_INCLUDE_WHAT_YOU_USE "")
  endif()
endmacro()

# Disable gcc analyzer for target
macro(target_disable_gcc_analyzer TARGET)
  if(CMAKE_C_COMPILER_ID STREQUAL "GNU")
    get_target_property(_compile_options ${TARGET} INTERFACE_COMPILE_OPTIONS)
    if(_compile_options)
      string(REGEX REPLACE "-fanalyzer|-Wanalyzer-[0-9a-zA-Z-]+" ""
                           _compile_options_no_gcc_analyzer "${_compile_options}"
      )
      set_target_properties(
        ${TARGET} PROPERTIES INTERFACE_COMPILE_OPTIONS "${_compile_options_no_gcc_analyzer}"
      )
    endif()
    get_target_property(_compile_options ${TARGET} COMPILE_OPTIONS)
    if(_compile_options)
      string(REGEX REPLACE "-fanalyzer|-Wanalyzer-[0-9a-zA-Z-]+" ""
                           _compile_options_no_gcc_analyzer "${_compile_options}"
      )
      set_target_properties(
        ${TARGET} PROPERTIES COMPILE_OPTIONS "${_compile_options_no_gcc_analyzer}"
      )
    endif()
  endif()
endmacro()

#[[.rst:

``target_disable_static_analysis``
==================================

This function disables static analysis for the given target:

.. code:: cmake

   target_disable_static_analysis(some_external_target)

There is also individual functions to disable a specific analysis for
the target:

-  ``target_disable_cpp_check(target)``
-  ``target_disable_vs_analysis(target)``
-  ``target_disable_clang_tidy(target)``
-  ``target_disable_include_what_you_use(target)``
-  ``target_disable_gcc_analyzer(target)``


]]
macro(target_disable_static_analysis TARGET)
  if(NOT CMAKE_GENERATOR MATCHES "Visual Studio")
    target_disable_clang_tidy(${TARGET})
    target_disable_cpp_check(${TARGET})
    target_disable_gcc_analyzer(${TARGET})
  endif()
  target_disable_vs_analysis(${TARGET})
  target_disable_include_what_you_use(${TARGET})
endmacro()
