#!/bin/bash

# Functions for detecting and building wavpack

function wavpackInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check wavpack
if [ ! -f ${MODULEPATH}/wavpack/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_wavpack() {
if wavpackInstalled ${1}; then
  echo "wavpack ${1} is installed."
else
  build_wavpack ${1}
fi
}

function build_wavpack() {

# Get desired version number to install
wavpack_v=${1}
if [ -z "${wavpack_v}" ] ; then
  wavpack_v=5.4.0
fi
wavpack_srcdir=wavpack-${wavpack_v}

echo "Installing wavpack ${wavpack_v}..."

#case ${1} in
#  5.2.0) # December 15, 2019
#   wavpack_yasm_ver=1.3.0
#  ;;
#esac

check_modules
module purge
module list

downloadPackage wavpack-${wavpack_v}.tar.bz2

cd ${tmp}

if [ -d ${tmp}/${wavpack_srcdir} ] ; then
  rm -rf ${tmp}/${wavpack_srcdir}
fi

cd ${tmp}
tar xvfj ${pkg}/wavpack-${wavpack_v}.tar.bz2
cd ${tmp}/${wavpack_srcdir}

./configure --prefix=${opt}/wavpack-${wavpack_v}
make -j ${ncpu} && make install

if [ ! $? -eq 0 ] ; then
  exit 4
fi

# Create the environment module
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
mkdir -pv ${MODULEPATH}/wavpack
cat << eof > ${MODULEPATH}/wavpack/${wavpack_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts wavpack-${wavpack_v} into your environment"
}

set VER ${wavpack_v}
set PKG ${opt}/wavpack-\$VER

module-whatis   "Loads wavpack-${wavpack_v}"
conflict wavpack

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig
prepend-path PATH \$PKG/bin
prepend-path MANPATH \$PKG/share/man

eof

cd ${root}
rm -rf ${tmp}/${wavpack_srcdir}

}
