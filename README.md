# Sharemind SDK build repository

## Quick start guide

### General

To quickly build everything handled by this repository (including the
dependencies), use something like this:

```bash
cd /path/to/this/repository
echo 'SET(Thing_SKIP "")' > config.local
mkdir b
cd b
cmake ..
make
```

After this, everything should already be installed in the `prefix/` subdirectory
under `/path/to/this/repository/`.

### Debian Jessie

Install dependencies:

```bash
sudo apt-get install cmake git make gcc g++ libbz2-dev libmpfr-dev libcrypto++-dev libbison-dev flex libtbb-dev libhdf5-dev libboost-filesystem-dev libboost-iostreams-dev libboost-program-options-dev libboost-system-dev libboost-thread-dev help2man
sudo apt-get install --no-install-recommends doxygen
```

Build Sharemind SDK:
```bash
git clone https://github.com/sharemind-sdk/build-sdk.git
cd build-sdk
echo 'INCLUDE("${CMAKE_CURRENT_SOURCE_DIR}/profiles/DebianJessie.cmake" REQUIRED)' > config.local
mkdir b
cd b
cmake ..
make
```

After this, everything should already be installed in the `prefix/` subdirectory
under `/path/to/this/repository/`.

## Detailed build instructions

Requirements:

* Linux or BSD based OS with 64-bit architecture
* Git
* C++ toolchain (gcc 4.7 or above, clang 3.4 or above)
* CMake (2.8.12 or above)
* GNU make
* Boost
* Crypto++
* GNU Bison
* Flex
* GNU MPFR
* HDF5
* Doxygen
* libbz2
* help2man

Some dependencies can be built by this repository and are pulled from the
[sharemind-sdk/dependencies](https://github.com/sharemind-sdk/dependencies/)
repository.

For more complex builds, see
[`config.local.example`](https://github.com/sharemind-sdk/build-sdk/blob/master/config.local.example).

Build profiles for specific systems can be found under
[`profiles`](https://github.com/sharemind-sdk/build-sdk/tree/master/profiles).
These profiles can be configured in the `config.local` file before running CMake.
