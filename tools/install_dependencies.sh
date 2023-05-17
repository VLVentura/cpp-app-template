#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "This script must be run with sudo privileges"
    exit 1
fi

# Check Linux version
if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    if [[ $ID == "ubuntu" ]]; then
        echo "*** Detected $PRETTY_NAME"
    else
        echo "Unsupported Linux distribution"
        exit 1
    fi
else
    echo "Unable to determine Linux distribution"
    exit 1
fi

# Function to install LLVM and Clang
install_llvm_clang() {
    local version=$1
    llvmpath=/usr/lib/llvm-$version/bin

    echo "[3/7] Installing Clang/LLVM $version"
    sudo bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)" -s $version all > /dev/null 2>&1
    sudo apt update > /dev/null 2>&1
    sudo apt install -y llvm-$version llvm-$version-dev clang-$version clangd-$version clang-format-$version clang-tidy-$version clang-tools-$version > /dev/null 2>&1
    sudo update-alternatives --install /usr/bin/clang clang $(which clang-$version) 100 && sudo update-alternatives --set clang $(which clang-$version) > /dev/null 2>&1
    sudo update-alternatives --install /usr/bin/clang++ clang++ $(which clang++-$version) 100 && sudo update-alternatives --set clang++ $(which clang++-$version) > /dev/null 2>&1
    sudo update-alternatives --install /usr/bin/clang-tidy clang-tidy $(which clang-tidy-$version) 100 && sudo update-alternatives --set clang-tidy $(which clang-tidy-$version) > /dev/null 2>&1
    sudo update-alternatives --install /usr/bin/clang-format clang-format $(which clang-format-$version) 100 && sudo update-alternatives --set clang-format $(which clang-format-$version) > /dev/null 2>&1
    sudo update-alternatives --install /usr/bin/lldb lldb $llvmpath/lldb 100 && sudo update-alternatives --set lldb $llvmpath/lldb
    sudo update-alternatives --install /usr/bin/lld lld $llvmpath/lld 100 && sudo update-alternatives --set lld $llvmpath/lld
    sudo update-alternatives --install /usr/bin/llvm-cov llvm-cov $llvmpath/llvm-cov 100 && sudo update-alternatives --set llvm-cov $llvmpath/llvm-cov
}

# Function to install GCC
install_gcc(){
    local version=$1

    if ! apt-cache show gcc-$version &>/dev/null; then
        echo "GCC $version is not available"
        exit 1
    fi
    echo "[2/7] Installing GCC $version"
    sudo apt install -y gcc-$version g++-$version > /dev/null 2>&1
    sudo update-alternatives --install /usr/bin/gcc gcc $(which gcc-$version) 100
    sudo update-alternatives --install /usr/bin/g++ g++ $(which gcc-$version) 100
}

# Step 1: Update the system and install base packages
echo "[1/7] Upgrading system and installing base packages"
sudo apt update > /dev/null 2>&1
sudo apt upgrade -y > /dev/null 2>&1
sudo apt install -y software-properties-common build-essential autoconf libtool pkg-config \
    gcc g++ gdb wget tar git file \
    ccache ninja-build cppcheck gcovr \
    python3 python3-pip > /dev/null 2>&1

# Step 2: Update GCC to the latest available version on apt and install LLVM and Clang packages
gcc_version=0
clang_version=15

while test $# -gt 0; do
    case "$1" in
        --gcc)
            shift
            if test $# -gt 0; then
                gcc_version=$1
            else
                echo "No GCC version specified"
                exit 1
            fi
            ;;
        --clang)
            shift
            if test $# -gt 0; then
                clang_version=$1
            else
                echo "No Clang version specified"
                exit 1
            fi
            ;;
        *)
            break
            ;;
    esac
    shift
done

if [[ $gcc_version != -1 ]]; then
    if [[ $gcc_version == 0 ]]; then
        latest_gcc_version=8
        for version in {9..12}; do
            if apt-cache show gcc-$version &>/dev/null; then
                latest_gcc_version=$version
            fi
        done
        gcc_version=$latest_gcc_version
    fi
    install_gcc $gcc_version
else
    echo "[2/7] Skip installation of a newer GCC"
fi

install_llvm_clang $clang_version

# Step 3: Install CMake
echo "[4/7] Installing CMake"
sudo bash -c "$(wget -O - https://apt.kitware.com/kitware-archive.sh)" > /dev/null 2>&1
sudo apt update > /dev/null 2>&1
sudo apt install -y cmake cmake-curses-gui > /dev/null 2>&1

# Step 4: Update pip
echo "[5/7] Upgrading pip3"
python3 -m pip install --upgrade pip setuptools testresources > /dev/null 2>&1

# Step 5: Install Conan
echo "[6/7] Installing conan"
pip install conan==1.56 > /dev/null 2>&1
conan profile new default --detect
conan profile update settings.compiler=gcc default
conan profile update settings.compiler.version=$gcc_version default
conan profile update settings.compiler.cppstd=17 default
conan profile update settings.compiler.libcxx=libstdc++11 default
echo "tools.system.package_manager:mode = install" >> ~/.conan/global.conf
echo "tools.system.package_manager:sudo = True" >> ~/.conan/global.conf

# Step 6: Check if vscode is installed and install extensions
if [[ $(which code) ]]; then
    echo "[7/7] Installing VSCode extensions"
    code --install-extension akiramiyakoda.cppincludeguard
    code --install-extension eamodio.gitlens
    code --install-extension Gruntfuggly.todo-tree
    code --install-extension hars.CppSnippets
    code --install-extension IBM.output-colorizer
    code --install-extension jeff-hykin.better-cpp-syntax
    code --install-extension llvm-vs-code-extensions.vscode-clangd
    code --install-extension ms-azuretools.vscode-docker
    code --install-extension ms-vscode.cmake-tools
    code --install-extension streetsidesoftware.code-spell-checker
    code --install-extension tdennis4496.cmantic
    code --install-extension twxs.cmake
    code --install-extension wayou.vscode-todo-highlight
    code --install-extension xaver.clang-format
    code --install-extension yzhang.markdown-all-in-one
    code --install-extension zxh404.vscode-proto3
    code --install-extension franneck94.c-cpp-runner
else
    echo "[7/7] VSCode is not installed, skipping extension installation"
fi

echo "*** Dependencies succesfully installed."