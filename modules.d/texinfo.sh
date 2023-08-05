#!/bin/bash

# Functions for detecting and building texinfo
echo 'Loading texinfo...'

function texinfoInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check texinfo
if [ ! -f ${MODULEPATH}/texinfo/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_texinfo() {
if texinfoInstalled ${1}; then
  echo "texinfo ${1} is installed."
else
  build_texinfo ${1}
fi
}

function build_texinfo() {

# Get desired version number to install
texinfo_v=${1}
if [ -z "${texinfo_v}" ] ; then
  texinfo_v=6.3
fi

case ${texinfo_v} in
6.3) # 2016-09-10
   ncurses_ver=6.0 # 2015-08-08
   ;;
7.0) # 2022-11-07
   ncurses_ver=6.3 # 2021-11-08
   ;;
7.0.3) # 2023-03-26
   ncurses_ver=6.4 # 2022-12-31
   ;;
*)
   echo "ERROR: Need review for texinfo ${1}"
   exit 4
   ;;
esac

# Optimized dependency strategy
if [ "${dependency_strategy}" == "optimized" ] ; then
  ncurses_ver=${global_ncurses}
fi

echo "Installing texinfo ${texinfo_v}..."

check_modules
check_ncurses ${ncurses_ver}
module purge
module load ncurses/${ncurses_ver}

downloadPackage texinfo-${texinfo_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/texinfo-${texinfo_v} ] ; then
  rm -rf ${tmp}/texinfo-${texinfo_v}
fi

tar xvfz ${pkg}/texinfo-${texinfo_v}.tar.gz
cd ${tmp}/texinfo-${texinfo_v}


config="./configure --prefix=${opt}/texinfo-${texinfo_v} CPPFLAGS=-I${opt}/ncurses-${ncurses_ver}/include LDFLAGS=-L${opt}/ncurses-${ncurses_ver}/lib"

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
mkdir -pv ${MODULEPATH}/texinfo
cat << eof > ${MODULEPATH}/texinfo/${texinfo_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts texinfo-${texinfo_v} into your environment"
}

set VER ${texinfo_v}
set PKG ${opt}/texinfo-\$VER

module-whatis   "Loads texinfo-${texinfo_v}"
conflict texinfo
module load ncurses/${ncurses_ver}
prereq ncurses/${ncurses_ver}

prepend-path PATH \$PKG/bin
prepend-path MANPATH \$PKG/share/man

eof

cd ${root}
rm -rf ${tmp}/texinfo-${texinfo_v}

}
