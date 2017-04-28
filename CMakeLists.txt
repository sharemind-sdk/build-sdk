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

CMAKE_MINIMUM_REQUIRED(VERSION 2.8.12)
IF(POLICY CMP0054)
  CMAKE_POLICY(SET CMP0054 NEW)
ENDIF()
PROJECT(SHAREMIND_APPSERV_BUILD NONE)

IF("${CMAKE_CURRENT_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_BINARY_DIR}")
  MESSAGE(FATAL_ERROR "Generation in source directory is not supported by build.git!")
ENDIF()

INCLUDE(Thing.cmake)
Thing_addKeywords(SHAREMIND_TYPE SHAREMIND_CHECK_COMMAND)

IF(DEFINED SHAREMIND_REPOSITORIES_ROOT_OVERRIDE)
  SET(SHAREMIND_REPOSITORIES_ROOT "${SHAREMIND_REPOSITORIES_ROOT_OVERRIDE}" CACHE INTERNAL "")
ELSE()
  SET(SHAREMIND_REPOSITORIES_ROOT "https://github.com/sharemind-sdk" CACHE INTERNAL "")
ENDIF()
IF(DEFINED SHAREMIND_DEPENDENCIES_ROOT_OVERRIDE)
  SET(SHAREMIND_DEPENDENCIES_ROOT "${SHAREMIND_DEPENDENCIES_ROOT_OVERRIDE}" CACHE INTERNAL "")
ELSE()
  SET(SHAREMIND_DEPENDENCIES_ROOT
      "https://github.com/sharemind-sdk/dependencies/raw/master" CACHE INTERNAL "")
ENDIF()

MESSAGE(STATUS "CMake version detected: ${CMAKE_VERSION}")
IF("${CMAKE_VERSION}" VERSION_LESS "3.11")
  MESSAGE(STATUS "Also building CMake 3.11.4 for targets.")
  SET(SHAREMIND_CMAKE_INSTALL_DIR "${CMAKE_CURRENT_BINARY_DIR}/newCMake")
  SET(SHAREMIND_CMAKE_BIN "${SHAREMIND_CMAKE_INSTALL_DIR}/bin/cmake")
  Thing_add(cmake
    URL "${SHAREMIND_DEPENDENCIES_ROOT}/cmake-3.11.4.tar.gz"
    URL_HASH SHA512=c5d03ad66a004292038e49e391c390ebc328fbb089ea699742a9b75f0ada9398c3dc971b868f75d8438bf437ecbeaa62541beb53cae14a699bf244ad101a2290
    URL_MD5 72e168b3bad2f9c34dcebbad7af56ff0
    INSTALL_DIR "${SHAREMIND_CMAKE_INSTALL_DIR}"
    CONFIGURE_COMMAND
      "${CMAKE_CURRENT_SOURCE_DIR}/cmake/bootstrap"
      "--no-qt-gui"
      "--verbose"
      "--prefix=${SHAREMIND_CMAKE_INSTALL_DIR}"
  )
  FUNCTION(SetNewerCMake out)
    Thing_resetArgs("${ARGN}" CMAKE_COMMAND "${SHAREMIND_CMAKE_BIN}" args)
    Thing_getArgs_concat("${args}" DEPENDS deps)
    LIST(APPEND deps "cmake")
    Thing_resetArgs("${args}" DEPENDS "${deps}" args)
    SET("${out}" "${args}" PARENT_SCOPE)
  ENDFUNCTION()
ELSE()
  SET(SHAREMIND_CMAKE_BIN "${CMAKE_COMMAND}")
ENDIF()
FILE(WRITE "${CMAKE_CURRENT_BINARY_DIR}/cmake_binary.txt" "${SHAREMIND_CMAKE_BIN}\n")

IF(NOT DEFINED SHAREMIND_PROJECTFILE)
  SET(SHAREMIND_PROJECTFILE "${CMAKE_CURRENT_SOURCE_DIR}/Projects.cmake")
ENDIF()
SET(SHAREMIND_PROJECTS_LIST_PASS "INIT")

INCLUDE("${CMAKE_CURRENT_SOURCE_DIR}/config.local" OPTIONAL)
INCLUDE("${CMAKE_CURRENT_BINARY_DIR}/config.local" OPTIONAL)

MESSAGE(STATUS "Using ${SHAREMIND_PROJECTFILE} as project file.")

IF(DEFINED SHAREMIND_INSTALL_PREFIX)
  SET(CMAKE_INSTALL_PREFIX "${SHAREMIND_INSTALL_PREFIX}")
ELSE()
  IF(NOT ("${CMAKE_BUILD_TYPE}" STREQUAL "Release"))
    SET(CMAKE_INSTALL_PREFIX "${CMAKE_CURRENT_SOURCE_DIR}/prefix")
  ENDIF()
ENDIF()
LIST(APPEND CMAKE_PREFIX_PATH "${CMAKE_INSTALL_PREFIX}")
LIST(REMOVE_DUPLICATES CMAKE_PREFIX_PATH)

IF(NOT DEFINED Thing_SKIP)
  INCLUDE("${CMAKE_CURRENT_SOURCE_DIR}/profiles/common.cmake" REQUIRED)
ENDIF()

# Parse project list:
ThingNewEmptyList(SHAREMIND_TARGETS)
ThingNewEmptyList(SHAREMIND_TARGETS_DEP)
ThingNewEmptyList(SHAREMIND_TARGETS_ALL)
ThingNewEmptyList(SHAREMIND_TARGETS_CHECK)
MACRO(SharemindAddCommon name)
  LIST(APPEND SHAREMIND_TARGETS_ALL "${name}")
  Thing_hasArg("${ARGN}" SHAREMIND_CHECK_COMMAND hasCheckCommand)
  IF(hasCheckCommand)
    LIST(APPEND SHAREMIND_TARGETS_CHECK "${name}")
    Thing_getArgs_concat("${ARGN}" SHAREMIND_CHECK_COMMAND
                         "SHAREMIND_CHECK_COMMAND_${name}")
  ENDIF()
  UNSET(hasCheckCommand)
  ThingNewEmptyList("SHAREMIND_ARGS_${name}")
  LIST(APPEND "SHAREMIND_ARGS_${name}" ${ARGN})
  ThingNewEmptyList("SHAREMIND_DEPS_${name}")
  ThingNewEmptyList("SHAREMIND_RDEPS_${name}")
  Thing_getArgs_concat("${ARGN}" DEPENDS SharemindAddCommon_deps)
  FOREACH(d IN LISTS SharemindAddCommon_deps)
    LIST(FIND Thing_SKIP "${d}" isSkipped)
    IF(${isSkipped} EQUAL -1)
      LIST(APPEND "SHAREMIND_DEPS_${name}" "${d}")
      LIST(APPEND "SHAREMIND_RDEPS_${d}" "${name}")
    ENDIF()
  ENDFOREACH()
  UNSET(d)
  LIST(APPEND "${listName}" "${name}")
ENDMACRO()
MACRO(SharemindAddExternalDependency name)
  LIST(FIND Thing_SKIP "${name}" isSkipped)
  IF(${isSkipped} EQUAL -1)
    LIST(APPEND SHAREMIND_TARGETS_DEP "${name}")
    SharemindAddCommon("${name}" ${ARGN})
  ENDIF()
ENDMACRO()
MACRO(SharemindAddRepository name)
  LIST(FIND Thing_SKIP "${name}" isSkipped)
  IF(${isSkipped} EQUAL -1)
    LIST(APPEND SHAREMIND_TARGETS "${name}")
    Thing_getArgs_concat("${ARGN}" GIT_REPOSITORY "SHAREMIND_REPOSITORY_${name}")
    SharemindAddCommon("${name}" ${ARGN})
  ENDIF()
ENDMACRO()
MACRO(SharemindAddShallowRepository name)
  SharemindAddRepository("${name}" ${ARGN})
ENDMACRO()
SET(SHAREMIND_PROJECTS_LIST_PASS "PARSE_ONLY")
INCLUDE("${SHAREMIND_PROJECTFILE}")
LIST(SORT SHAREMIND_TARGETS_DEP)
LIST(SORT SHAREMIND_TARGETS)
LIST(SORT SHAREMIND_TARGETS_ALL)
LIST(SORT SHAREMIND_TARGETS_CHECK)
FUNCTION(SharemindCalcDeepDeps prefix name out)
  UNSET(p)
  ThingNewEmptyList(p)
  FOREACH(d IN LISTS "${prefix}${name}")
    LIST(APPEND p "${d}")
    SharemindCalcDeepDeps("${prefix}" "${d}" o)
    LIST(APPEND p ${o})
    UNSET(o)
  ENDFOREACH()
  LIST(REMOVE_DUPLICATES p)
  SET("${out}" ${p} PARENT_SCOPE)
  UNSET(p)
ENDFUNCTION()
FOREACH(t IN LISTS SHAREMIND_TARGETS_ALL)
  SharemindCalcDeepDeps("SHAREMIND_DEPS_" "${t}" "SHAREMIND_DEEPDEPS_${t}")
  SharemindCalcDeepDeps("SHAREMIND_RDEPS_" "${t}" "SHAREMIND_DEEPRDEPS_${t}")
ENDFOREACH()
UNSET(t)

# List targets to be built:
STRING(REPLACE ";" " " SHAREMIND_TARGETS_DEP_STR "${SHAREMIND_TARGETS_DEP}")
STRING(REPLACE ";" " " SHAREMIND_TARGETS_STR "${SHAREMIND_TARGETS}")
MESSAGE(STATUS "Building dependencies: ${SHAREMIND_TARGETS_DEP_STR}")
MESSAGE(STATUS "Building targets: ${SHAREMIND_TARGETS_STR}")

# Generate build graph:
FIND_PROGRAM(DOT_COMMAND dot)
IF(DOT_COMMAND)
  SET(f "${CMAKE_CURRENT_BINARY_DIR}/graph.dot")
  FILE(WRITE "${f}" "digraph \"build.git\" {\n")
  FILE(APPEND "${f}" "  compound = true; rankdir = TB; style = filled;\n")
  FILE(APPEND "${f}" "  nodesep = 0.5; ranksep = 5; remincross = true;\n")
  FILE(APPEND "${f}" "  searchsize = 9999;\n\n")
  FILE(APPEND "${f}" "  node [shape=box style=filled];\n\n")
  SET(SHAREMIND_MAXRDEPS 0)
  FOREACH(t IN LISTS SHAREMIND_TARGETS_ALL)
    LIST(LENGTH "SHAREMIND_DEEPRDEPS_${t}" l)
    IF(SHAREMIND_MAXRDEPS LESS l)
      SET(SHAREMIND_MAXRDEPS "${l}")
    ENDIF()
    UNSET(l)
  ENDFOREACH()
  UNSET(t)
  FUNCTION(ZEROPREFIX maxlen v out)
    STRING(LENGTH "${v}" l)
    IF(l LESS maxlen)
      MATH(EXPR m "${maxlen} - 1")
      ZEROPREFIX("${m}" "0${v}" v)
    ENDIF()
    SET("${out}" "${v}" PARENT_SCOPE)
  ENDFUNCTION()
  SET(i 0)
  LIST(LENGTH SHAREMIND_TARGETS_ALL k)
  FOREACH(t IN LISTS SHAREMIND_TARGETS_ALL)
    MATH(EXPR h "((${k} - ${i} - 1) * 10000) / ${k}")
    ZEROPREFIX(4 "${h}" h)
    LIST(LENGTH "SHAREMIND_DEEPRDEPS_${t}" r)
    MATH(EXPR s "(${r} * 10000) / (${SHAREMIND_MAXRDEPS} + 1)") # [0,10k)
    UNSET(r)
    MATH(EXPR s "((${s} + 3334) * 10000) / 13333") # [2500,10k)
    MATH(EXPR v "12499-${s}")
    ZEROPREFIX(4 "${s}" s)
    ZEROPREFIX(4 "${v}" v)
    FILE(APPEND "${f}" "\n  \"${t}\" [fillcolor=\"0.${h}, 0.${s}, 0.${v}\"];\n")
    UNSET(h)
    UNSET(s)
    UNSET(v)
    LIST(LENGTH "SHAREMIND_DEPS_${t}" l)
    IF("${l}" GREATER 0)
      FILE(APPEND "${f}" "  \"${t}\" -> {")
      FOREACH(d IN LISTS "SHAREMIND_DEPS_${t}")
        FILE(APPEND "${f}" " \"${d}\"")
      ENDFOREACH()
      UNSET(d)
      FILE(APPEND "${f}" " };\n")
    ENDIF()
    UNSET(l)
    MATH(EXPR i "${i} + 1")
  ENDFOREACH()
  UNSET(k)
  UNSET(i)
  UNSET(t)
  FILE(APPEND "${f}" "}")
  UNSET(f)
  MESSAGE(STATUS "Wrote dependency graph description file (graph.dot).")
  ADD_CUSTOM_TARGET("graph"
    COMMAND "${DOT_COMMAND}" "-Tpng" "graph.dot" "-o" "graph.png"
    WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/"
    COMMENT "Generating graph.png")
ENDIF()

# Add targets to build:
MACRO(SharemindAdd name type)
  IF(COMMAND SetNewerCMake)
    SetNewerCMake(a ${ARGN})
  ELSE()
    SET(a "${ARGN}")
  ENDIF()
  Thing_resetArgs("${a}" SHAREMIND_TYPE "${type}" a)
  Thing_add("${name}" ${a})
  IF(DEFINED "SHAREMIND_CHECK_COMMAND_${name}")
    Thing_getProperty("${name}" binary_dir a)
    ADD_CUSTOM_TARGET("just_check_${name}"
                      ${SHAREMIND_CHECK_COMMAND_${name}}
                      WORKING_DIRECTORY "${a}"
                      COMMENT "Running checks on ${name}...")
    ADD_CUSTOM_TARGET("check_${name}"
                      ${SHAREMIND_CHECK_COMMAND_${name}}
                      WORKING_DIRECTORY "${a}"
                      DEPENDS "${name}"
                      COMMENT "Running checks on ${name}...")
  ENDIF()
  UNSET(a)
ENDMACRO()
MACRO(SharemindAddExternalDependency name)
  SharemindAdd("${name}" "externalDependency" ${ARGN})
ENDMACRO()
MACRO(SharemindAddRepository name)
  SharemindAdd("${name}" "sharemindRepository" ${ARGN})
ENDMACRO()
MACRO(SharemindAddShallowRepository name)
  Thing_resetArgs("${ARGN}" SHALLOW_CLONE "1" a)
  SharemindAdd("${name}" "sharemindRepository" ${a})
  UNSET(a)
ENDMACRO()
SET(SHAREMIND_PROJECTS_LIST_PASS "FINAL")
INCLUDE("${SHAREMIND_PROJECTFILE}")
MESSAGE(STATUS "Added all targets to build.")
MESSAGE(STATUS "The full CMAKE_PREFIX_PATH list is: ${CMAKE_PREFIX_PATH}")

# Add "deps" meta-target to build all dependencies:
ADD_CUSTOM_TARGET(deps
  DEPENDS ${SHAREMIND_TARGETS_DEP}
  COMMENT "Finished building all dependencies")

# Add "check" and "just_check" meta-targets to do all checks:
ADD_CUSTOM_TARGET(check COMMENT "All checks done!")
ADD_CUSTOM_TARGET(just_check COMMENT "All checks done!")
FOREACH(name IN LISTS SHAREMIND_TARGETS_CHECK)
  ADD_DEPENDENCIES(check "check_${name}")
  ADD_DEPENDENCIES(just_check "just_check_${name}")
ENDFOREACH()

# Write meta-information to files:
FUNCTION(WriteMetaInfoList filename list)
  LIST(LENGTH list l)
  IF("${l}" GREATER 0)
    STRING(REPLACE ";" "\n" o "${list}")
    SET(o "${o}\n")
  ELSE()
    SET(o "")
  ENDIF()
  FILE(WRITE "${CMAKE_CURRENT_BINARY_DIR}/${filename}" "${o}")
ENDFUNCTION()
WriteMetaInfoList("projectfile.txt" "${SHAREMIND_PROJECTFILE}")
WriteMetaInfoList("targets.txt" "${SHAREMIND_TARGETS}")
WriteMetaInfoList("deps.txt" "${SHAREMIND_TARGETS_DEP}")
WriteMetaInfoList("all.txt" "${SHAREMIND_TARGETS_ALL}")
WriteMetaInfoList("check.txt" "${SHAREMIND_TARGETS_CHECK}")
FOREACH(t IN LISTS SHAREMIND_TARGETS_ALL)
  WriteMetaInfoList("${t}/self.txt" "${t}")
  WriteMetaInfoList("${t}/deps.txt" "${SHAREMIND_DEPS_${t}}")
  WriteMetaInfoList("${t}/rdeps.txt" "${SHAREMIND_RDEPS_${t}}")
  WriteMetaInfoList("${t}/deepdeps.txt" "${SHAREMIND_DEEPDEPS_${t}}")
  WriteMetaInfoList("${t}/deeprdeps.txt" "${SHAREMIND_DEEPRDEPS_${t}}")
  Thing_getProperty("${t}" source_dir o)
  WriteMetaInfoList("${t}/sourcedir.txt" "${o}")
  Thing_getProperty("${t}" binary_dir o)
  WriteMetaInfoList("${t}/binarydir.txt" "${o}")
  UNSET(o)
ENDFOREACH()
FOREACH(t IN LISTS SHAREMIND_TARGETS)
  WriteMetaInfoList("${t}/repository.txt" "${SHAREMIND_REPOSITORY_${t}}")
ENDFOREACH()
UNSET(t)
MESSAGE(STATUS "Wrote build meta-information files.")

IF(COMMAND Sharemind_hook_postLists)
  MESSAGE(STATUS "Executing post-CMakeLists.txt hook...")
  Sharemind_hook_postLists()
ENDIF()
