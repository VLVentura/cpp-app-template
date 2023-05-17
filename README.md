# Introduction 

Template repository for applications written in C++

# Table of Contents

- [Introduction](#introduction)
- [Table of Contents](#table-of-contents)
- [Setting up the Development Environment](#setting-up-the-development-environment)
  - [Configuring Dependencies on Ubuntu](#configuring-dependencies-on-ubuntu)
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

On tools directory, run the script `install_dependencies.sh` with sudo privileges.
This script will install all the dependencies and the latest version of GCC available on your distribution and Clang-15 by default.

```bash
cd tools ;
sudo ./install_dependencies
```

You can also specify a version of gcc to install and/or a version of clang. Just keep in mind that maybe not all GCC's versions are available on your distribution. On Ubuntu 20.04 LTS, for example, the latest GCC available is GCC-10.

```bash
cd tools ;
sudo ./install_dependencies --gcc 10 --clang 15
```

If you don't want to install a newer GCC, you can pass -1 to it, and it will skip the GCC installation. Clang is required, you cannot skip clang installation.

```bash
cd tools ;
sudo ./install_dependencies --gcc -1
```

## Configure and Build Process

### Configure Project

Copy the `CMakeUserPresets.json` file from resources directory to the root directory and use one of the presets 
listed on the file to configure and build project.

1. List the presets:

```bash
cmake --list-presets
```

1. Use one of the presets listed

```bash
cmake --preset=gcc-developer
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