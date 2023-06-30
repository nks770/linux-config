#!/bin/bash

# Functions for detecting and building OpenCORE Adaptive Multi Rate (AMR)
echo 'Loading OpenCORE Adaptive Multi Rate (AMR)...'

function opencoreamrInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check opencoreamr
if [ ! -f ${MODULEPATH}/opencore-amr/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_opencoreamr() {
if opencoreamrInstalled ${1}; then
  echo "opencore-amr ${1} is installed."
else
  build_opencoreamr ${1}
fi
}

function build_opencoreamr() {

# Get desired version number to install
opencoreamr_v=${1}
if [ -z "${opencoreamr_v}" ] ; then
  opencoreamr_v=0.1.5
fi

echo "Installing opencore-amr ${opencoreamr_v}..."
opencoreamr_srcdir=opencore-amr-${opencoreamr_v}

check_modules

downloadPackage opencore-amr-${opencoreamr_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${opencoreamr_srcdir} ] ; then
  rm -rf ${tmp}/${opencoreamr_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/opencore-amr-${opencoreamr_v}.tar.gz
cd ${tmp}/${opencoreamr_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge

config="./configure --prefix=${opt}/opencore-amr-${opencoreamr_v}"
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
mkdir -pv ${MODULEPATH}/opencore-amr
cat << eof > ${MODULEPATH}/opencore-amr/${opencoreamr_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts opencoreamr-${opencoreamr_v} into your environment"
}

set VER ${opencoreamr_v}
set PKG ${opt}/opencore-amr-\$VER

module-whatis   "Loads opencore-amr-${opencoreamr_v}"
conflict opencoreamr

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/${opencoreamr_srcdir}

}
