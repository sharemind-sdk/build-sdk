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

#
# To build on Debian Stretch with this profile you need to "apt-get install" at
# least the following dependencies:
#
#   bison cmake doxygen flex g++ gcc git libboost-dev libboost-filesystem-dev
#   libboost-iostreams-dev libboost-program-options-dev libboost-system-dev
#   libcrypto++-dev libgmp-dev libgnutls28-dev libhdf5-dev libmpfr-dev libssl-dev
#   m4 make nettle-dev patch pkg-config xz-utils

INCLUDE("${CMAKE_CURRENT_SOURCE_DIR}/profiles/common.cmake" REQUIRED)

LIST(REMOVE_ITEM Thing_SKIP cpp_redis exprtk)
