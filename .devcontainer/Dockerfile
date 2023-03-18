FROM docker.io/ubuntu:20.04

# By default, anything you run in Docker is done as superuser.
# Conan runs some install commands as superuser, and will prepend `sudo` to
# these commands, unless `CONAN_SYSREQUIRES_SUDO=0` is in your env variables.
ENV CONAN_SYSREQUIRES_SUDO 0
# Some packages request that Conan use the system package manager to install
# a few dependencies. This flag allows Conan to proceed with these installations;
# leaving this flag undefined can cause some installation failures.
ENV CONAN_SYSREQUIRES_MODE enabled

ARG LLVM_VERSION=15
ARG GCC_VERSION=9

# Setup environment
RUN apt update; \
    DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
    software-properties-common build-essential autoconf libtool pkg-config wget tar git \
    ccache ninja-build cppcheck gcovr python3 python3-pip; \
    ccache --max-size=2G --set-config=compression=true --set-config=compression_level=5

# Install llvm
RUN bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)" -s ${LLVM_VERSION} all; \
    apt update; \
    DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
    clang-${LLVM_VERSION} clang-format-${LLVM_VERSION} \
    clang-tidy-${LLVM_VERSION} clang-tools-${LLVM_VERSION}; \
    update-alternatives --install /usr/bin/clang clang $(which clang-${LLVM_VERSION}) 100 && \
    update-alternatives --set clang $(which clang-${LLVM_VERSION}); \
    update-alternatives --install /usr/bin/clang++ clang++ $(which clang++-${LLVM_VERSION}) 100 && \
    update-alternatives --set clang++ $(which clang++-${LLVM_VERSION}); \
    update-alternatives --install /usr/bin/clang-tidy clang-tidy $(which clang-tidy-${LLVM_VERSION}) 100 && \
    update-alternatives --set clang-tidy $(which clang-tidy-${LLVM_VERSION}); \
    update-alternatives --install /usr/bin/clang-format clang-format $(which clang-format-${LLVM_VERSION}) 100 && \
    update-alternatives --set clang-format $(which clang-format-${LLVM_VERSION})

# Add latest ubuntu repository
RUN add-apt-repository 'deb http://archive.ubuntu.com/ubuntu/ lunar main restricted universe multiverse'

# Install GCC
RUN apt update; \
    DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
    gcc-${GCC_VERSION} g++-${GCC_VERSION}; \
    update-alternatives --install /usr/bin/gcc gcc $(which gcc-${GCC_VERSION}) 100; \
    update-alternatives --install /usr/bin/g++ g++ $(which g++-${GCC_VERSION}) 100

# Install CMake
RUN bash -c "$(wget -O - https://apt.kitware.com/kitware-archive.sh)"; \
    apt update; \ 
    DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends cmake

# Install Conan
RUN python3 -m pip install --upgrade pip setuptools; \
    pip install conan==1.56; \
    conan profile new default --detect; \
    conan profile update settings.compiler=gcc default; \ 
    conan profile update settings.compiler.version=9 default; \
    conan profile update settings.compiler.cppstd=17 default; \
    conan profile update settings.compiler.libcxx=libstdc++11 default

# Install heavy dependencies
RUN apt update; \
    DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
    libgrpc-dev/lunar libgrpc++-dev/lunar libprotobuf-dev/lunar protobuf-compiler/lunar \
    protobuf-compiler-grpc/lunar libabsl-dev libboost1.81-dev

## Cleanup cached apt data we don't need anymore
RUN apt-get autoremove -y && apt-get clean; \
    rm -rf /var/lib/apt/lists/*

COPY . app/

WORKDIR /app/

RUN cmake --preset=gcc-developer && cmake --build build/ --target all -j $(nproc)

CMD [ "/bin/bash" ]