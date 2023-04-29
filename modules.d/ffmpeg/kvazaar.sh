#!/bin/bash

# Functions for detecting and building kvazaar

function kvazaarInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check kvazaar
if [ ! -f ${MODULEPATH}/kvazaar/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_kvazaar() {
if kvazaarInstalled ${1}; then
  echo "kvazaar ${1} is installed."
else
  build_kvazaar ${1}
fi
}

function build_kvazaar() {

# Get desired version number to install
kvazaar_v=${1}
if [ -z "${kvazaar_v}" ] ; then
  kvazaar_v=1.3.0
fi
kvazaar_srcdir=kvazaar-${kvazaar_v}

echo "Installing kvazaar ${kvazaar_v}..."

case ${1} in
  1.3.0) # Jul 9, 2019
   kvazaar_yasm_ver=1.3.0
  ;;
esac

check_modules
# Yasm is optional, but some of the optimization will not be compiled in if it's missing.
check_yasm ${kvazaar_yasm_ver}

module purge
module load yasm/${kvazaar_yasm_ver}
module list

downloadPackage kvazaar-${kvazaar_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${kvazaar_srcdir} ] ; then
  rm -rf ${tmp}/${kvazaar_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/kvazaar-${kvazaar_v}.tar.gz
cd ${tmp}/${kvazaar_srcdir}

./configure --prefix=${opt}/kvazaar-${kvazaar_v}
make -j ${ncpu} && make install

if [ ! $? -eq 0 ] ; then
  exit 4
fi

# Create the environment module
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
mkdir -pv ${MODULEPATH}/kvazaar
cat << eof > ${MODULEPATH}/kvazaar/${kvazaar_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts kvazaar-${kvazaar_v} into your environment"
}

set VER ${kvazaar_v}
set PKG ${opt}/kvazaar-\$VER

module-whatis   "Loads kvazaar-${kvazaar_v}"
conflict kvazaar

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig
prepend-path PATH \$PKG/bin
prepend-path MANPATH \$PKG/share/man

eof

cd ${root}
rm -rf ${tmp}/${kvazaar_srcdir}

}
