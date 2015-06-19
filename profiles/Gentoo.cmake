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
# All the above for "emerge" on one line (don't forget to add USE flags):
#
#   dev-vcs/git sys-devel/make \>=dev-util/cmake-2.8.12 dev-libs/boost
#   sys-devel/gcc dev-libs/glib:2 dev-libs/openssl dev-libs/crypto++
#   sys-devel/bison sys-devel/flex dev-libs/mpfr app-doc/doxygen
#

INCLUDE("${CMAKE_CURRENT_SOURCE_DIR}/profiles/common.cmake" REQUIRED)

LIST(REMOVE_ITEM Thing_SKIP exprtk libsortnetwork)
