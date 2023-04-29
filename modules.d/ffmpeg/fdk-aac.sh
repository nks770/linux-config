#!/bin/bash

# Functions for detecting and building the Fraunhofer FDK AAC codec
echo 'Loading fdk-aac...'

function fdkaacInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check fdkaac
if [ ! -f ${MODULEPATH}/fdk-aac/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_fdkaac() {
if fdkaacInstalled ${1}; then
  echo "fdk-aac ${1} is installed."
else
  build_fdkaac ${1}
fi
}

function build_fdkaac() {

# Get desired version number to install
fdkaac_v=${1}
if [ -z "${fdkaac_v}" ] ; then
  fdkaac_v=2.0.1
fi
fdkaac_srcdir=fdk-aac-${fdkaac_v}

echo "Installing fdk-aac ${fdkaac_v}..."

check_modules
module purge
module list

downloadPackage fdk-aac-${fdkaac_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${fdkaac_srcdir} ] ; then
  rm -rf ${tmp}/${fdkaac_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/fdk-aac-${fdkaac_v}.tar.gz
cd ${tmp}/${fdkaac_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

if [ ! -f configure ] ; then
./autogen.sh
fi

config="./configure --prefix=${opt}/fdk-aac-${fdkaac_v}"

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

# fdk-aac does not have any test suite
#if [ ${run_tests} -gt 0 ] ; then
#  make check
#  echo '>> Tests complete'
#  read k
#fi

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
mkdir -pv ${MODULEPATH}/fdk-aac
cat << eof > ${MODULEPATH}/fdk-aac/${fdkaac_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts fdkaac-${fdkaac_v} into your environment"
}

set VER ${fdkaac_v}
set PKG ${opt}/fdk-aac-\$VER

module-whatis   "Loads fdk-aac-${fdkaac_v}"
conflict fdkaac

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/${fdkaac_srcdir}

}
