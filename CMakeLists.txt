# CMakeLists.txt for core testing in
# editorconfig-core-c.
#
# Copyright (c) 2011-2019 EditorConfig Team
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#

cmake_minimum_required(VERSION 3.5.1)
cmake_policy(VERSION 3.5.1)

project(editorconfig VERSION "0.12.7" LANGUAGES C)

set(PROJECT_VERSION_SUFFIX "-development")

include(GNUInstallDirs)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/CMake_Modules")

# set default compilation directory
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/lib")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/lib")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/bin")

# uninstall target
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake_uninstall.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
    IMMEDIATE @ONLY)

add_custom_target(uninstall
    COMMAND ${CMAKE_COMMAND} -P
    ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)

# package target
set(HOME_URL "https://editorconfig.org")
set(MAILING_LIST "editorconfig@googlegroups.com")

set(CPACK_PACKAGE_VENDOR "EditorConfig Team")
set(CPACK_PACKAGE_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${PROJECT_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${PROJECT_VERSION_PATCH})
set(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE")
set(CPACK_RESOURCE_FILE_README "${CMAKE_CURRENT_SOURCE_DIR}/README.md")

# Export compilation database for sonarlint
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CPACK_PACKAGE_INSTALL_DIRECTORY "editorconfig")

if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin") # Mac OS X
    set(CPACK_GENERATOR "STGZ;TGZ;TZ")
elseif(UNIX)
    # UNIX should be checked before WIN32 since cygwin makes UNIX and WIN32
    # both true
    set(CPACK_GENERATOR "STGZ;TGZ;TZ;DEB;RPM")
elseif(WIN32)
    set(CPACK_GENERATOR "ZIP;NSIS")
endif()

set(CPACK_MONOLITHIC_INSTALL 1)
set(CPACK_SOURCE_GENERATOR "TGZ;TBZ2")
set(CPACK_PACKAGE_CONTACT "EditorConfig <${MAILING_LIST}>")
set(CPACK_PACKAGE_DESCRIPTION_FILE ${CMAKE_CURRENT_SOURCE_DIR}/README.md)
set(CPACK_SYSTEM_NAME "${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_PROCESSOR}")
# get the architecture of Deb package. The name of the architecture is not
# always the same with ${CMAKE_SYSTEM_PROCESSOR}
if(NOT CPACK_DEBIAN_PACKAGE_ARCHITECTURE)
    execute_process(COMMAND dpkg --print-architecture
        OUTPUT_VARIABLE arch OUTPUT_STRIP_TRAILING_WHITESPACE)
    set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "${arch}")
endif()
set(CPACK_DEBIAN_PACKAGE_HOMEPAGE ${HOME_URL})
set(CPACK_NSIS_CONTACT ${CPACK_PACKAGE_CONTACT})
set(CPACK_NSIS_DISPLAY_NAME "EditorConfig Core")
set(CPACK_NSIS_PACKAGE_HOMEPAGE ${HOME_URL})
set(CPACK_PACKAGE_INSTALL_REGISTRY_KEY "editorconfig")
set(CPACK_RPM_PACKAGE_ARCHITECTURE ${CMAKE_SYSTEM_PROCESSOR})
set(CPACK_RPM_PACKAGE_LICENSE "Simplified BSD license")
set(CPACK_RPM_PACKAGE_URL ${HOME_URL})
include(CPack)

add_subdirectory(src)
add_subdirectory(doc)
add_subdirectory(include)

# Testing. Type "make test" to run tests. Only do this if the test submodule is
# checked out.
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/tests/CMakeLists.txt)
    enable_testing()
    set(EDITORCONFIG_CMD "editorconfig_bin")
    set(EDITORCONFIG_CMD_IS_TARGET TRUE)
        # TRUE => use the given CMake target, here, "editorconfig_bin",
        # rather than an executable file named "editorconfig_bin".
        # Used by tests/CMakeLists.txt.
    add_subdirectory(tests)
    message(STATUS "Tests enabled")
else()
    message(WARNING
        " Testing files are not found. Testing will not be available. If you obtained the source tree through git, please run `git submodule update --init` to update the tests submodule.")
endif()

# This is a way to find the EXE name for debugging.  However, it issues a
# CMake warning under policy CMP0026.
#get_target_property(out_name editorconfig_bin LOCATION)
#message(STATUS "main: Editorconfig binary will be in -${out_name}-")
