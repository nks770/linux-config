#!/bin/bash

# Functions for detecting and building expat
echo 'Loading expat...'

function expatInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check expat
if [ ! -f ${MODULEPATH}/expat/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_expat() {
if expatInstalled ${1}; then
  echo "expat ${1} is installed."
else
  build_expat ${1}
fi
}

function build_expat() {

# Get desired version number to install
expat_v=${1}
if [ -z "${expat_v}" ] ; then
  echo "ERROR: No expat version specified!"
  exit 2
fi

echo "Installing expat ${expat_v}..."

check_modules
module purge

downloadPackage expat-${expat_v}.tar.bz2

cd ${tmp}

if [ -d ${tmp}/expat-${expat_v} ] ; then
  rm -rf ${tmp}/expat-${expat_v}
fi

tar xvfj ${pkg}/expat-${expat_v}.tar.bz2
cd ${tmp}/expat-${expat_v}

config="./configure --prefix=${opt}/expat-${expat_v}"

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
mkdir -pv ${MODULEPATH}/expat
cat << eof > ${MODULEPATH}/expat/${expat_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts expat-${expat_v} into your environment"
}

set VER ${expat_v}
set PKG ${opt}/expat-\$VER

module-whatis   "Loads expat-${expat_v}"
conflict expat

prepend-path PATH \$PKG/bin
prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path MANPATH \$PKG/share/man
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/expat-${expat_v}

}
