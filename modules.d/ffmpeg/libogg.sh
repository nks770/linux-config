#!/bin/bash

# Functions for detecting and building libogg

function liboggInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check libogg
if [ ! -f ${MODULEPATH}/libogg/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_libogg() {
if liboggInstalled ${1}; then
  echo "libogg ${1} is installed."
else
  build_libogg ${1}
fi
}

function build_libogg() {

# Get desired version number to install
libogg_v=${1}
if [ -z "${libogg_v}" ] ; then
  libogg_v=1.3.4
fi
libogg_srcdir=libogg-${libogg_v}

echo "Installing libogg ${libogg_v}..."

#case ${1} in
#  1.3.4) # 2019 August 30
#   libogg_nasm_ver=2.13.03
#  ;;
#esac

check_modules
module purge
module list

downloadPackage libogg-${libogg_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${libogg_srcdir} ] ; then
  rm -rf ${tmp}/${libogg_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/libogg-${libogg_v}.tar.gz
cd ${tmp}/${libogg_srcdir}

./configure --prefix=${opt}/libogg-${libogg_v}
make -j ${ncpu} && make install

if [ ! $? -eq 0 ] ; then
  exit 4
fi

# Create the environment module
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
mkdir -pv ${MODULEPATH}/libogg
cat << eof > ${MODULEPATH}/libogg/${libogg_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts libogg-${libogg_v} into your environment"
}

set VER ${libogg_v}
set PKG ${opt}/libogg-\$VER

module-whatis   "Loads libogg-${libogg_v}"
conflict libogg

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/${libogg_srcdir}

}
