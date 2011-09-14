#
# ITKDevelopmentSupport
#
# A CMake project that builds commonly used tools needed for
# ITK (and other) Development efforts
#
# Author: Kent William
#  EMail: norman-k-williams@uiowa.edu
#
# Each of the tools can be turned off by specifying
# -DUSE_SYSTEM_<ToolName>:BOOL=ON
# On the CMake command line (or toggle that variable in the GUI)
#
cmake_minimum_required(VERSION 2.8)
cmake_policy(VERSION 2.8)

project(ITKDevelopmentSupport)

set(CMAKE_MODULE_PATH
  ${ITKDevelopmentSupport_SOURCE_DIR}/CMake
  ${CMAKE_MODULE_PATH}
)

set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Choose tge type of build" FORCE)

#
# All programs built with External Projects
include(ExternalProject)

#
# By default, build with release flags
#-----------------------------------------------------------------------------
# Set a default build type if none was specified
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  message(STATUS "Setting build type to 'Release' as none was specified.")
  set(CMAKE_BUILD_TYPE RelWithDebInfo CACHE STRING "Choose the type of build." FORCE)
  # Set the possible values of build type for cmake-gui
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()

#
# This macro does the setup to allow the user to use an already-installed
# version of the programs installed by this project.
#
# It's possible to include this project as part of another project
# and then use the ${PackageName}_EXECUTABLE variables as part of a build,
# but it would involve making all targets that depend on that program
# depend on the corresponding ExternalProject defined here.
macro(CheckForSystemVersion PackageName CommandName)
  option(USE_SYSTEM_${PackageName} "Use already-installed ${CommandName}" OFF)
  if(USE_SYSTEM_${PackageName})
    find_program(${PackageName}_EXECUTABLE ${CommandName}
      DOC "location of ${CommandName}")
    if("${${PackageName}_EXECUTABLE}" STREQUAL "${PackageName}_EXECUTABLE-NOTFOUND")
      message(WARNING
        "To use the already-installed ${CommandName}, set ${PackageName}_EXECUTABLE")
    endif()
  else(USE_SYSTEM_${PackageName})
    set(${PackageName}_EXECUTABLE "${CMAKE_INSTALL_PREFIX}/bin/${CommandName}"
      CACHE FILEPATH "Location of program ${CommandName}")
  endif()
endmacro(CheckForSystemVersion)

#
# Uncrustify C/C++ Beautifier
#
# See http://sourceforge.net/projects/uncrustify
#
CheckForSystemVersion(UNCRUSTIFY uncrustify)
#
# External project for Uncrustify
if(NOT USE_SYSTEM_UNCRUSITY)
  ExternalProject_add(uncrustify
    GIT_REPOSITORY git://uncrustify.git.sourceforge.net/gitroot/uncrustify/uncrustify
    GIT_TAG 60f3681da60462eda539b78e0c6c3eea823481e5
    CONFIGURE_COMMAND ../uncrustify/configure
    "--prefix=${CMAKE_INSTALL_PREFIX}"
    CXXFLAGS=${CMAKE_CXX_FLAGS_${CMAKE_BUILD_TYPE}}
    CFLAGS=${CMAKE_C_FLAGS_${CMAKE_BUILD_TYPE}}
    )
endif()

#
# KWStyle -- Kitware Coding Style Checker
# See http://public.kitware.com/KWStyle/
CheckForSystemVersion(KWSTYLE KWStyle)
#
# External project for KWStyle
if(NOT USE_SYSTEM_KWSTYLE)
  ExternalProject_add(KWStyle
    CVS_REPOSITORY :pserver:anoncvs@public.kitware.com:/cvsroot/KWStyle
    CVS_MODULE KWStyle
    CMAKE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    )
endif()

#
# PCRE - Perl compatible regular expressions
# See http://www.pcre.org/
# This is a prerequisite for CPPChack and Swig
#
option(USE_SYSTEM_PCRE "Use installed version of PCRE" OFF)

if(USE_SYSTEM_PCRE)
  find_library(PCRE_LIB NAMES libpcre.dylib libpcre.so libpcre.a
    PATHS /usr/lib /usr/local/lib /lib)
  if(PCRE_LIB-NOTFOUND)
    message(FATAL "Failed to locate libpcre")
  endif()
endif()

#
# External project for pcre
if(NOT USE_SYSTEM_PCRE)
  option(PCRE_SIMPLE_BUILD "Use simplest method to build PCRE" ON)
  if(PCRE_SIMPLE_BUILD)
    # this is the simplest version
    # for building from the release Tar
    # using autoconf-generated Maskefiles
    ExternalProject_add(pcre
      URL http://downloads.sourceforge.net/project/pcre/pcre/8.12/pcre-8.12.tar.gz
      URL_MD5 fa69e4c5d8971544acd71d1f10d59193
      CONFIGURE_COMMAND ../PCRE/configure --prefix=${CMAKE_INSTALL_PREFIX}
      CXXFLAGS=${CMAKE_CXX_FLAGS_${CMAKE_BUILD_TYPE}}
      CFLAGS=${CMAKE_C_FLAGS_${CMAKE_BUILD_TYPE}}
      )
  else()
    # This is an alternate CMake-based version of the build.
    # PCRE has CMakelists.txt but it contains errors and fails to configure
    # and install the pcre-config script, which breaks building Swig.
    set(pcre_script ${CMAKE_CURRENT_LIST_DIR}/pcre_fix_CMakeLists.cmake)
    set(pcre_append ${CMAKE_CURRENT_LIST_DIR}/pcre_append.cmake)
    ExternalProject_add(pcre
      SVN_REPOSITORY svn://vcs.exim.org/pcre/code/tags/pcre-8.13
      PATCH_COMMAND COMMAND ${CMAKE_COMMAND} -Dappend_file=${pcre_append}
      -Dfixfile=<SOURCE_DIR>/CMakeLists.txt -P ${pcre_script}
      CMAKE_ARGS
      -DCMAKE_BUILD_TYPE:STRING=Release
      -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}
      -DCMAKE_BUILD_TYPE:STRING=Release
      )
  endif()
endif()

#
# CPPCheck - A C/C++ static analyzer
# See http://sourceforge.net/apps/mediawiki/cppcheck/index.php?title=Main_Page
#
option(USE_SYSTEM_CPPCHECK "Use already-installed cppcheck" OFF)
find_package(cppcheck)

if(USE_SYSTEM_CPPCHECK AND NOT CPPCHECK_FOUND)
  message(WARNING
    "To use the already-installed cppcheck, set CPPCHECK_EXECUTABLE")
endif()

#
# External project for cppcheck
if(NOT USE_SYSTEM_CPPCHECK OR NOT CPPCHECK_FOUND)
  #
  # CPPCheck just comes with a simple zero-configuration
  # Makefile for building.
  # I wrote a CMakeLists.txt for cppcheck, and it gets
  # pushed into the source tree before configuratino using
  # the ExternalProject PATCH_COMMAND keyword
  ExternalProject_add(cppcheck
    DEPENDS pcre
    GIT_REPOSITORY git://github.com/danmar/cppcheck.git
    GIT_TAG 288efd832cd28e254f6f2352814f28bab6797ffa
    PATCH_COMMAND ${CMAKE_COMMAND} -E copy
    ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt.cppcheck
    <SOURCE_DIR>/CMakeLists.txt
    CMAKE_ARGS
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}
    -DPCRE_LIBRARY_DIR:PATH=${CMAKE_INSTALL_PREFIX}/lib
    -DPCRE_INCLUDE_DIR:PATH=${CMAKE_INSTALL_PREFIX}/include
    )

endif()

#
# Swig - Generate 
CheckForSystemVersion(SWIG swig)
#
# External project for swig
if(NOT USE_SYSTEM_SWIG)
  ExternalProject_add(Swig
    URL http://prdownloads.sourceforge.net/swig/swig-2.0.4.tar.gz
    URL_MD5 4319c503ee3a13d2a53be9d828c3adc0
    CONFIGURE_COMMAND ../Swig/configure --prefix=${CMAKE_INSTALL_PREFIX}
    --with-pcre-prefix=${CMAKE_INSTALL_PREFIX}
    CXXFLAGS=${CMAKE_CXX_FLAGS_${CMAKE_BUILD_TYPE}}
    CFLAGS=${CMAKE_C_FLAGS_${CMAKE_BUILD_TYPE}}
    DEPENDS pcre
    )
endif()

CheckForSystemVersion(VALGRIND valgrind)

if(NOT USE_SYSTEM_VALGRIND)
  ExternalProject_add(valgrind
#    SVN_REPOSITORY svn://svn.valgrind.org/valgrind/tags/VALGRIND_3_6_1
    URL http://valgrind.org/downloads/valgrind-3.6.1.tar.bz2
    URL_MD5 2c3aa122498baecc9d69194057ca88f5
    BUILD_IN_SOURCE 1
    CONFIGURE_COMMAND ../valgrind/configure
    --prefix=${CMAKE_INSTALL_PREFIX}
    CXXFLAGS=${CMAKE_CXX_FLAGS_${CMAKE_BUILD_TYPE}}
    CFLAGS=${CMAKE_C_FLAGS_${CMAKE_BUILD_TYPE}}
    )
endif()
