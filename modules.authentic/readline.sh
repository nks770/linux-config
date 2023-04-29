#!/bin/bash

# Functions for detecting and building readline
echo 'Loading readline...'

function readlineInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check readline
if [ ! -f ${MODULEPATH}/readline/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_readline() {
if readlineInstalled ${1}; then
  echo "readline ${1} is installed."
else
  build_readline ${1}
fi
}

function build_readline() {

# Get desired version number to install
readline_v=${1}
if [ -z "${readline_v}" ] ; then
  readline_v=8.2
fi

case ${readline_v} in
7.0) #2016-09-15
   ncurses_ver=6.0  # 2015-08-08
   ;;
8.1) #2020-12-06
   ncurses_ver=6.2  # 2020-02-12
   ;;
8.1.2) #2022-01-05
   ncurses_ver=6.3  # 2021-11-08
   ;;
*)
   echo "ERROR: Review needed for readline ${1}"
   exit 4
   ;;
esac

echo "Installing readline ${readline_v}..."

check_modules
check_ncurses ${ncurses_ver}
module purge
module load ncurses/${ncurses_ver}

downloadPackage readline-${readline_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/readline-${readline_v} ] ; then
  rm -rf ${tmp}/readline-${readline_v}
fi

tar xvfz ${pkg}/readline-${readline_v}.tar.gz
cd ${tmp}/readline-${readline_v}

config="./configure --prefix=${opt}/readline-${readline_v} --with-curses CFLAGS=-I${opt}/ncurses-${ncurses_ver}/include LDFLAGS=-L${opt}/ncurses-${ncurses_ver}/lib"

if [ ${debug} -gt 0 ] ; then
  ./configure --help
  echo ''
  module list
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

# There is no testsuite for readline
#if [ ${run_tests} -gt 0 ] ; then
#  make check
#  echo '>> Tests complete'
#  read k
#fi

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
mkdir -pv ${MODULEPATH}/readline
cat << eof > ${MODULEPATH}/readline/${readline_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts readline-${readline_v} into your environment"
}

set VER ${readline_v}
set PKG ${opt}/readline-\$VER

module-whatis   "Loads readline-${readline_v}"
conflict readline
module load ncurses/${ncurses_ver}
prereq ncurses/${ncurses_ver}

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path MANPATH \$PKG/share/man
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/readline-${readline_v}

}
