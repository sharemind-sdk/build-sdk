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

IF(CMAKE_VERSION VERSION_LESS 2.8.12)
  MESSAGE(FATAL_ERROR "Thing: CMake 2.8.12 or later required, but version ${CMAKE_VERSION} found!")
ENDIF()

INCLUDE(ExternalProject)

SET(Thing_VoidCommand ${CMAKE_COMMAND} -E echo_append)

MACRO(ThingNewEmptyList name)
  IF(DEFINED "${name}")
    MESSAGE(FATAL_ERROR "CMake variable ${name} is already defined!")
  ENDIF()
  SET("${name}" tmp)
  LIST(REMOVE_ITEM "${name}" tmp)
ENDMACRO()

# Joins all items of a list to a string using the given glue:
FUNCTION(Thing_join output glue)
  STRING(REGEX REPLACE "([^\\]|^);" "\\1${glue}" tmp "${ARGN}")
  STRING(REGEX REPLACE "[\\](.)" "\\1" tmp "${tmp}")
  SET(${output} "${tmp}" PARENT_SCOPE)
ENDFUNCTION()

FUNCTION(Thing_pathJoin output)
  IF(WIN32)
    Thing_join(out ";" ${ARGN})
  ELSE()
    Thing_join(out ":" ${ARGN})
  ENDIF()
  SET(${output} "${out}" PARENT_SCOPE)
ENDFUNCTION()

IF(NOT DEFINED Thing_EXTRA_KEYWORDS)
  SET(Thing_EXTRA_KEYWORDS "")
ENDIF()
SET(Thing__stoppers
  "DEPENDS" "PREFIX" "LIST_SEPARATOR" "TMP_DIR" "STAMP_DIR" "DOWNLOAD_NAME"
  "DOWNLOAD_DIR" "DOWNLOAD_COMMAND" "CVS_REPOSITORY" "CVS_MODULE" "CVS_TAG"
  "SVN_REPOSITORY" "SVN_REVISION" "SVN_USERNAME" "SVN_PASSWORD" "SVN_TRUST_CERT"
  "GIT_REPOSITORY" "GIT_TAG" "HG_REPOSITORY" "HG_TAG" "URL" "URL_HASH" "URL_MD5"
  "TLS_VERIFY" "TLS_CAINFO" "TIMEOUT" "UPDATE_COMMAND" "PATCH_COMMAND"
  "SOURCE_DIR" "CONFIGURE_COMMAND" "CMAKE_COMMAND" "CMAKE_GENERATOR"
  "CMAKE_GENERATOR_TOOLSET" "CMAKE_ARGS" "CMAKE_CACHE_ARGS" "BINARY_DIR"
  "BUILD_COMMAND" "BUILD_IN_SOURCE" "INSTALL_DIR" "INSTALL_COMMAND"
  "TEST_BEFORE_INSTALL" "TEST_AFTER_INSTALL" "TEST_COMMAND" "LOG_DOWNLOAD"
  "LOG_UPDATE" "LOG_CONFIGURE" "LOG_BUILD" "LOG_TEST" "LOG_INSTALL"
  "STEP_TARGETS"
)

MACRO(Thing_addKeywords)
  LIST(APPEND Thing_EXTRA_KEYWORDS ${ARGN})
  LIST(REMOVE_DUPLICATES Thing_EXTRA_KEYWORDS)
ENDMACRO()

FUNCTION(Thing_getKeywords out)
  SET(allKeywords ${Thing__stoppers})
  LIST(APPEND allKeywords ${Thing_EXTRA_KEYWORDS})
  SET(${out} ${allKeywords} PARENT_SCOPE)
ENDFUNCTION()

# Returns all the values from a given ExternalProject_Add arguments group under
# the given argument group name, concatenated:
FUNCTION(Thing_getArgs_concat inArgs argName outArgs)
  Thing_getKeywords(stoppers)
  LIST(FIND stoppers "${argName}" isStopper)
  IF(${isStopper} EQUAL -1)
    MESSAGE(WARNING "Thing: Unknown argument name given, but continuing anyway: ${argName}")
  ENDIF()
  SET(SKIP 1)
  SET(tmp "")
  FOREACH(a IN LISTS inArgs)
    IF("${a}$" STREQUAL "${argName}$")
      SET(SKIP 0)
    ELSEIF(NOT SKIP)
      LIST(FIND stoppers "${a}" isStopper)
      IF(NOT (${isStopper} EQUAL -1))
        SET(SKIP 1)
      ELSE()
        LIST(APPEND tmp "${a}")
      ENDIF()
    ENDIF()
  ENDFOREACH()
  SET(${outArgs} "${tmp}" PARENT_SCOPE)
ENDFUNCTION()

# Removes all given argument groups from a list of ExternalProject_Add arguments:
FUNCTION(Thing_removeArgs inArgs argName outArgs)
  Thing_getKeywords(stoppers)
  LIST(FIND stoppers "${argName}" isStopper)
  IF(${isStopper} EQUAL -1)
    MESSAGE(WARNING "Thing: Unknown argument name given, but continuing anyway: ${argName}")
  ENDIF()
  SET(SKIP 0)
  SET(tmp "")
  FOREACH(a IN LISTS inArgs)
    IF("${a}$" STREQUAL "${argName}$")
      SET(SKIP 1)
    ELSEIF(SKIP)
      LIST(FIND stoppers "${a}" isStopper)
      IF(NOT (${isStopper} EQUAL -1))
        SET(SKIP 0)
        LIST(APPEND tmp "${a}")
      ENDIF()
    ELSE()
      LIST(APPEND tmp "${a}")
    ENDIF()
  ENDFOREACH()
  SET(${outArgs} "${tmp}" PARENT_SCOPE)
ENDFUNCTION()

# Resets a given argument in a list of ExternalProject_Add arguments:
FUNCTION(Thing_resetArgs inArgs argName newValues outArgs)
  Thing_removeArgs("${inArgs}" "${argName}" args)
  LIST(APPEND args "${argName}" "${newValues}")
  SET(${outArgs} "${args}" PARENT_SCOPE)
ENDFUNCTION()

# Returns whether the given argument list contains the given argument:
FUNCTION(Thing_hasArg args argName out)
  Thing_getKeywords(stoppers)
  LIST(FIND stoppers "${argName}" isStopper)
  IF(${isStopper} EQUAL -1)
    MESSAGE(WARNING "Thing: Unknown argument name given, but continuing anyway: ${argName}")
  ENDIF()
  LIST(FIND args "${argName}" hasArg)
  IF(${hasArg} EQUAL -1)
    SET("${out}" FALSE PARENT_SCOPE)
  ELSE()
    SET("${out}" TRUE PARENT_SCOPE)
  ENDIF()
ENDFUNCTION()

# Constructs a new ExternalProject_Add argument list for an out-of-tree
# configure and build, e.g configure/cmake && make && make install:
FUNCTION(Thing_remoteConfigure name origArgs buildDir sourceDir outArgs)
  SET(argsToRemove DOWNLOAD_NAME DOWNLOAD_DIR DOWNLOAD_COMMAND CVS_REPOSITORY
                   CVS_MODULE CVS_TAG SVN_REPOSITORY SVN_REVISION SVN_USERNAME
                   SVN_PASSWORD SVN_TRUST_CERT GIT_REPOSITORY GIT_TAG
                   HG_REPOSITORY HG_TAG URL URL_HASH URL_MD5 TLS_VERIFY
                   TLS_CAINFO TIMEOUT UPDATE_COMMAND PATCH_COMMAND SOURCE_DIR
                   BINARY_DIR)
  FOREACH(argToRemove IN LISTS argsToRemove)
    Thing_removeArgs("${origArgs}" "${argToRemove}" origArgs)
  ENDFOREACH()
  LIST(APPEND origArgs
       "DOWNLOAD_COMMAND" "${Thing_VoidCommand}"
       "UPDATE_COMMAND" "${Thing_VoidCommand}"
       "PATCH_COMMAND" "${Thing_VoidCommand}"
       "BINARY_DIR" "${buildDir}"
       "SOURCE_DIR" "${sourceDir}")
  SET(${outArgs} "${origArgs}" PARENT_SCOPE)
ENDFUNCTION()

# Constructs a new ExternalProject_Add argument list for an out-of-tree build,
# e.g. make && make install:
FUNCTION(Thing_remoteBuild name origArgs buildDir sourceDir outArgs)
  SET(argsToRemove DOWNLOAD_NAME DOWNLOAD_DIR DOWNLOAD_COMMAND CVS_REPOSITORY
                   CVS_MODULE CVS_TAG SVN_REPOSITORY SVN_REVISION SVN_USERNAME
                   SVN_PASSWORD SVN_TRUST_CERT GIT_REPOSITORY GIT_TAG
                   HG_REPOSITORY HG_TAG URL URL_HASH URL_MD5 TLS_VERIFY
                   TLS_CAINFO TIMEOUT UPDATE_COMMAND PATCH_COMMAND SOURCE_DIR
                   CONFIGURE_COMMAND CMAKE_COMMAND CMAKE_GENERATOR
                   CMAKE_GENERATOR_TOOLSET CMAKE_ARGS CMAKE_CACHE_ARGS
                   BINARY_DIR)
  FOREACH(argToRemove IN LISTS argsToRemove)
    Thing_removeArgs("${origArgs}" "${argToRemove}" origArgs)
  ENDFOREACH()
  LIST(APPEND origArgs
       "DOWNLOAD_COMMAND" "${Thing_VoidCommand}"
       "UPDATE_COMMAND" "${Thing_VoidCommand}"
       "PATCH_COMMAND" "${Thing_VoidCommand}"
       "CONFIGURE_COMMAND" "${Thing_VoidCommand}"
       "BINARY_DIR" "${buildDir}"
       "SOURCE_DIR" "${sourceDir}")
  SET(${outArgs} "${origArgs}" PARENT_SCOPE)
ENDFUNCTION()

FUNCTION(Thing_addFromOverride name)
  IF(TARGET "${name}")
    SET(m "Thing_addFromOverride() called multiple times for target")
    MESSAGE(FATAL_ERROR "${m} \"${name}\"!!! Aborting.")
  ENDIF()
  Thing_getArgs_concat("${ARGN}" DEPENDS deps)
  Thing_removeArgs("${ARGN}" DEPENDS newArgs)
  IF(deps)
    LIST(APPEND newArgs DEPENDS)
    FOREACH(dep IN LISTS deps)
      LIST(FIND Thing_SKIP "${dep}" depFound)
      IF(${depFound} EQUAL -1)
        LIST(APPEND newArgs "${dep}")
      ENDIF()
    ENDFOREACH()
  ENDIF()
  IF("${CMAKE_VERSION}" VERSION_LESS "2.8.10")
    Thing_removeArgs("${newArgs}" URL_HASH newArgs)
  ELSE()
    Thing_removeArgs("${newArgs}" URL_MD5 newArgs)
  ENDIF()
  Thing_getArgs_concat("${newArgs}" GIT_REPOSITORY git_repository)

  # Remove all non-ExternalProject keywords:
  FOREACH(keyword IN LISTS Thing_EXTRA_KEYWORDS)
    Thing_removeArgs("${newArgs}" "${keyword}" newArgs)
  ENDFOREACH()

  IF(NOT git_repository)
    ExternalProject_Add("${name}" "${newArgs}")
  ELSE()
    Thing_getArgs_concat("${newArgs}" UPDATE_COMMAND update_command)
    IF(update_command)
      ExternalProject_Add("${name}" "${newArgs}")
    ELSE()
      Thing_getArgs_concat("${newArgs}" GIT_TAG git_tag)
      IF(NOT git_tag)
        SET(git_tag "master")
      ENDIF()
      ExternalProject_Add("${name}" "${newArgs}"
                          UPDATE_COMMAND "${CMAKE_COMMAND}" -E echo_append)
      ExternalProject_Get_Property(${name} SOURCE_DIR source_dir)
      Thing_getArgs_concat("${newArgs}" LOG_UPDATE log_update)
      IF(log_update)
        SET(log LOG log_update)
      ELSE()
        SET(log "")
      ENDIF()
      ExternalProject_Add_Step(
        "${name}" newGitUpdate
        COMMAND sh -c "git show-ref --tags ${git_tag} || git show-ref --heads ${git_tag} && ( git fetch && git checkout ${git_tag} && git merge --ff origin/${git_tag} ) || true"
        DEPENDEES download
        DEPENDERS update
        ALWAYS 1
        WORKING_DIRECTORY "${source_dir}"
        ${log})
    ENDIF()
  ENDIF()
ENDFUNCTION()

SET(Thing_Polymorphisms_DIR
    "${CMAKE_CURRENT_BINARY_DIR}/ThingPolymorphisms")
FILE(MAKE_DIRECTORY "${Thing_Polymorphisms_DIR}")
MACRO(Thing_call cmdName expr)
  FILE(WRITE "${Thing_Polymorphisms_DIR}/${Thing__cmdName}.cmake"
             "${cmdName}(${expr})")
  INCLUDE("${Thing_Polymorphisms_DIR}/${Thing__cmdName}.cmake")
ENDMACRO()

SET(Thing_ListSeparator "~~...~~")

MACRO(Thing_prefixPaths out)
  Thing_join(${out} "${Thing_ListSeparator}" ${CMAKE_PREFIX_PATH})
ENDMACRO()

FUNCTION(Thing_add name)
  IF(DEFINED Thing_add_HELP_I_am_trapped_in_a_recursive_loop)
    SET(m "Unexpected Thing_add() recursion detected!!! Did you call")
    SET(m "${m} Thing_add() from inside of Thing_OVERRIDE()? - Call")
    MESSAGE(FATAL_ERROR "${m} Thing_addFromOverride() instead. Aborting.")
  ENDIF()
  SET(Thing_add_HELP_I_am_trapped_in_a_recursive_loop "round-round-round we go")
  IF(TARGET "${name}")
    SET(m "Thing_add() called multiple times for target")
    MESSAGE(FATAL_ERROR  "${m} \"${name}\"!!! Aborting.")
  ENDIF()
  LIST(FIND Thing_SKIP "${name}" isSkipped)
  IF(${isSkipped} EQUAL -1)
    Thing_prefixPaths(prefixPaths)
    IF(NOT CMAKE_BUILD_TYPE)
      SET(bType "Debug")
    ELSE()
      SET(bType "${CMAKE_BUILD_TYPE}")
    ENDIF()
    SET(args "LIST_SEPARATOR" "${Thing_ListSeparator}"
             "PREFIX" "${CMAKE_CURRENT_BINARY_DIR}/${name}"
             "INSTALL_DIR" "${CMAKE_INSTALL_PREFIX}"
             "SOURCE_DIR" "${CMAKE_CURRENT_SOURCE_DIR}/${name}"
             "CMAKE_ARGS" "-DCMAKE_PREFIX_PATH=${prefixPaths}"
                          "-DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}"
                          "-DCMAKE_BUILD_TYPE=${bType}"
             "${ARGN}")
    FOREACH(override IN LISTS Thing_ARGUMENT_OVERRIDES)
      IF(COMMAND "${override}")
        Thing_call("${override}" "\"${name}\" \"${args}\" args")
      ELSE()
        MESSAGE(WARNING "Thing: \"${override}\" in argument overrides is not a command!")
      ENDIF()
    ENDFOREACH()
    IF(COMMAND "Thing_OVERRIDE")
      Thing_OVERRIDE("${name}" "${args}")
    ELSE()
      Thing_addFromOverride("${name}" "${args}")
    ENDIF()
    ExternalProject_Get_Property("${name}" install_dir)
    LIST(FIND CMAKE_PREFIX_PATH "${install_dir}" isInPrefixPath)
    IF(${isInPrefixPath} EQUAL -1)
      LIST(APPEND CMAKE_PREFIX_PATH "${install_dir}")
    ENDIF()
    SET(CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}" PARENT_SCOPE)
    SET(Thing_installDir_${name} "${install_dir}" PARENT_SCOPE)
  ENDIF()
  UNSET(Thing_add_HELP_I_am_trapped_in_a_recursive_loop)
ENDFUNCTION()

FUNCTION(Thing_getProperty name property out)
  ExternalProject_Get_Property("${name}" "${property}")
  SET("${out}" "${${property}}" PARENT_SCOPE)
ENDFUNCTION()
