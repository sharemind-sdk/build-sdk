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

IF(CMAKE_VERSION VERSION_LESS 2.8.12)
  MESSAGE(FATAL_ERROR "Thing: CMake 2.8.12 or later required, but version ${CMAKE_VERSION} found!")
ENDIF()

INCLUDE(ExternalProject)
INCLUDE(Thing_gitDownload.cmake)

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
  # General options:
  "DEPENDS" "PREFIX" "LIST_SEPARATOR" "TMP_DIR" "STAMP_DIR" "EXCLUDE_FROM_ALL"
  # Download step options:
  "DOWNLOAD_NAME" "DOWNLOAD_DIR" "DOWNLOAD_COMMAND" "DOWNLOAD_NO_PROGRESS"
  "CVS_REPOSITORY" "CVS_MODULE" "CVS_TAG"
  "SVN_REPOSITORY" "SVN_REVISION" "SVN_USERNAME" "SVN_PASSWORD" "SVN_TRUST_CERT"
  "GIT_REPOSITORY" "GIT_TAG" "GIT_SUBMODULES"
  "HG_REPOSITORY" "HG_TAG"
  "URL" "URL_HASH" "URL_MD5"
  "TLS_VERIFY" "TLS_CAINFO"
  "TIMEOUT"
  # Update/patch step options:
  "UPDATE_COMMAND" "UPDATE_DISCONNECTED" "PATCH_COMMAND"
  # Configure step options:
  "SOURCE_DIR" "CONFIGURE_COMMAND" "CMAKE_COMMAND" "CMAKE_GENERATOR"
  "CMAKE_GENERATOR_PLATFORM" "CMAKE_GENERATOR_TOOLSET" "CMAKE_ARGS"
  "CMAKE_CACHE_ARGS" "CMAKE_CACHE_DEFAULT_ARGS"
  # Build step options:
  "BINARY_DIR" "BUILD_COMMAND" "BUILD_IN_SOURCE" "BUILD_ALWAYS"
  "BUILD_BYPRODUCTS"
  # Install step options:
  "INSTALL_DIR" "INSTALL_COMMAND"
  # Test step options:
  "TEST_BEFORE_INSTALL" "TEST_AFTER_INSTALL" "TEST_EXCLUDE_FROM_MAIN"
  "TEST_COMMAND"
  # Output logging options:
  "LOG_DOWNLOAD" "LOG_UPDATE" "LOG_CONFIGURE" "LOG_BUILD" "LOG_TEST"
  "LOG_INSTALL"
  # Terminal access options:
  "USES_TERMINAL_DOWNLOAD" "USES_TERMINAL_UPDATE" "USES_TERMINAL_CONFIGURE"
  "USES_TERMINAL_BUILD" "USES_TERMINAL_TEST" "USES_TERMINAL_INSTALL"
  # Other options:
  "STEP_TARGETS" "INDEPENDENT_STEP_TARGETS"
  # Thing options:
  "SHALLOW_CLONE"
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
  ThingNewEmptyList(tmp)
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

# Sets an argument if it is not already set:
MACRO(Thing_setDefaultArg out args arg)
  Thing_hasArg("${args}" "${arg}" "${out}")
  IF("${${out}}")
    SET(${out} "${args}")
  ELSE()
    Thing_resetArgs("${args}" "${arg}" "${ARGN}" "${out}")
  ENDIF()
ENDMACRO()

# Constructs a new ExternalProject_Add argument list for an out-of-tree
# configure and build, e.g configure/cmake && make && make install:
FUNCTION(Thing_remoteConfigure name origArgs buildDir sourceDir outArgs)
  SET(argsToRemove DOWNLOAD_NAME DOWNLOAD_DIR DOWNLOAD_COMMAND CVS_REPOSITORY
                   CVS_MODULE CVS_TAG SVN_REPOSITORY SVN_REVISION SVN_USERNAME
                   SVN_PASSWORD SVN_TRUST_CERT GIT_REPOSITORY GIT_TAG
                   HG_REPOSITORY HG_TAG URL URL_HASH URL_MD5 TLS_VERIFY
                   TLS_CAINFO TIMEOUT UPDATE_COMMAND PATCH_COMMAND SOURCE_DIR
                   BINARY_DIR SHALLOW_CLONE)
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
                   BINARY_DIR SHALLOW_CLONE)
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
  Thing_getArgs_concat("${newArgs}" SHALLOW_CLONE shallow_clone)

  # Remove all non-ExternalProject keywords:
  Thing_removeArgs("${newArgs}" SHALLOW_CLONE newArgs)
  FOREACH(keyword IN LISTS Thing_EXTRA_KEYWORDS)
    Thing_removeArgs("${newArgs}" "${keyword}" newArgs)
  ENDFOREACH()

  IF(NOT git_repository)
    ExternalProject_Add("${name}" "${newArgs}")
  ELSE()
    Thing_removeArgs("${newArgs}" UPDATE_COMMAND newArgs)
    Thing_removeArgs("${newArgs}" DOWNLOAD_COMMAND newArgs)
    ExternalProject_Add("${name}" "${newArgs}" UPDATE_COMMAND ${Thing_VoidCommand} DOWNLOAD_COMMAND ${Thing_VoidCommand})

    ExternalProject_Get_Property(${name} source_dir stamp_dir download_dir tmp_dir)
    GET_FILENAME_COMPONENT(src_name "${source_dir}" NAME)
    GET_FILENAME_COMPONENT(work_dir "${source_dir}" PATH)

    Thing_getArgs_concat("${newArgs}" DOWNLOAD_COMMAND download_command)
    SET(download_comment)
    IF(download_command)
      SET(Thing_GitDownloadCommand ${download_command})
    ELSEIF(shallow_clone)
      SET(Thing_GitDownloadCommand "git clone --depth 1 ${git_repository} ${src_name}")
      SET(download_comment "Performing newGitDownload step (git clone --depth 1) for '${name}'")
    ELSE()
      SET(Thing_GitDownloadCommand "git clone ${git_repository} ${src_name}")
      SET(download_comment "Performing newGitDownload step (git clone) for '${name}'")
    ENDIF()

    Thing_getArgs_concat("${newArgs}" GIT_TAG git_tag)
    IF(NOT git_tag)
      SET(git_tag "master")
    ENDIF()

    Thing_getArgs_concat("${newArgs}" UPDATE_COMMAND update_command)
    IF(update_command)
      SET(Thing_GitUpdateCommand ${update_command})
    ELSE()
      SET(Thing_GitUpdateCommand "git show-ref --tags ${git_tag} || git show-ref --heads ${git_tag} && ( git fetch && git checkout ${git_tag} && git merge --ff origin/${git_tag} ) || true")
    ENDIF()

    Thing_getArgs_concat("${newArgs}" LOG_DOWNLOAD log_download)

    SET(depends)

    # For the download step, and the git clone operation, only the repository
    # should be recorded in a configured RepositoryInfo file. If the repo
    # changes, the clone script should be run again. But if only the tag
    # changes, avoid running the clone script again. Let the 'always' running
    # update step checkout the new tag.
    #
    SET(module)
    SET(tag)
    CONFIGURE_FILE(
      "${CMAKE_ROOT}/Modules/RepositoryInfo.txt.in"
      "${stamp_dir}/${name}-gitinfo.txt"
      @ONLY
    )

    Thing_writeGitDownloadScript(${tmp_dir}/${name}-gitclone.cmake ${source_dir}
      git ${git_repository} ${git_tag} ${src_name} ${work_dir}
      ${stamp_dir}/${name}-gitinfo.txt ${stamp_dir}/${name}-gitclone-lastrun.txt
      ${Thing_GitDownloadCommand}
    )

    SET(download_cmd ${CMAKE_COMMAND} -P ${tmp_dir}/${name}-gitclone.cmake)
    LIST(APPEND depends ${stamp_dir}/${name}-gitinfo.txt)

    IF(log_download)
      SET(log LOG log_download)
    ELSE()
      SET(log "")
    ENDIF()
    ExternalProject_Add_Step(
      "${name}" newGitDownload
      COMMENT ${download_comment}
      COMMAND ${download_cmd}
      WORKING_DIRECTORY ${work_dir}
      DEPENDEES mkdir
      DEPENDERS download
      ${log})

    Thing_getArgs_concat("${newArgs}" LOG_UPDATE log_update)
    IF(log_update)
      SET(log LOG log_update)
    ELSE()
      SET(log "")
    ENDIF()
    ExternalProject_Add_Step(
      "${name}" newGitUpdate
      COMMAND sh -c ${Thing_GitUpdateCommand}
      DEPENDEES download
      DEPENDERS update
      ALWAYS 1
      WORKING_DIRECTORY "${source_dir}"
      ${log})

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
  Thing_join("${out}" "${Thing_ListSeparator}" ${CMAKE_PREFIX_PATH})
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
    IF(NOT CMAKE_BUILD_TYPE)
      SET(bType "Debug")
    ELSE()
      SET(bType "${CMAKE_BUILD_TYPE}")
    ENDIF()
    SET(args "${ARGN}")
    Thing_setDefaultArg(args "${args}" "LIST_SEPARATOR"
                          "${Thing_ListSeparator}")
    Thing_getArgs_concat("${args}" "LIST_SEPARATOR" separator)
    Thing_setDefaultArg(args "${args}" "PREFIX"
                          "${CMAKE_CURRENT_BINARY_DIR}/${name}")
    Thing_setDefaultArg(args "${args}" "INSTALL_DIR"
                          "${CMAKE_INSTALL_PREFIX}")
    Thing_setDefaultArg(args "${args}" "SOURCE_DIR"
                          "${CMAKE_CURRENT_SOURCE_DIR}/${name}")
    Thing_join(prefixPaths "${separator}" ${CMAKE_PREFIX_PATH})
    Thing_setDefaultArg(args "${args}" "CMAKE_ARGS"
                          "-DCMAKE_PREFIX_PATH=${prefixPaths}"
                          "-DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}"
                          "-DCMAKE_BUILD_TYPE=${bType}")
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
