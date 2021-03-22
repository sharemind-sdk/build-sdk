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

SharemindAddExternalDependency(exprtk
  URL "https://github.com/ArashPartow/exprtk/tarball/ce2320489562192e2e81489d8978b9871bd1a4b2"
  DOWNLOAD_NAME "exprtk-ce232048.tar.gz"
  URL_HASH SHA512=469b9099ae4fa7294b3a1d7ccd2a743e92872c81ae46e568f67dac35999d29cbb926a395969f694a087a0982ccc1764cc4d65c087e28bc37a8f9a607868b4d54
  URL_MD5 872400594e9b4b1f41db9641675ca8fe
  PATCH_COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_CURRENT_SOURCE_DIR}/patches/exprtk-CMakeLists.txt" CMakeLists.txt)

SharemindAddRepository(cmake-helpers
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/cmake-helpers.git")

SharemindAddRepository(cheaders
  DEPENDS cmake-helpers
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/cheaders.git")

SharemindAddRepository(libsoftfloat
  DEPENDS cheaders cmake-helpers
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libsoftfloat.git")

SharemindAddRepository(libsoftfloat_math
  DEPENDS cheaders cmake-helpers libsoftfloat
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libsoftfloat_math.git")

SharemindAddRepository(cxxheaders
  DEPENDS cheaders cmake-helpers
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/cxxheaders.git"
  SHAREMIND_CHECK_COMMAND $(MAKE) check)

SharemindAddRepository(libaccesscontrolprocessfacility
  DEPENDS cmake-helpers cxxheaders
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libaccesscontrolprocessfacility.git")

SharemindAddRepository(vm_m4
  DEPENDS cmake-helpers
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/vm_m4.git")

SharemindAddRepository(libvmi
  DEPENDS cmake-helpers cxxheaders vm_m4
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libvmi.git")

SharemindAddRepository(libexecutable
  DEPENDS cmake-helpers cxxheaders
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libexecutable.git")

SharemindAddRepository(module-apis
  DEPENDS cheaders cmake-helpers
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/module-apis.git")

SharemindAddRepository(libmodapi
  DEPENDS cheaders cmake-helpers module-apis
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libmodapi.git")

SharemindAddRepository(libmodapicxx
  DEPENDS cmake-helpers cxxheaders libmodapi
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libmodapicxx.git")

SharemindAddRepository(libprocessfacility
  DEPENDS cheaders cmake-helpers
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libprocessfacility.git")

SharemindAddRepository(facility-module-apis
  DEPENDS cheaders cmake-helpers libprocessfacility module-apis
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/facility-module-apis.git")

SharemindAddRepository(libfmodapi
  DEPENDS cmake-helpers cxxheaders facility-module-apis
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libfmodapi.git")

SharemindAddRepository(libvm
  DEPENDS cheaders cmake-helpers cxxheaders libexecutable libsoftfloat libvmi vm_m4
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libvm.git")

SharemindAddRepository(loghard
  DEPENDS cheaders cmake-helpers cxxheaders
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/loghard.git"
  SHAREMIND_CHECK_COMMAND $(MAKE) check)

SharemindAddRepository(libconsensusservice
  DEPENDS cmake-helpers
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libconsensusservice.git")

SharemindAddRepository(data-store-api
  DEPENDS cmake-helpers
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/data-store-api.git")

SharemindAddRepository(libdatastoremanager
  DEPENDS cmake-helpers cxxheaders data-store-api
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libdatastoremanager.git")

SharemindAddRepository(libexecutionmodelevaluator
  DEPENDS cmake-helpers cxxheaders exprtk loghard
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libexecutionmodelevaluator.git")

SharemindAddRepository(libexecutionprofiler
  DEPENDS cmake-helpers cxxheaders loghard
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libexecutionprofiler.git")

SharemindAddRepository(librandom
  DEPENDS cmake-helpers cxxheaders
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/librandom.git"
  SHAREMIND_CHECK_COMMAND $(MAKE) check)

SharemindAddRepository(libsortnetwork
  DEPENDS cmake-helpers cxxheaders
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libsortnetwork.git")

SharemindAddRepository(mod_algorithms
  DEPENDS cheaders cmake-helpers cxxheaders libsoftfloat libsoftfloat_math libsortnetwork module-apis
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/mod_algorithms.git")

SharemindAddRepository(libconfiguration
  DEPENDS cmake-helpers cxxheaders
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libconfiguration.git")

SharemindAddRepository(pdkheaders
  DEPENDS cmake-helpers cxxheaders module-apis
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/pdkheaders.git")

SharemindAddRepository(libemulator_protocols
  DEPENDS cmake-helpers pdkheaders
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libemulator_protocols.git")

SharemindAddRepository(mod_shared3p_emu
  DEPENDS cheaders cmake-helpers cxxheaders libconfiguration libemulator_protocols libexecutionmodelevaluator libexecutionprofiler libsoftfloat libsoftfloat_math loghard module-apis pdkheaders
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/mod_shared3p_emu.git")

SharemindAddRepository(mod_aby_emu
  DEPENDS cheaders cmake-helpers cxxheaders libemulator_protocols libexecutionmodelevaluator libexecutionprofiler loghard module-apis pdkheaders
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/mod_aby_emu.git")

SharemindAddRepository(mod_spdz_fresco_emu
  DEPENDS cheaders cmake-helpers cxxheaders libemulator_protocols libexecutionmodelevaluator libexecutionprofiler libmodapi loghard module-apis pdkheaders
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/mod_spdz_fresco_emu.git")

SharemindAddRepository(libdbcommon
  DEPENDS cmake-helpers
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libdbcommon.git")

SharemindAddRepository(mod_keydb
  DEPENDS cmake-helpers data-store-api libaccesscontrolprocessfacility libconsensusservice libprocessfacility loghard module-apis pdkheaders
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/mod_keydb.git")

SharemindAddRepository(mod_tabledb
  DEPENDS cheaders cmake-helpers cxxheaders data-store-api libaccesscontrolprocessfacility libconfiguration libconsensusservice libdbcommon libmodapi libprocessfacility loghard module-apis
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/mod_tabledb.git")

SharemindAddRepository(mod_tabledb_hdf5
  DEPENDS cmake-helpers cxxheaders data-store-api libconfiguration libconsensusservice libdbcommon libprocessfacility loghard mod_tabledb module-apis
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/mod_tabledb_hdf5.git")

SharemindAddRepository(facility_loghard
  DEPENDS cmake-helpers cxxheaders facility-module-apis loghard
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/facility_loghard.git")

SharemindAddRepository(facility_executionprofiler
  DEPENDS cmake-helpers cxxheaders facility-module-apis libexecutionprofiler loghard
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/facility_executionprofiler.git")

SharemindAddRepository(facility_datastoremanager
  DEPENDS cmake-helpers facility-module-apis libdatastoremanager
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/facility_datastoremanager.git")

SharemindAddRepository(mod_executionprofiler
  DEPENDS cheaders cmake-helpers libexecutionprofiler module-apis
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/mod_executionprofiler.git")

SharemindAddRepository(emulator
  DEPENDS cmake-helpers cxxheaders libaccesscontrolprocessfacility libconfiguration libfmodapi libmodapicxx libprocessfacility librandom libvm
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/emulator.git")

SharemindAddRepository(sbdump
  DEPENDS cheaders cmake-helpers cxxheaders libexecutable libvmi loghard
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/sbdump.git")

SharemindAddRepository(libas
  DEPENDS cheaders cmake-helpers libexecutable libvmi
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/libas.git")

SharemindAddRepository(secrec
  DEPENDS cheaders cmake-helpers cxxheaders libas
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/secrec.git")

SharemindAddRepository(secrec-stdlib
  DEPENDS cmake-helpers secrec
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/secrec-stdlib.git")

SharemindAddRepository(qtcreator-plugin-sharemind-mpc
  DEPENDS cmake-helpers
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/qtcreator-plugin-sharemind-mpc.git")

IF(NOT DEFINED SHAREMIND_EXCLUDE_NODE)
  SET(SHAREMIND_EXCLUDE_NODE 1)
ENDIF()

SharemindAddRepository(profile_log_visualizer
  DEPENDS cmake-helpers
  GIT_REPOSITORY "${SHAREMIND_REPOSITORIES_ROOT}/profile_log_visualizer.git"
  EXCLUDE_FROM_ALL ${SHAREMIND_EXCLUDE_NODE})

UNSET(SHAREMIND_REPOSITORIES_ROOT)
UNSET(SHAREMIND_DEPENDENCIES_ROOT)
