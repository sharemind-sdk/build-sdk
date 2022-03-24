# Sharemind SDK build repository

## Quick start guide

### Debian Bullseye

Install the dependencies:

```bash
sudo apt-get install bison cmake doxygen flex g++ gcc git libboost-dev libboost-filesystem-dev libboost-iostreams-dev libboost-program-options-dev libboost-system-dev libcrypto++-dev libhdf5-dev libhiredis-dev libmpfr-dev m4 make
sudo apt-get install --no-install-recommends doxygen
```

Build Sharemind SDK:
```bash
git clone https://github.com/sharemind-sdk/build-sdk.git
cd build-sdk
echo 'INCLUDE("${CMAKE_CURRENT_SOURCE_DIR}/profiles/DebianBullseye.cmake" REQUIRED)' > config.local
mkdir b
cd b
cmake ..
make
```

After this, everything should already be installed in the `prefix/` subdirectory
under `/path/to/this/repository/`.

## Detailed build instructions

Some dependencies can be built by this repository and are pulled from the
[sharemind-sdk/dependencies](https://github.com/sharemind-sdk/dependencies/)
repository.

To include the installation of these dependencies to the build, configure the build
as follows:

```bash
cd /path/to/this/repository
echo 'SET(Thing_SKIP "")' > config.local
```

Building [sharemind-sdk/profile_log_visualizer](https://github.com/sharemind-sdk/profile_log_visualizer/)
is disabled by default, refer to example configuration for enabling it.

For more complex builds, see
[`config.local.example`](https://github.com/sharemind-sdk/build-sdk/blob/master/config.local.example).

Build profiles for specific systems can be found under
[`profiles`](https://github.com/sharemind-sdk/build-sdk/tree/master/profiles).
These profiles can be configured in the `config.local` file before running CMake.
