workspace "CppAppTemplate"
    configurations { "Debug", "Release" }
    platforms { "x32", "x64" }

project "CppAppTemplate"
    kind "ConsoleApp"
    language "C++"
    cdialect "C11"
    cppdialect "C++17"

    targetdir "%{prj.path}/build/%{cfg.buildcfg}/%{cfg.platform}"
    objdir "%{prj.path}/build/%{cfg.buildcfg}/%{cfg.platform}/obj"

    excludes "cmake/"
    excludes ".vscode/"

    includedirs {
		"%{prj.path}/src",
        "%{prj.path}/tests",

        -- Add third_party directories
        -- "%{prj.path}/third_party/<some_project>"

        -- Not source code or third_party dependencies
        "%{prj.path}/resources",
        "%{prj.path}/.devcontainer",
        "%{prj.path}/.github",
    }

    files { 
        "%{prj.path}/src/**.h", 
		"%{prj.path}/src/**.c", 
		"%{prj.path}/src/**.hpp", 
		"%{prj.path}/src/**.cpp",

        -- Test files
        "%{prj.path}/tests/**.h", 
		"%{prj.path}/tests/**.c", 
		"%{prj.path}/tests/**.hpp", 
		"%{prj.path}/tests/**.cpp",
        
        -- Not source code files
        "%{prj.path}/conanfile.txt",
        "%{prj.path}/premake5.lua",
        "%{prj.path}/.clang-format",
        "%{prj.path}/.clang-tidy",
        "%{prj.path}/.dockerignore",
        "%{prj.path}/.gitignore",
        "%{prj.path}/resources/*",
        "%{prj.path}/.devcontainer/*",
        "%{prj.path}/.github/*",
    }

    removefiles {
        "**/CMakeLists.txt",
        "%{prj.path}/CMakePresets.json",
        "%{prj.path}/conanfile.local.txt",
    }

    local globalDebugOptions = {
        -- Warnings
        "/WX",                  -- Treats all compiler warnings as errors 
        "/W4",                  -- Baseline reasonable warnings
        "/w14242",              -- 'identifier': conversion from 'type1' to 'type1', possible loss of data
        "/w14254",              -- 'operator': conversion from 'type1:field_bits' to 'type2:field_bits', possible loss of data
        "/w14263",              -- 'function': member function does not override any base class virtual member function
        "/w14265",              -- 'classname': class has virtual functions, but destructor is not virtual instances of this class may not be destructed correctly
        "/w14287",              -- 'operator': unsigned/negativ,e constant mismatch
        "/we4289",              -- nonstandard extension used: 'variable': loop control variable declared in the for-loop is used outside the for-loop scope
        "/w14296",              -- 'operator': expression is always 'boolean_value'
        "/w14311",              -- 'variable': pointer truncation from 'type1' to 'type2'
        "/w14545",              -- expression before comma evaluates to a function which is missing an argument list
        "/w14546",              -- function call before comma missing argument list
        "/w14547",              -- 'operator': operator before comma has no effect; expected operator with side-effect
        "/w14549",              -- 'operator': operator before comma has no effect; did you intend 'operator'?
        "/w14555",              -- expression has no effect; expected expression with side- effect
        "/w14619",              -- pragma warning: there is no warning number 'number'
        "/w14640",              -- Enable warning on thread un-safe static member initialization
        "/w14826",              -- Conversion from 'type1' to 'type_2' is sign-extended. This may cause unexpected runtime behavior.
        "/w14905",              -- wide string literal cast to 'LPSTR'
        "/w14906",              -- string literal cast to 'LPWSTR'
        "/w14928",              -- illegal copy-initialization; more than one user-defined conversion has been implicitly applied
        "/permissive-",         -- standards conformance mode for MSVC compiler.
        
        -- Compiler options
        "/diagnostics:column",  -- prettify the compilers output
        "/sdl",                 -- Enable Additional Security Checks: https://learn.microsoft.com/en-us/cpp/build/reference/sdl-enable-additional-security-checks?view=msvc-170
        "/MP",                  -- Build with multiple processes: https://learn.microsoft.com/en-us/cpp/build/reference/mp-build-with-multiple-processes?view=msvc-170
    }

    local globalLinkOptions = {
        "/DYNAMICBASE", -- Use address space layout randomization: https://learn.microsoft.com/en-us/cpp/build/reference/dynamicbase-use-address-space-layout-randomization?view=msvc-170
        "/NXCOMPAT",    -- Compatible with Data Execution Prevention: https://learn.microsoft.com/en-us/cpp/build/reference/nxcompat-compatible-with-data-execution-prevention?view=msvc-170
        "/CETCOMPAT",   -- CET Shadow Stack compatible: https://learn.microsoft.com/en-us/cpp/build/reference/cetcompat?view=msvc-170
    }

    filter "configurations:Debug"
        defines { "DEBUG" }
        symbols "On"

        buildoptions {
            globalDebugOptions,
            
            -- Extra Compiler options
            "/fsanitize=address",   -- Enable sanitizers: https://learn.microsoft.com/en-us/cpp/build/reference/fsanitize?view=msvc-170
            -- "/MTd",              -- If sanitize address is enabled, see this: https://stackoverflow.com/questions/66531482/application-crashes-when-using-address-sanitizer-with-msvc
        }

        linkoptions {
            globalLinkOptions,

            -- Extra Linker options
            "/INCREMENTAL:NO",   -- If sanitize address is enabled, see this: https://learn.microsoft.com/en-us/cpp/build/reference/incremental-link-incrementally?view=msvc-170
        }

    filter "configurations:Release"
        defines { "NDEBUG" }
        optimize "On"

        buildoptions {
            globalDebugOptions,

            -- Extra Compiler options
            "/GL",                  -- Whole program optimization: https://learn.microsoft.com/en-us/cpp/build/reference/gl-whole-program-optimization?view=msvc-170
            "/guard:cf",            -- Enable Control Flow Guard: https://learn.microsoft.com/en-us/cpp/build/reference/guard-enable-control-flow-guard?view=msvc-170
        }

        linkoptions {
            globalLinkOptions,

            -- Extra Linker options
            "/LTCG",        -- Link-time code generation: https://learn.microsoft.com/en-us/cpp/build/reference/ltcg-link-time-code-generation?view=msvc-170
        }