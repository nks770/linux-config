#!/bin/bash

# Functions for detecting and building wavpack
echo 'Loading wavpack...'

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
  echo "ERROR: No wavpack version specified!"
  exit 2
fi

#case ${1} in
#  5.2.0) # December 15, 2019
#   wavpack_yasm_ver=1.3.0
#  ;;
#esac

echo "Installing wavpack ${wavpack_v}..."
wavpack_srcdir=wavpack-${wavpack_v}

check_modules

downloadPackage ${wavpack_srcdir}.tar.bz2

cd ${tmp}

if [ -d ${tmp}/${wavpack_srcdir} ] ; then
  rm -rf ${tmp}/${wavpack_srcdir}
fi

cd ${tmp}
tar xvfj ${pkg}/${wavpack_srcdir}.tar.bz2
cd ${tmp}/${wavpack_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge

config="./configure --prefix=${opt}/wavpack-${wavpack_v}"
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
