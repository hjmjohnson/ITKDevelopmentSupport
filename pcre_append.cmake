#
# install the pcre-config script which Swig needs to descide where to find pcre
set(prefix ${CMAKE_INSTALL_PREFIX})
set(exec_prefix ${CMAKE_INSTALL_PREFIX})
set(libdir ${CMAKE_INSTALL_PREFIX}/libd)
set(includedir ${CMAKE_INSTALL_PREFIX}/include)
set(PACKAGE_VERSION 8.13)
set(enable_cpp yes)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/pcre-config.in ${CMAKE_CURRENT_BINARY_DIR}/pcre-config @ONLY)
install(PROGRAMS ${CMAKE_CURRENT_BINARY_DIR}/pcre-config DESTINATION ${CMAKE_INSTALL_PREFIX}/bin)
