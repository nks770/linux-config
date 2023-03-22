#!/bin/bash

# Functions for detecting and building gdbm
echo 'Loading gdbm...'

function gdbmInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check gdbm
if [ ! -f ${MODULEPATH}/gdbm/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_gdbm() {
if gdbmInstalled ${1}; then
  echo "gdbm ${1} is installed."
else
  build_gdbm ${1}
fi
}

function build_gdbm() {

# Get desired version number to install
gdbm_v=${1}
if [ -z "${gdbm_v}" ] ; then
  gdbm_v=1.23
fi

case ${gdbm_v} in
1.14.1) #2018-01-03
   readline_ver=7.0 #2016-09-15
   ncurses_ver=6.0  #2015-08-08
   ;;
1.19) #2020-12-23
   readline_ver=8.1 #2020-12-06
   ncurses_ver=6.2  #2020-02-12
   ;;
1.23) #2022-02-04
   readline_ver=8.1.2 #2022-01-05
   ncurses_ver=6.3    #2021-11-08
   ;;
*)
   echo "ERROR: Need review for gdbm ${1}"
   exit 4
   ;;
esac
echo "Installing gdbm ${gdbm_v}..."

check_modules
check_readline ${readline_ver}
check_ncurses ${ncurses_ver}
module purge
module load readline/${readline_ver} ncurses/${ncurses_ver}

downloadPackage gdbm-${gdbm_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/gdbm-${gdbm_v} ] ; then
  rm -rf ${tmp}/gdbm-${gdbm_v}
fi

tar xvfz ${pkg}/gdbm-${gdbm_v}.tar.gz
cd ${tmp}/gdbm-${gdbm_v}

config="./configure --prefix=${opt}/gdbm-${gdbm_v} --enable-libgdbm-compat CPPFLAGS=-I/opt/readline-${readline_ver}/include"
export LDFLAGS="-L/opt/readline-${readline_ver}/lib -L/opt/ncurses-${ncurses_ver}/lib"

if [ ${debug} -gt 0 ] ; then
  ./configure --help
  echo ''
  module list
  echo ''
  echo LDFLAGS="${LDFLAGS}"
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
mkdir -pv ${MODULEPATH}/gdbm
cat << eof > ${MODULEPATH}/gdbm/${gdbm_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts gdbm-${gdbm_v} into your environment"
}

set VER ${gdbm_v}
set PKG ${opt}/gdbm-\$VER

module-whatis   "Loads gdbm-${gdbm_v}"
conflict gdbm
module load readline/${readline_ver} ncurses/${ncurses_ver}
prereq readline/${readline_ver}
prereq ncurses/${ncurses_ver}

prepend-path PATH \$PKG/bin
prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path MANPATH \$PKG/share/man

eof

cd ${root}
rm -rf ${tmp}/gdbm-${gdbm_v}

}
