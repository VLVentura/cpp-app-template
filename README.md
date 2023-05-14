# Introduction 

Template repository for applications written in C++

# Table of Contents

- [Introduction](#introduction)
- [Table of Contents](#table-of-contents)
- [Setting up the Development Environment](#setting-up-the-development-environment)
  - [Configuring Dependencies on Ubuntu](#configuring-dependencies-on-ubuntu)
    - [Dependencies installed with apt](#dependencies-installed-with-apt)
    - [GCC](#gcc)
    - [Clang, clangd, clang-tidy, clang-format and llvm-cov](#clang-clangd-clang-tidy-clang-format-and-llvm-cov)
    - [CMake](#cmake)
    - [Pip](#pip)
    - [Conan](#conan)
    - [VSCode Extensions that will help with code productivity](#vscode-extensions-that-will-help-with-code-productivity)
  - [Configure and Build Process](#configure-and-build-process)
    - [Configure Project](#configure-project)
    - [Build Project](#build-project)
- [Setting up the Development Environment with Docker](#setting-up-the-development-environment-with-docker)
  - [Building Docker Image](#building-docker-image)
    - [With Docker Compose](#with-docker-compose)
    - [Without Docker Compose](#without-docker-compose)
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

### Clang, clangd, clang-tidy, clang-format and llvm-cov

The following command will install the clang-15, Replace `15` to install another version

```bash
sudo bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)" -s 15 all;
sudo apt update;
sudo apt install -y clang-15 clangd-15 clang-format-15 clang-tidy-15 clang-tools-15 llvm-cov-15
sudo update-alternatives --install /usr/bin/clang clang $(which clang-15) 100 && sudo update-alternatives --set clang $(which clang-15)
sudo update-alternatives --install /usr/bin/clang++ clang++ $(which clang++-15) 100 && sudo update-alternatives --set clang++ $(which clang++-15)
sudo update-alternatives --install /usr/bin/clang-tidy clang-tidy $(which clang-tidy-15) 100 && sudo update-alternatives --set clang-tidy $(which clang-tidy-15)
sudo update-alternatives --install /usr/bin/clang-format clang-format $(which clang-format-15) 100 && sudo update-alternatives --set clang-format $(which clang-format-15)
sudo update-alternatives --install /usr/bin/llvm-cov-15 llvm-cov $(which llvm-cov-15) 100 && sudo update-alternatives --set llvm-cov $(which llvm-cov-15)
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
code --install-extension franneck94.c-cpp-runner
```

## Configure and Build Process

### Configure Project

Copy the `CMakeUserPresets.json` file from resources directory to the root directory and use one of the presets 
listed on the file to configure and build project.

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

### With Docker Compose

1. Execute the following command inside `.devcontainer` directory to build:

    ```bash
    docker compose build
    ```

2. Run the application with:

    ```bash
    docker compose run --rm app
    ```

    `--rm` will exclude the container when it exit, if you want to exclude manually, just remove this flag.

3. Delete the services

    ```bash
    docker compose down
    ```

### Without Docker Compose

1. Execute the following command to build `app` docker image:

    ```bash
    docker build -t cpp-app-image -f .devcontainer/Dockerfile .
    ```

2. Start a container

    ```bash
    docker run -it --name cpp-app cpp-app-image
    ```

3. Building

    Now that you are on a Docker container just follows the instructions on [Configure](#configure-project) to configure the project and [Build](#build-project) to build the app.

## Copying from Docker Container

After the build, if you want to copy the executable to outside of the container, run the command below:

```bash
docker cp <CONTAINER_NAME or CONTAINER_ID>:/app/build/out/<BUILD_CONFIG>/bin/main .; 
```