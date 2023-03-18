#!/bin/bash

# Functions for detecting and building cmake
echo 'Loading cmake...'

function cmakeInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check cmake
if [ ! -f ${MODULEPATH}/cmake/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_cmake() {
if cmakeInstalled ${1}; then
  echo "cmake ${1} is installed."
else
  build_cmake ${1}
fi
}

function build_cmake() {

# Get desired version number to install
cmake_v=${1}
if [ -z "${cmake_v}" ] ; then
  cmake_v=3.11.4
fi
cmake_srcdir=cmake-${cmake_v}

case ${cmake_v} in
3.11.4) # 2018-06-14
   ncurses_ver=6.1  # 2018-01-27
   ;;
*)
   ncurses_ver=6.1  # 2018-01-27
   ;;
esac

echo "Installing cmake ${cmake_v}..."

check_modules
check_ncurses ${ncurses_ver}

module purge
# Note ncurses dependency is to build optional module ccmake (the curses GUI to cmake)
module load ncurses/${ncurses_ver}

downloadPackage cmake-${cmake_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${cmake_srcdir} ] ; then
  rm -rf ${tmp}/${cmake_srcdir}
fi

tar xvfz ${pkg}/cmake-${cmake_v}.tar.gz
cd ${tmp}/${cmake_srcdir}

config="./configure --prefix=${opt}/cmake-${cmake_v} --parallel=${ncpu}"
echo "CMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}"
export CMAKE_PREFIX_PATH=${opt}/ncurses-${ncurses_ver}

if [ ${debug} -gt 0 ] ; then
  ./configure --help
  echo ''
  module list
  echo CMAKE_PREFIX_PATH="${CMAKE_PREFIX_PATH}"
  echo ''
  echo ${config}
  read k
fi

${config}

if [ ${debug} -gt 0 ] ; then
  echo '>> Configure complete'
  read k
fi

make -j ${ncpu}

if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Build complete'
  read k
fi

if [ ${run_tests} -gt 0 ] ; then
  make test
  echo ''
  echo 'NOTE: There is probably a failed test for "kwsys.testSystemTools"'
  echo 'The further details indicate the part that failed is:'
  echo 'TestFileAccess incorrectly indicated that this is a writable file: ...'
  echo ''
  echo 'If the testsuite is run as root, this is an expected failure'
  echo 'More info is available here:'
  echo 'https://gitlab.kitware.com/utils/kwsys/-/merge_requests/251'
  echo ''
  echo '>> Press enter for more info on failed tests (if applicable)'
  echo ''
  ./bin/ctest -V --rerun-failed
  echo ''
  echo '>> Tests complete'
  read k
fi

make install

if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Install complete'
  read k
fi

# Create the environment module
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi
mkdir -pv ${MODULEPATH}/cmake
cat << eof > ${MODULEPATH}/cmake/${cmake_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts cmake-${cmake_v} into your environment"
}

set VER ${cmake_v}
set PKG ${opt}/cmake-\$VER

module-whatis   "Loads cmake-${cmake_v}"
conflict cmake
module load ncurses/${ncurses_ver}
prereq ncurses/${ncurses_ver}

prepend-path PATH \$PKG/bin

eof

cd ${root}
rm -rf ${tmp}/${cmake_srcdir}

}
