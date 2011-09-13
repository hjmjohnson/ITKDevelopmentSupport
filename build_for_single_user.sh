#!/bin/sh

ThisComputer=$(hostname)

echo This script will build ITKDevelopmentSupport
echo and install it in your home directory
echo in the directory ~/${ThisComputer}-utils
echo Then you would add ~/${ThisComputer}-utils/bin to your path.
echo ""
echo If you want to install into a different directory, use the
echo flag --install-dir, e.g. build_for_single_user --install-dir '~/utils'
echo ""

if [ $# = 0 ] ; then
    install_dir=~/${ThisComputer}-utils
elif [ "${1}" = "--install-dir" ] ; then
    shift
    echo setting install_dir=${1}
    install_dir=$1
    shift
fi

if [ ! -d ITKDevelopmentSupport ] ; then
    echo This script is meant to be run in the parent directory of
    echo the ITKDevelopmentEnvironment Source directory
    echo Exiting
    exit 1
fi

OS=$(uname -s)
if [ "${OS}" = "Linux" ] ; then
    NPROCS=$(grep -c ^processor /proc/cpuinfo)
else
    NPROCS=$(system_profiler | awk '/Number Of Cores/{print $5}{next;}')
fi

echo building in $(pwd)/ITKDev-build and installing in ${install_dir}

mkdir -p ITKDev-build
cd ITKDev-build
cmake "-DCMAKE_INSTALL_PREFIX:PATH=${install_dir}" ../ITKDevelopmentSupport
make #-j ${NPROCS}
