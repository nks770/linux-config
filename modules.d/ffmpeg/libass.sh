#!/bin/bash

# Functions for detecting and building libass

function libassInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check libass
if [ ! -f ${MODULEPATH}/libass/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_libass() {
if libassInstalled ${1}; then
  echo "libass ${1} is installed."
else
  build_libass ${1}
fi
}

function build_libass() {

# Get desired version number to install
libass_v=${1}
if [ -z "${libass_v}" ] ; then
  libass_v=0.14.0
fi
libass_srcdir=libass-${libass_v}

echo "Installing libass ${libass_v}..."

case ${1} in
  0.14.0) # Oct 31, 2017
   libass_nasm_ver=2.13.03
  ;;
esac

check_modules
check_nasm ${libass_nasm_ver}

module purge
module load nasm/${libass_nasm_ver}
module list

downloadPackage libass-${libass_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${libass_srcdir} ] ; then
  rm -rf ${tmp}/${libass_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/libass-${libass_v}.tar.gz
cd ${tmp}/${libass_srcdir}

./configure --prefix=${opt}/libass-${libass_v}
make -j ${ncpu} && make install

if [ ! $? -eq 0 ] ; then
  exit 4
fi

# Create the environment module
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
mkdir -pv ${MODULEPATH}/libass
cat << eof > ${MODULEPATH}/libass/${libass_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts libass-${libass_v} into your environment"
}

set VER ${libass_v}
set PKG ${opt}/libass-\$VER

module-whatis   "Loads libass-${libass_v}"
conflict libass

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/${libass_srcdir}

}
