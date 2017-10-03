#
# Copyright (C) Cybernetica
#
# Research/Commercial License Usage
# Licensees holding a valid Research License or Commercial License
# for the Software may use this file according to the written
# agreement between you and Cybernetica.
#
# GNU General Public License Usage
# Alternatively, this file may be used under the terms of the GNU
# General Public License version 3.0 as published by the Free Software
# Foundation and appearing in the file LICENSE.GPL included in the
# packaging of this file.  Please review the following information to
# ensure the GNU General Public License version 3.0 requirements will be
# met: http://www.gnu.org/copyleft/gpl-3.0.html.
#
# For further information, please contact us at sharemind@cyber.ee.
#

IF(DEFINED SHAREMIND_REPOSITORIES_ROOT_OVERRIDE)
  SET(SHAREMIND_REPOSITORIES_ROOT "${SHAREMIND_REPOSITORIES_ROOT_OVERRIDE}")
ELSE()
#  SET(SHAREMIND_REPOSITORIES_ROOT "ssh://git@github.com/sharemind-sdk")
  SET(SHAREMIND_REPOSITORIES_ROOT "https://github.com/sharemind-sdk")
ENDIF()
IF(DEFINED SHAREMIND_DEPENDENCIES_ROOT_OVERRIDE)
  SET(SHAREMIND_DEPENDENCIES_ROOT "${SHAREMIND_DEPENDENCIES_ROOT_OVERRIDE}")
ELSE()
  SET(SHAREMIND_DEPENDENCIES_ROOT
      "https://github.com/sharemind-sdk/dependencies/raw/master")
ENDIF()

SharemindAddExternalDependency(gmp
  URL "${SHAREMIND_DEPENDENCIES_ROOT}/gmp-6.0.0a.tar.bz2"
  URL_HASH SHA512=04c8fde7f6e9c2e42753cebf6345d74ef6bdae5ef764df303b6615d17c8d851ac2876ca32c6ba5e111a8d07575c8b725c7b90518a6616be27a7b46d6aeb82c1a
  URL_MD5 b7ff2d88cae7f8085bd5006096eed470
  CONFIGURE_COMMAND ./configure "--prefix=${CMAKE_INSTALL_PREFIX}/"
                                "--enable-cxx"
  BUILD_IN_SOURCE 1)

IF(DEFINED Thing_installDir_gmp)
  SET(mpfr_withGmp "--with-gmp=${Thing_installDir_gmp}")
ENDIF()
SharemindAddExternalDependency(mpfr
  DEPENDS gmp
# URL "http://www.mpfr.org/mpfr-current/mpfr-3.1.2.tar.bz2"
  URL "${SHAREMIND_DEPENDENCIES_ROOT}/mpfr-3.1.2.tar.bz2"
  URL_HASH SHA512=0312a1ac813c51737e7d2b40fa771a73adb796ef962bbbd81ffd5e18a16b13346dd20875710e29f5304146750253d7d3755dc4c7b28c1b3b6cd527a6a7affd14
  URL_MD5 ee2c3ac63bf0c2359bf08fc3ee094c19
  CONFIGURE_COMMAND ./configure "--prefix=${CMAKE_INSTALL_PREFIX}/"
                                "--disable-maintainer-mode"
                                "--enable-thread-safe"
                                "--enable-shared"
                                "--disable-static"
                                ${mpfr_withGmp}
  BUILD_IN_SOURCE 1)
UNSET(mpfr_withGmp)

SharemindAddExternalDependency(cryptopp
# URL "http://www.cryptopp.com/cryptopp565.zip"
  URL "${SHAREMIND_DEPENDENCIES_ROOT}/cryptopp565.zip"
  URL_HASH SHA512=f13718d02ca69b0129aaf9e767c9d2e0333aa7538355f9c63d9eaf1ff369062084a18dc01489439ebf37797b3ea81b01beb072057d47ec962bfb824ddc72abc7
  URL_MD5 df5ef4647b4e978bba0cac79a83aaed5
  PATCH_COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_CURRENT_SOURCE_DIR}/patches/crypto++-5.6.5-CMakeLists.txt" CMakeLists.txt)

SharemindAddExternalDependency(boost
# URL "http://downloads.sourceforge.net/project/boost/boost/1.56.0/boost_1_56_0.tar.bz2"
  URL "${SHAREMIND_DEPENDENCIES_ROOT}/boost_1_56_0.tar.bz2"
  URL_MD5 a744cf167b05d72335f27c88115f211d
  URL_HASH SHA512=1ce9871c3a2519682538a5f1331938b948123432d99aea0ce026958cbebd25d84019a3a28c452724b9693df98a8d1264bb2d93d2fee508453f8b42836e67481e
  PATCH_COMMAND patch -p1 < "${CMAKE_CURRENT_SOURCE_DIR}/patches/boost-1.56.0-fixes.patch"
  CONFIGURE_COMMAND ./bootstrap.sh "--prefix=${CMAKE_INSTALL_PREFIX}"
                                  "--without-libraries=atomic,chrono,context,coroutine,date_time,exception,graph,graph_parallel,locale,log,math,python,random,regex,serialization,signals,test,timer,wave"
  BUILD_COMMAND ./b2 -j3 --ignore-site-config
  INSTALL_COMMAND ./b2 -j3 --ignore-site-config install
  BUILD_IN_SOURCE 1)

SharemindAddExternalDependency(exprtk
  URL "https://github.com/ArashPartow/exprtk/tarball/ce2320489562192e2e81489d8978b9871bd1a4b2"
  DOWNLOAD_NAME "exprtk-ce232048.tar.gz"
  URL_HASH SHA512=469b9099ae4fa7294b3a1d7ccd2a743e92872c81ae46e568f67dac35999d29cbb926a395969f694a087a0982ccc1764cc4d65c087e28bc37a8f9a607868b4d54
  URL_MD5 872400594e9b4b1f41db9641675ca8fe
  PATCH_COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_CURRENT_SOURCE_DIR}/patches/exprtk-CMakeLists.txt" CMakeLists.txt)

SharemindAddExternalDependency(hdf5
# URL "http://www.hdfgroup.org/ftp/HDF5/prev-releases/hdf5-1.8.13/src/hdf5-1.8.13.tar.bz2"
  URL "${SHAREMIND_DEPENDENCIES_ROOT}/hdf5-1.8.13.tar.bz2"
  URL_HASH SHA512=76dcd045c5dffe28478e9eb4ff5ff3f9d400b044c5af19d8b1040f8f0d1ecdce9c92d49f7df0450412214ff37023ea76ed031411a99dd4c2b848ebd3b332b853
  URL_MD5 b060bb137d6bd8accf8f0c4c59d2746d
  CONFIGURE_COMMAND env "CFLAGS=-w"
                    ./configure "--prefix=${CMAKE_INSTALL_PREFIX}/"
                                "--disable-dependency-tracking"
                                "--enable-production"
                                "--disable-deprecated-symbols"
                                "--enable-shared"
                                "--disable-silent-rules"
                                "--disable-sharedlib-rpath"
                                "--disable-static"
                                "--disable-debug"
                                "--disable-codestack"
                                "--disable-cxx"
                                "--disable-fortran"
                                "--disable-fortran2003"
                                "--disable-parallel"
                                "--enable-threadsafe"
                                "--disable-hl"
                                "--without-szlib"
                                "--with-pthread"
                                "--without-zlib"
  BUILD_IN_SOURCE 1)

SharemindAddExternalDependency(cpp_redis
  URL "https://github.com/Cylix/cpp_redis/tarball/e4d9568121340485b1126d0a40538718297cab11"
  DOWNLOAD_NAME "cpp_redis.tar.gz"
  URL_HASH SHA512=538015faf3706971f93e4d811ff26331ae99f87c146e91dbc55d1e6097345726922506ad4bb262cb8dbb98115b363c4280df8d35d862fb6692903564a12b8fdd
  PATCH_COMMAND patch -p1 <
                "${CMAKE_CURRENT_SOURCE_DIR}/patches/cpp_redis-gcc7.patch"
  )

SharemindAddRepository(cmake-helpers
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/cmake-helpers.git")

SharemindAddRepository(libsoftfloat
  DEPENDS cmake-helpers
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libsoftfloat.git")

SharemindAddRepository(cheaders
  DEPENDS boost cmake-helpers
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/cheaders.git")

SharemindAddRepository(libaccesscontrolfacility
  DEPENDS cheaders cmake-helpers
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libaccesscontrolfacility.git")

SharemindAddRepository(libsoftfloat_math
  DEPENDS cheaders cmake-helpers libsoftfloat
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libsoftfloat_math.git")

SharemindAddRepository(cxxheaders
  DEPENDS boost cheaders cmake-helpers
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/cxxheaders.git"
  SHAREMIND_CHECK_COMMAND $(MAKE) check)

SharemindAddRepository(vm_m4
  DEPENDS cmake-helpers
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/vm_m4.git")

SharemindAddRepository(libvmi
  DEPENDS cheaders cmake-helpers vm_m4
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libvmi.git")

SharemindAddRepository(libexecutable
  DEPENDS cheaders cmake-helpers
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libexecutable.git")

SharemindAddRepository(module-apis
  DEPENDS cheaders cmake-helpers
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/module-apis.git")

SharemindAddRepository(libmodapi
  DEPENDS cheaders cmake-helpers module-apis
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libmodapi.git")

SharemindAddRepository(libmodapicxx
  DEPENDS cmake-helpers libmodapi
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libmodapicxx.git")

SharemindAddRepository(libprocessfacility
  DEPENDS cheaders cmake-helpers
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libprocessfacility.git")

SharemindAddRepository(facility-module-apis
  DEPENDS cheaders cmake-helpers libprocessfacility module-apis
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/facility-module-apis.git")

SharemindAddRepository(libfmodapi
  DEPENDS cheaders cmake-helpers facility-module-apis libmodapi libprocessfacility module-apis
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libfmodapi.git")

SharemindAddRepository(libfmodapicxx
  DEPENDS cmake-helpers cxxheaders libfmodapi libmodapicxx
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libfmodapicxx.git")

SharemindAddRepository(libvm
  DEPENDS cheaders cmake-helpers libexecutable libmodapi libsoftfloat libvmi module-apis vm_m4
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libvm.git")

SharemindAddRepository(libvmcxx
  DEPENDS cmake-helpers cxxheaders libvm
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libvmcxx.git")

SharemindAddRepository(loghard
  DEPENDS cheaders cmake-helpers cxxheaders
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/loghard.git")

SharemindAddRepository(libconsensusservice
  DEPENDS cmake-helpers
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libconsensusservice.git")

SharemindAddRepository(libdatastoremanager
  DEPENDS cmake-helpers cxxheaders
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libdatastoremanager.git")

SharemindAddRepository(libexecutionmodelevaluator
  DEPENDS cmake-helpers cxxheaders exprtk loghard
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libexecutionmodelevaluator.git")

SharemindAddRepository(libexecutionprofiler
  DEPENDS cmake-helpers cxxheaders loghard
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libexecutionprofiler.git")

SharemindAddRepository(librandom
  DEPENDS boost cmake-helpers cxxheaders
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/librandom.git"
  SHAREMIND_CHECK_COMMAND $(MAKE) check)

SharemindAddRepository(libsortnetwork
  DEPENDS cmake-helpers
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libsortnetwork.git")

SharemindAddRepository(mod_algorithms
  DEPENDS cheaders cmake-helpers cxxheaders libsoftfloat libsoftfloat_math libsortnetwork module-apis
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/mod_algorithms.git")

SharemindAddRepository(libicontroller
  DEPENDS cmake-helpers cxxheaders
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libicontroller.git")

SharemindAddRepository(libconfiguration
  DEPENDS boost cmake-helpers cxxheaders
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libconfiguration.git")

SharemindAddRepository(pdkheaders
  DEPENDS cmake-helpers cxxheaders module-apis
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/pdkheaders.git")

SharemindAddRepository(libemulator_protocols
  DEPENDS cmake-helpers pdkheaders
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libemulator_protocols.git")

SharemindAddRepository(mod_shared3p_emu
  DEPENDS boost cheaders cmake-helpers cryptopp cxxheaders libconfiguration libemulator_protocols libexecutionmodelevaluator libexecutionprofiler libsoftfloat libsoftfloat_math loghard module-apis pdkheaders
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/mod_shared3p_emu.git")

SharemindAddRepository(mod_aby_emu
  DEPENDS boost cheaders cmake-helpers cxxheaders libemulator_protocols libexecutionmodelevaluator libexecutionprofiler loghard module-apis pdkheaders
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/mod_aby_emu.git")

SharemindAddRepository(mod_spdz_fresco_emu
  DEPENDS boost cheaders cxxheaders libemulator_protocols libexecutionmodelevaluator libexecutionprofiler libmodapi loghard pdkheaders
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/mod_spdz_fresco_emu.git")

SharemindAddRepository(libdbcommon
  DEPENDS cmake-helpers
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libdbcommon.git")

SharemindAddRepository(mod_keydb
  DEPENDS boost cmake-helpers cpp_redis libconsensusservice libdatastoremanager libprocessfacility loghard module-apis pdkheaders
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/mod_keydb.git")

SharemindAddRepository(mod_tabledb
  DEPENDS boost cheaders cmake-helpers cxxheaders libaccesscontrolfacility libconfiguration libconsensusservice libdatastoremanager libdbcommon libmodapi loghard module-apis
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/mod_tabledb.git")

SharemindAddRepository(mod_tabledb_hdf5
  DEPENDS boost cmake-helpers cxxheaders hdf5 libaccesscontrolfacility libconfiguration libconsensusservice libdatastoremanager libdbcommon libprocessfacility loghard mod_tabledb module-apis
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/mod_tabledb_hdf5.git")

SharemindAddRepository(facility_loghard
  DEPENDS cmake-helpers cxxheaders facility-module-apis loghard
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/facility_loghard.git")

SharemindAddRepository(facility_executionprofiler
  DEPENDS cmake-helpers facility-module-apis libexecutionprofiler loghard
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/facility_executionprofiler.git")

SharemindAddRepository(facility_datastoremanager
  DEPENDS cmake-helpers cxxheaders facility-module-apis libdatastoremanager
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/facility_datastoremanager.git")

SharemindAddRepository(mod_executionprofiler
  DEPENDS cheaders cmake-helpers libexecutionprofiler module-apis
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/mod_executionprofiler.git")

SharemindAddRepository(emulator
  DEPENDS boost cmake-helpers cxxheaders libaccesscontrolfacility libconfiguration libfmodapicxx libicontroller libmodapicxx libprocessfacility librandom libvmcxx
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/emulator.git")

SharemindAddRepository(sbdump
  DEPENDS cheaders cmake-helpers libexecutable libvmi
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/sbdump.git")

SharemindAddRepository(libas
  DEPENDS cheaders cmake-helpers libexecutable libvmi vm_m4
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libas.git")

SharemindAddRepository(secrec
  DEPENDS boost cheaders cmake-helpers libas mpfr
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/secrec.git")

SharemindAddRepository(stdlib
  DEPENDS secrec
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/stdlib.git")

UNSET(SHAREMIND_REPOSITORIES_ROOT)
UNSET(SHAREMIND_DEPENDENCIES_ROOT)
