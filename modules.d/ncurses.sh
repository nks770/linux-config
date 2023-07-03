#!/bin/bash

# Functions for detecting and building ncurses
echo 'Loading ncurses...'

function ncursesInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check ncurses
if [ ! -f ${MODULEPATH}/ncurses/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_ncurses() {
if ncursesInstalled ${1}; then
  echo "ncurses ${1} is installed."
else
  build_ncurses ${1}
fi
}

function build_ncurses() {

# Get desired version number to install
ncurses_v=${1}
if [ -z "${ncurses_v}" ] ; then
  ncurses_v=6.4
fi

echo "Installing ncurses ${ncurses_v}..."
ncurses_srcdir=ncurses-${ncurses_v}

check_modules

downloadPackage ncurses-${ncurses_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${ncurses_srcdir} ] ; then
  rm -rf ${tmp}/${ncurses_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/ncurses-${ncurses_v}.tar.gz
cd ${tmp}/ncurses-${ncurses_v}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge

config="./configure --prefix=${opt}/ncurses-${ncurses_v} --with-shared"

if [ ${debug} -gt 0 ] ; then
  ./configure --help
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
  make check
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
mkdir -pv ${MODULEPATH}/ncurses
cat << eof > ${MODULEPATH}/ncurses/${ncurses_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts ncurses-${ncurses_v} into your environment"
}

set VER ${ncurses_v}
set PKG ${opt}/ncurses-\$VER

module-whatis   "Loads ncurses-${ncurses_v}"
conflict ncurses

prepend-path PATH \$PKG/bin
prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path MANPATH \$PKG/share/man

eof

cd ${root}
rm -rf ${tmp}/${ncurses_srcdir}

}
