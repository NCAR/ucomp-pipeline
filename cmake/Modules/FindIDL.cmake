# Copyright (c) 2012-2015, Michael Galloy <mgalloy@gmail.com>
# Copyright (c) 2013, Lars Baehren <lbaehren@gmail.com>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#  * Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
#  * Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# - FindIDL: Module to find the IDL distribution.
#
# Module usage:
#   find_package(IDL ...)
#
# Specify IDL_ROOT_DIR to indicate the location of an IDL distribution.
#
# This module will define the following variables:
#   IDL_FOUND           = whether IDL was found
#   IDL_LICENSED        = whether IDL was licensed to run
#   IDL_PLATFORM_EXT    = DLM extension, i.e., darwin.x86_64, linux.x86, etc.
#   IDL_DLL_EXT         = extension for DLM shared objects, i.e., so, dll
#   IDL_INCLUDE_DIR     = IDL include directory
#   IDL_LIBRARY         = IDL shared library location
#   IDL_LIBRARY_PATH    = IDL shared library directory
#   IDL_EXECUTABLE      = IDL command
#   IDL_PATH_SEP        = character to separate IDL paths
#   IDL_ROOT_DIR        = root of IDL distribution

if (NOT IDL_FOUND)
  include(FindPackageHandleStandardArgs)

  # convenience variable for ITT's install dir, should be fixed to use
  # Program Files env var but it is problematic in cygwin
  if ("${CMAKE_SYSTEM_NAME}" STREQUAL "Windows")
    set(_IDL_PROGRAM_FILES_DIR "C:/Program Files")
    set(_IDL_NAME "IDL")
    set(_IDL_OS "")
    set(_IDL_KNOWN_COMPANIES "Harris" "Exelis" "ITT")
    set(IDL_PATH_SEP ";")
    set(IDL_DLL_EXT "dll")
  elseif ("${CMAKE_SYSTEM_NAME}" STREQUAL "CYGWIN")
    set(_IDL_PROGRAM_FILES_DIR "/cygdrive/c/Program Files")
    set(_IDL_NAME "IDL")
    set(_IDL_OS "")
    set(_IDL_KNOWN_COMPANIES "Harris" "Exelis" "ITT")
    set(IDL_PATH_SEP ";")
    set(IDL_DLL_EXT "dll")
    # Cygwin assumes Linux conventions, but IDL is a Windows application
    set (CMAKE_FIND_LIBRARY_SUFFIXES ".lib")
    set (CMAKE_FIND_LIBRARY_PREFIXES "")
  elseif ("${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin")
    set(_IDL_PROGRAM_FILES_DIR "/Applications")
    set(_IDL_NAME "idl")
    set(_IDL_OS "darwin.")
    set(_IDL_KNOWN_COMPANIES "harris" "exelis" "itt")
    set(IDL_PATH_SEP ":")
    set(IDL_DLL_EXT "so")
  elseif ("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux")
    set(_IDL_PROGRAM_FILES_DIR "/usr/local")
    set(_IDL_NAME "idl")
    set(_IDL_OS "linux.")
    set(_IDL_KNOWN_COMPANIES "harris" "exelis" "itt")
    set(IDL_PATH_SEP ":")
    set(IDL_DLL_EXT "so")
  endif ()

  # 32 vs. 64 bit
  if ("${CMAKE_SIZEOF_VOID_P}" STREQUAL "4")
    set(IDL_BIN_EXT "x86")
  elseif ("${CMAKE_SIZEOF_VOID_P}" STREQUAL "8")
    set(IDL_BIN_EXT "x86_64")
  else ()
    set(IDL_BIN_EXT "unknown")
  endif ()

  # find IDL based on version numbers, if you want a specific one, set
  # it prior to running configure
  if (NOT DEFINED IDL_FIND_VERSION)
    set(_IDL_KNOWN_VERSIONS "87" "86" "85" "84" "83" "82" "81" "80" "71" "706")
    # IDL 8.0 is in a different location than other versions on Windows (extra
    # IDL directory in path)
    foreach (_IDL_COMPANY ${_IDL_KNOWN_COMPANIES})
      list(APPEND
           _IDL_SEARCH_DIRS
           "${_IDL_PROGRAM_FILES_DIR}/${_IDL_COMPANY}/${_IDL_NAME}/${_IDL_NAME}80")
      list(APPEND
           _IDL_SEARCH_DIRS
           "${_IDL_PROGRAM_FILES_DIR}/${_IDL_COMPANY}/${_IDL_NAME}/${_IDL_NAME}81")
      foreach (_IDL_KNOWN_VERSION ${_IDL_KNOWN_VERSIONS})
        list(APPEND _IDL_SEARCH_DIRS
             "${_IDL_PROGRAM_FILES_DIR}/${_IDL_COMPANY}/${_IDL_NAME}${_IDL_KNOWN_VERSION}")
      endforeach (_IDL_KNOWN_VERSION ${_IDL_KNOWN_VERSIONS})
    endforeach (_IDL_COMPANY ${_IDL_KNOWN_COMPANIES})
  endif ()

  if (NOT "$ENV{IDL_DIR}" STREQUAL "")
    set(_IDL_SEARCH_DIRS "$ENV{IDL_DIR}")
  endif ()

  find_path(IDL_INCLUDE_DIR
    idl_export.h
    PATHS ${_IDL_SEARCH_DIRS}
    HINTS ${IDL_ROOT_DIR}
    PATH_SUFFIXES external/include
  )

  set(IDL_PLATFORM_EXT "${_IDL_OS}${IDL_BIN_EXT}")

  find_library(IDL_LIBRARY
    NAMES idl
    PATHS ${_IDL_SEARCH_DIRS}
    HINTS ${IDL_ROOT_DIR}
    PATH_SUFFIXES bin/bin.${IDL_PLATFORM_EXT}
  )

  get_filename_component(_IDL_EXECUTABLE_PATH "${IDL_INCLUDE_DIR}/../../bin" ABSOLUTE)
  find_program(IDL_EXECUTABLE idl${CMAKE_EXECUTABLE_SUFFIX}
    PATHS ${_IDL_EXECUTABLE_PATH}
    NO_DEFAULT_PATH
    )

  if (IDL_INCLUDE_DIR AND IDL_LIBRARY AND IDL_EXECUTABLE)
    set(IDL_FOUND TRUE)
  endif ()

  if (IDL_FOUND)
    set(_testIDLVersion ${CMAKE_CURRENT_BINARY_DIR}/TestIDLVersion.c)

    file(WRITE  ${_testIDLVersion} "#include <stdio.h>\n")
    file(APPEND ${_testIDLVersion} "#include <idl_export.h>\n")
    file(APPEND ${_testIDLVersion} "int main () {\n")
    file(APPEND ${_testIDLVersion} "  printf(\"%i;%i;%i\", IDL_VERSION_MAJOR, IDL_VERSION_MINOR, IDL_VERSION_SUB);\n")
    file(APPEND ${_testIDLVersion} "  return 0;\n")
    file(APPEND ${_testIDLVersion} "}\n")

    try_run(run_TestIDL compile_TestIDL
      ${CMAKE_CURRENT_BINARY_DIR}
      ${_testIDLVersion}
      CMAKE_FLAGS -DINCLUDE_DIRECTORIES=${IDL_INCLUDE_DIR}
      COMPILE_OUTPUT_VARIABLE IDL_VERSION_COMPILE_OUTPUT
      RUN_OUTPUT_VARIABLE IDL_VERSION
      )
  endif ()

  if (IDL_VERSION)
      list(GET IDL_VERSION 0 IDL_VERSION_MAJOR)
      list(GET IDL_VERSION 1 IDL_VERSION_MINOR)
      list(GET IDL_VERSION 2 IDL_VERSION_SUB)
      set(IDL_VERSION "${IDL_VERSION_MAJOR}.${IDL_VERSION_MINOR}.${IDL_VERSION_SUB}")
  else ()
      find_file(IDL_VERSION_TXT version.txt
        HINTS ${IDL_ROOT_DIR}
        )
      if (IDL_VERSION_TXT)
        file(READ "${IDL_VERSION_TXT}" _IDL_VERSION)
        string(STRIP "${_IDL_VERSION}" IDL_VERSION)
      endif ()
  endif ()

  find_package_handle_standard_args(IDL DEFAULT_MSG IDL_LIBRARY IDL_INCLUDE_DIR)

  if (IDL_FOUND)
    # find the version
    get_filename_component(IDL_ROOT_DIR "${IDL_INCLUDE_DIR}/../.." ABSOLUTE)
    get_filename_component(IDL_LIBRARY_PATH "${IDL_LIBRARY}" PATH)

    # determine if IDL is licensed
    execute_process(
      COMMAND ${IDL_EXECUTABLE} -IDL_STARTUP "" -quiet -IDL_QUIET 1 -e "print, lmgr(/demo)"
      OUTPUT_VARIABLE LMGR_OUTPUT
      ERROR_VARIABLE LMGR_ERROR
    )
    string(STRIP "${LMGR_OUTPUT}" LMGR_OUTPUT)
    if (LMGR_OUTPUT)
      set(IDL_LICENSED FALSE)
    else ()
      set(IDL_LICENSED TRUE)
    endif ()

    if (NOT IDL_FIND_QUIETLY)
      message(STATUS "Found components for IDL")
      message(STATUS "IDL_VERSION     = ${IDL_VERSION}")
      message(STATUS "IDL_EXECUTABLE  = ${IDL_EXECUTABLE}")
      message(STATUS "IDL_INCLUDE_DIR = ${IDL_INCLUDE_DIR}")
      message(STATUS "IDL_LIBRARY     = ${IDL_LIBRARY}")
      message(STATUS "IDL_LICENSED    = ${IDL_LICENSED}")
    endif ()
  else ()
    set(IDL_LICENSED FALSE)

    if (IDL_FIND_REQUIRED)
      message(FATAL_ERROR "Could not find IDL!")
    endif ()
  endif ()

  mark_as_advanced (
    IDL_INCLUDE_DIR
    IDL_LIBRARY
    )
endif()
