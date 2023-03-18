# Introduction 

Template repository for applications written in C++

# Table of Contents

- [Introduction](#introduction)
- [Table of Contents](#table-of-contents)
- [Setting up the Development Environment](#setting-up-the-development-environment)
  - [Configuring Dependencies on Ubuntu](#configuring-dependencies-on-ubuntu)
    - [Dependencies installed with apt](#dependencies-installed-with-apt)
    - [GCC](#gcc)
    - [Clang, clangd, clang-tidy and clang-format](#clang-clangd-clang-tidy-and-clang-format)
    - [CMake](#cmake)
    - [Pip](#pip)
    - [Conan](#conan)
    - [VSCode Extensions that will help with code productivity](#vscode-extensions-that-will-help-with-code-productivity)
  - [Configure and Build Process](#configure-and-build-process)
    - [Configure Project](#configure-project)
    - [Build Project](#build-project)
- [Setting up the Development Environment with Docker](#setting-up-the-development-environment-with-docker)
  - [Building Docker Image](#building-docker-image)
  - [Executing The Image](#executing-the-image)
  - [Building](#building)
  - [Copying from Docker Container](#copying-from-docker-container)

# Setting up the Development Environment

In order to set up the development environment for a C++ project, some dependencies are needed

1. Compilers
   * GCC
   * Clang
2. Build System, Tests and Code Coverage
   * CMake
   * Ninja Build System
   * CTest
   * gcovr
3. Package Manager
   * Python
   * Conan
4. LSP and Linters
   * clangd
   * clang-format
   * clang-tidy
   * cppcheck
5. Misc
   * Git
   * ccache
   * vscode extensions

## Configuring Dependencies on Ubuntu

### Dependencies installed with apt

Use the following command to update the system and install the packages:

```bash
sudo apt update;
sudo apt upgrade -y;
sudo apt install -y software-properties-common build-essential autoconf libtool pkg-config \
     wget tar git \
     ccache ninja-build cppcheck gcovr \
     python3 python3-pip
```

### GCC

The following command will install the gcc-11. Replace `11` to install another version

```bash
sudo add-apt-repository 'deb http://archive.ubuntu.com/ubuntu/ lunar main restricted universe multiverse';
sudo apt update;
sudo apt install -y gcc-11 g++-11 gdb;
sudo update-alternatives --install /usr/bin/gcc gcc gcc-11 100
sudo update-alternatives --install /usr/bin/g++ g++ g++-11 100
```

### Clang, clangd, clang-tidy and clang-format

The following command will install the clang-15, Replace `15` to install another version

```bash
sudo bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)" -s 15 all;
sudo apt update;
sudo apt install -y clang-15 clangd-15 clang-format-15 clang-tidy-15 clang-tools-15
```

### CMake

This is a cross-platform build system used to generate build files for various platforms and compilers.

```bash
sudo bash -c "$(wget -O - https://apt.kitware.com/kitware-archive.sh)";
sudo apt update;
sudo apt install cmake cmake-curses-gui
```

### Pip

Update pip to the latest version

```bash
python3 -m pip install --upgrade pip setuptools
```

### Conan

This is a package manager for C/C++ that simplifies dependency management.
Install and configure with the commands above:

```bash
pip install conan==1.56;
conan profile new default --detect;
conan profile update settings.compiler=gcc default;
conan profile update settings.compiler.version=9 default;
conan profile update settings.compiler.cppstd=17 default;
conan profile update settings.compiler.libcxx=libstdc++11 default;
echo "tools.system.package_manager:mode = install\ntools.system.package_manager:sudo = True" >> ~/.conan/global.conf
```

### VSCode Extensions that will help with code productivity

Assuming that you already has vscode installed

```bash
code --install-extension akiramiyakoda.cppincludeguard;
code --install-extension eamodio.gitlens;
code --install-extension Gruntfuggly.todo-tree;
code --install-extension hars.CppSnippets;
code --install-extension IBM.output-colorizer;
code --install-extension jeff-hykin.better-cpp-syntax;
code --install-extension llvm-vs-code-extensions.vscode-clangd;
code --install-extension ms-azuretools.vscode-docker;
code --install-extension ms-vscode.cmake-tools;
code --install-extension streetsidesoftware.code-spell-checker;
code --install-extension tdennis4496.cmantic;
code --install-extension twxs.cmake;
code --install-extension wayou.vscode-todo-highlight;
code --install-extension xaver.clang-format;
code --install-extension yzhang.markdown-all-in-one;
code --install-extension zxh404.vscode-proto3
```

## Configure and Build Process

### Configure Project

Create a `CMakeUserPresets.json` file with the content below

```json
{
    "version": 3,
    "cmakeMinimumRequired": {
        "major": 3,
        "minor": 16
    },
    "configurePresets": [
        {
            "name": "gcc-developer_local",
            "inherits": "gcc-developer",
            "displayName": "GCC - Local Developer Mode",
            "description": "Setup for GCC with local dependencies",
            "cacheVariables": {
                "ENABLE_LOCAL_BUILD_MODE": {
                    "type": "BOOL",
                    "value": true
                }
            }
        },
        {
            "name": "gcc-production_local",
            "inherits": "gcc-production",
            "displayName": "GCC - Local Production Mode",
            "description": "Setup for GCC with local dependencies",
            "cacheVariables": {
                "ENABLE_LOCAL_BUILD_MODE": {
                    "type": "BOOL",
                    "value": true
                }
            }
        },
        {
            "name": "clang-developer_local",
            "inherits": "clang-developer",
            "displayName": "Clang - Local Developer Mode",
            "description": "Setup for Clang with local dependencies",
            "cacheVariables": {
                "ENABLE_LOCAL_BUILD_MODE": {
                    "type": "BOOL",
                    "value": true
                }
            }
        },
        {
            "name": "clang-production_local",
            "inherits": "clang-production",
            "displayName": "Clang - Local Production Mode",
            "description": "Setup for Clang with local dependencies",
            "cacheVariables": {
                "ENABLE_LOCAL_BUILD_MODE": {
                    "type": "BOOL",
                    "value": true
                }
            }
        }
    ],
    "buildPresets": [
        {
            "name": "gcc-release",
            "displayName": "GCC - Release build",
            "description": "Build for production",
            "configurePreset": "gcc-production_local",
            "configuration": "Release",
            "targets": "all",
            "jobs": 12
        },
        {
            "name": "gcc-debug",
            "displayName": "GCC - Debug build",
            "description": "Build for debug mode",
            "configurePreset": "gcc-developer_local",
            "configuration": "Debug",
            "targets": [
                "all",
                "CodeCoverage"
            ],
            "jobs": 12
        },
        {
            "name": "clang-release",
            "displayName": "Clang - Release build",
            "description": "Build for production",
            "configurePreset": "clang-production_local",
            "configuration": "Release",
            "targets": "all",
            "jobs": 12
        },
        {
            "name": "clang-debug",
            "displayName": "Clang - Debug build",
            "description": "Build for debug mode",
            "configurePreset": "clang-developer_local",
            "configuration": "Debug",
            "targets": [
                "all",
                "CodeCoverage"
            ],
            "jobs": 12
        }
    ]
}
```

Use one of the presets listed on `CMakeUserPresets.json` to configure and build project.

1. List the presets:

```bash
cmake --list-presets
```

2. Use one of the presets listed with suffix `_local`.

```bash
cmake --preset=gcc-developer_local
```

### Build Project

Run the following command to build the project:

```bash
cmake --build build/ --target all -j $(nproc)
```

# Setting up the Development Environment with Docker

To create this docker image, all the steps that was described in this README will be followed. If you prefer, use it so you don't need to setup the project manually and whenever you need to work with this project, just start the container.

## Building Docker Image

Execute the following command to build `app` docker image:

```bash
docker build -t app-image .
```

## Executing The Image

```bash
docker run -it --name app -v $(pwd):/app app-image
```

## Building

Now that you are on a Docker container just follows the instructions on [Configure](#configure-project) to configure the project and [Build](#build-project) to build the app.

## Copying from Docker Container

After the build maybe you will need to copy the executable to outside the container, to achieve this, run the following command:

```bash
docker cp app:/app/build/out/<BUILD_CONFIG>/<EXECUTABLE> .
```