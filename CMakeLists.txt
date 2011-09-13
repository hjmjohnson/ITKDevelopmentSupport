cmake_minimum_required(VERSION 2.8)
cmake_policy(VERSION 2.8)

project(ITKDevelopmentSupport)

include(ExternalProject)

if("${CMAKE_BUILD_TYPE}" STREQUAL "")
set(CMAKE_BUILD_TYPE Release)
endif()

#
# External project for Uncrustify
option(USE_SYSTEM_UNCRUSTIFY  "Use already-installed uncrustify" OFF)

if(USE_SYSTEM_UNCRUSTIFY)
  find_program(UNCRUSTIFY_EXE uncrustify
    DOC "path of uncrustify program"
    )
  if("${UNCRUSTIFY_EXE}" STREQUAL "")
    message(WARNING "To use the system uncrustify, set UNCRUSTIFY_EXE")
  endif()

endif()

if(NOT USE_SYSTEM_UNCRUSITY)
  ExternalProject_add(uncrustify
    GIT_REPOSITORY git://uncrustify.git.sourceforge.net/gitroot/uncrustify/uncrustify
    GIT_TAG 60f3681da60462eda539b78e0c6c3eea823481e5
    CONFIGURE_COMMAND ../uncrustify/configure
    "--prefix=${CMAKE_INSTALL_PREFIX}"
    CXXFLAGS=${CMAKE_CXX_FLAGS_${CMAKE_BUILD_TYPE}}
    CFLAGS=${CMAKE_C_FLAGS_${CMAKE_BUILD_TYPE}}
    )
  set(UNCRUSTIFY_EXE "${CMAKE_BINARY_DIR}/Utils/bin/uncrustify" CACHE PATH
    "Absolute path for uncrustify")
endif()

#
# External project for KWStyle
option(USE_SYSTEM_KWSTYLE  "Use already-installed KWStyle" OFF)

if(USE_SYSTEM_KWSTYLE)
  find_program(KWSTYLE_EXE KWStyle
    DOC "path of KWStyle program"
    )
  if("${KWSTYLE_EXE}" STREQUAL "")
    message(WARNING "To use the system KWStyle, set KWSTYLE_EXE")
  endif()

endif()

if(NOT USE_SYSTEM_KWSTYLE)
  ExternalProject_add(KWStyle
    CVS_REPOSITORY :pserver:anoncvs@public.kitware.com:/cvsroot/KWStyle
    CVS_MODULE KWStyle
    CMAKE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}
    -DCMAKE_BUILD_TYPE:STRING=Release
    )
endif()

#
# External project for pcre
option(USE_SYSTEM_PCRE "Use installed version of PCRE" OFF)
if(USE_SYSTEM_PCRE)
  find_library(PCRE_LIB NAMES libpcre.dylib libpcre.so libpcre.a
    PATHS /usr/lib /usr/local/lib /lib)
  if(PCRE_LIB-NOTFOUND)
    message(FATAL "Failed to locate libpcre")
  endif()
endif()

if(NOT USE_SYSTEM_PCRE)
  set(pcre_script ${CMAKE_CURRENT_LIST_DIR}/pcre_fix_CMakeLists.cmake)
  set(pcre_append ${CMAKE_CURRENT_LIST_DIR}/pcre_append.cmake)
  ExternalProject_add(pcre
    #    URL http://downloads.sourceforge.net/project/pcre/pcre/8.12/pcre-8.12.tar.gz
    #    URL_MD5 d41d8cd98f00b204e9800998ecf8427e
    SVN_REPOSITORY svn://vcs.exim.org/pcre/code/tags/pcre-8.13
    #    CONFIGURE_COMMAND ../pcre/configure --prefix=${CMAKE_INSTALL_PREFIX}
    #    CXXFLAGS="${CMAKE_CXX_FLAGS_${CMAKE_BUILD_TYPE}}"
    #    CFLAGS="${CMAKE_C_FLAGS_${CMAKE_BUILD_TYPE}}"
    PATCH_COMMAND COMMAND ${CMAKE_COMMAND} -Dappend_file=${pcre_append}
    -Dfixfile=<SOURCE_DIR>/CMakeLists.txt -P ${pcre_script}
    CMAKE_ARGS
    -DCMAKE_BUILD_TYPE:STRING=Release
    -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}
    -DCMAKE_BUILD_TYPE:STRING=Release
    )
  # ExternalProject_add_step(pcre fix_CMakeLists_txt
  #   COMMENT "Fix typo in CMakeLists.txt"
  #   DEPENDEES download
  #   DEPENDERS configure
  #   COMMAND ${CMAKE_COMMAND} -Dfixfile=${pcre_CMakeLists_txt} -P ${pcre_script}
  #   )
endif()

#
# External project for cppcheck
option(USE_SYSTEM_CPPCHECK  "Use already-installed cppcheck" OFF)

if(USE_SYSTEM_CPPCHECK)
  find_program(CPPCHECK_EXE cppcheck
    DOC "path of cppcheck program"
    )
  if("${CPPCHECK_EXE}" STREQUAL "")
    message(WARNING "To use the system cppcheck, set CPPCHECK_EXE")
  endif()
endif()
 
if(NOT USE_SYSTEM_CPPCHECK)
  ExternalProject_add(cppcheck
    DEPENDS pcre
    GIT_REPOSITORY git://github.com/danmar/cppcheck.git
    GIT_TAG 288efd832cd28e254f6f2352814f28bab6797ffa
    PATCH_COMMAND ${CMAKE_COMMAND} -E copy
    ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt.cppcheck
    <SOURCE_DIR>/CMakeLists.txt

    CMAKE_ARGS
    -DCMAKE_BUILD_TYPE:STRING=Release
    -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}
    -DPCRE_LIBRARY_DIR:PATH=${CMAKE_INSTALL_PREFIX}/lib
    -DPCRE_INCLUDE_DIR:PATH=${CMAKE_INSTALL_PREFIX}/include
    )

endif()

#
# External project for swig
option(USE_SYSTEM_SWIG  "Use already-installed swig" OFF)

if(USE_SYSTEM_SWIG)
  find_program(SWIG_EXE swig
    DOC "path of swig program"
    )
  if("${SWIG_EXE}" STREQUAL "")
    message(WARNING "To use the system swig, set SWIG_EXE")
  endif()
endif()

if(NOT USE_SYSTEM_CPPCHECK)
  ExternalProject_add(swig
    DEPENDS pcre
    GIT_REPOSITORY git://github.com/Chaircrusher/SWIG_204.git
    CONFIGURE_COMMAND ../swig/configure --prefix=${CMAKE_INSTALL_PREFIX}
    --with-pcre-prefix=${CMAKE_INSTALL_PREFIX}
    CXXFLAGS=${CMAKE_CXX_FLAGS_${CMAKE_BUILD_TYPE}}
    CFLAGS=${CMAKE_C_FLAGS_${CMAKE_BUILD_TYPE}}
    )
endif()