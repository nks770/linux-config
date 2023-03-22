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
3.10.1) # 2017-12-14
   ncurses_ver=6.0  # 2015-08-08
   ;;
3.11.4) # 2018-06-14
   ncurses_ver=6.1  # 2018-01-27
   ;;
3.15.2) # 2019-08-07
   ncurses_ver=6.1  # 2018-01-27
   ;;
3.15.5) # 2019-10-30
   ncurses_ver=6.1  # 2018-01-27
   ;;
*)
   echo "ERROR: Review needed for cmake ${1}"
   exit 4 # Need to review
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
  # Patch to enable avoid a testsuite failure when compiled with newer GCC
  # I borrowed this update from referencing cmake 3.11.4 (slightly newer)
  # This is for test # "34 - CompileFeatures"
  if [ "${cmake_v}" == "3.10.1" ] ; then
    cat << eof > testsuite.patch
Index: Tests/CompileFeatures/default_dialect.c
===================================================================
--- Tests/CompileFeatures/default_dialect.c        2017-12-13 07:25:23.000000000 -0600
+++ Tests/CompileFeatures/default_dialect.c        2018-06-14 07:57:32.000000000 -0500
@@ -1,6 +1,6 @@

 #if DEFAULT_C11
-#if __STDC_VERSION__ != 201112L
+#if __STDC_VERSION__ < 201112L
 #error Unexpected value for __STDC_VERSION__.
 #endif
 #elif DEFAULT_C99
eof
    patch -Z -b -p0 < testsuite.patch
    if [ ! $? -eq 0 ] ; then
      exit 4
    fi
    if [ ${debug} -gt 0 ] ; then
      echo '>> Testsuite patching complete'
      read k
    fi
  fi
  make test
  echo ''
  echo 'NOTE: You are probably seeing a failed test for "kwsys.testSystemTools"'
  echo 'Looking further into the matter, the specific error message is:'
  echo 'TestFileAccess incorrectly indicated that this is a writable file: ...'
  echo ''
  echo 'If the testsuite is run as root, this is an expected failure'
  echo 'More info is available here:'
  echo 'https://gitlab.kitware.com/utils/kwsys/-/merge_requests/251'
  echo ''
  echo '>> Press enter for more info on failed tests (if applicable)'
  read k
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
