#
# Copyright (C) 2015 Cybernetica
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
  SET(SHAREMIND_REPOSITORIES_ROOT "ssh://git@github.com/sharemind-sdk")
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
# URL "http://www.cryptopp.com/cryptopp562.zip"
  URL "${SHAREMIND_DEPENDENCIES_ROOT}/cryptopp562.zip"
  URL_HASH SHA512=016ca7ebad1091d67ad0bc5ccb7549d96d4af6b563d9d5a612cae27b3d1a3514c41b954e319fed91c820e8c701e3aa43da186e0864bf959ce4afd1539248ebbe
  URL_MD5 7ed022585698df48e65ce9218f6c6a67
  PATCH_COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_CURRENT_SOURCE_DIR}/patches/crypto++-5.6.2-CMakeLists.txt" CMakeLists.txt)

SharemindAddExternalDependency(tbb
# URL "http://www.threadingbuildingblocks.org/sites/default/files/software_releases/source/tbb42_20140122oss_src.tgz"
  URL "${SHAREMIND_DEPENDENCIES_ROOT}/tbb42_20140122oss_src.tgz"
  URL_HASH SHA512=e4391666bdacd6990ed23cf3c8635b18f727e6e794cadba38c2bbe9113990b955f9f341316a541b4b1b5757ec9af9ac0926a56b4a2d9c2485e3b0a6c6aa888ca
  URL_MD5 70345f907f5ffe9b2bc3b7ed0d6508bc
  CONFIGURE_COMMAND ${Thing_VoidCommand}
  INSTALL_COMMAND ${CMAKE_COMMAND}
                  "-DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}"
                  -P "${CMAKE_CURRENT_SOURCE_DIR}/patches/tbb-install.cmake"
  BUILD_IN_SOURCE 1)

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

SharemindAddExternalDependency(libsortnetwork
# URL "http://verplant.org/libsortnetwork/files/libsortnetwork-1.1.0.tar.bz2"
  URL "${SHAREMIND_DEPENDENCIES_ROOT}/libsortnetwork-1.1.0.tar.bz2"
  URL_HASH SHA512=6efdf4883af9fd0a61f82a914dc284b3fcb5864726e2b7a7149eab3b9be8aa0a3cdfe3a20421348e5eb1c5d641dd7147ffb4d6f1d5bf0bb470e9653cc672329a
  URL_MD5 8923fd56604da0c00675092b1f095492
  PATCH_COMMAND patch -p1 < "${CMAKE_CURRENT_SOURCE_DIR}/patches/libsortnetwork-1.1.0.patch"
  CONFIGURE_COMMAND ./configure "--prefix=${CMAKE_INSTALL_PREFIX}"
  BUILD_COMMAND env "echo=echo" make
  INSTALL_COMMAND env "echo=echo" make install
  BUILD_IN_SOURCE 1)

SharemindAddExternalDependency(exprtk
#  URL "https://github.com/ArashPartow/exprtk/tarball/ce2320489562192e2e81489d8978b9871bd1a4b2"
  URL "${SHAREMIND_DEPENDENCIES_ROOT}/exprtk-ce232048.tar.gz"
  DOWNLOAD_NAME "exprtk-ce232048.tar.gz"
  URL_HASH SHA512=469b9099ae4fa7294b3a1d7ccd2a743e92872c81ae46e568f67dac35999d29cbb926a395969f694a087a0982ccc1764cc4d65c087e28bc37a8f9a607868b4d54
  URL_MD5 872400594e9b4b1f41db9641675ca8fe
  PATCH_COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_CURRENT_SOURCE_DIR}/patches/exprtk-CMakeLists.txt" CMakeLists.txt)

SharemindAddRepository(libsoftfloat
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libsoftfloat.git")

SharemindAddRepository(cheaders
  DEPENDS boost
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/cheaders.git")

SharemindAddRepository(libsoftfloat_math
  DEPENDS cheaders libsoftfloat
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libsoftfloat_math.git")

SharemindAddRepository(cxxheaders
  DEPENDS boost
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/cxxheaders.git")

SharemindAddRepository(vm_m4
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/vm_m4.git")

SharemindAddRepository(libvmi
  DEPENDS cheaders vm_m4
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libvmi.git")

SharemindAddRepository(libexecutable
  DEPENDS cheaders
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libexecutable.git")

SharemindAddRepository(libmodapi
  DEPENDS cheaders
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libmodapi.git")

SharemindAddRepository(libmodapicxx
  DEPENDS cxxheaders libmodapi
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libmodapicxx.git")

SharemindAddRepository(libfmodapi
  DEPENDS cheaders libmodapi
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libfmodapi.git")

SharemindAddRepository(libfmodapicxx
  DEPENDS cxxheaders libfmodapi libmodapicxx
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libfmodapicxx.git")

SharemindAddRepository(libvm
  DEPENDS cheaders libexecutable libmodapi libsoftfloat libvmi vm_m4
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libvm.git")

SharemindAddRepository(libvmcxx
  DEPENDS cxxheaders libvm
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libvmcxx.git")

SharemindAddRepository(libmutexes
  DEPENDS tbb
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libmutexes.git")

SharemindAddRepository(loghard
  DEPENDS cheaders cxxheaders libmutexes
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/loghard.git")

SharemindAddRepository(libexecutionprofiler
  DEPENDS cxxheaders loghard
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libexecutionprofiler.git")

SharemindAddRepository(librandom
  DEPENDS boost cxxheaders loghard
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/librandom.git")

SharemindAddRepository(mod_algorithms
  DEPENDS cheaders cxxheaders libmodapi libsoftfloat libsortnetwork
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/mod_algorithms.git")

SharemindAddRepository(libicontroller
  DEPENDS cxxheaders
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libicontroller.git")

SharemindAddRepository(mod_shared3p_emu
  DEPENDS boost cheaders cryptopp cxxheaders exprtk libexecutionprofiler libmodapi librandom libsoftfloat libsoftfloat_math loghard
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/mod_shared3p_emu.git")

SharemindAddRepository(facility_loghard
  DEPENDS cxxheaders libfmodapi loghard
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/facility_loghard.git")

SharemindAddRepository(facility_executionprofiler
  DEPENDS libexecutionprofiler libfmodapi loghard
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/facility_executionprofiler.git")

SharemindAddRepository(mod_executionprofiler
  DEPENDS cheaders libexecutionprofiler libmodapi
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/mod_executionprofiler.git")

SharemindAddRepository(emulator
  DEPENDS boost cxxheaders libicontroller libfmodapicxx libmodapicxx libvmcxx
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/emulator.git")

SharemindAddRepository(sbdump
  DEPENDS cheaders libexecutable libvmi
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/sbdump.git")

SharemindAddRepository(libas
  DEPENDS cheaders libexecutable libvmi vm_m4
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libas.git")

SharemindAddRepository(secrec
  DEPENDS boost libas mpfr
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/secrec.git")

SharemindAddRepository(stdlib
  DEPENDS secrec
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/stdlib.git")

UNSET(SHAREMIND_REPOSITORIES_ROOT)
UNSET(SHAREMIND_DEPENDENCIES_ROOT)
