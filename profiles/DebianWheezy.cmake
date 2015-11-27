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

#
# To build on Debian Wheezy with this profile you need to "apt-get install" at
# least the following dependencies:
#
#   git make gcc g++ libbz2-dev libglib2.0-dev libmpfr-dev libcrypto++-dev
#   libbison-dev flex libmpfr-dev doxygen libtbb-dev libhdf5-dev
#
# PS: Note that you must also manually install CMake 2.8.12 or later.
#

INCLUDE("${CMAKE_CURRENT_SOURCE_DIR}/profiles/common.cmake" REQUIRED)

LIST(REMOVE_ITEM Thing_SKIP boost exprtk libsortnetwork)
