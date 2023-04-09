#!/bin/bash

# Functions for detecting and building gperf
echo 'Loading gperf...'

function gperfInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check gperf
if [ ! -f ${MODULEPATH}/gperf/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_gperf() {
if gperfInstalled ${1}; then
  echo "gperf ${1} is installed."
else
  build_gperf ${1}
fi
}

function build_gperf() {

# Get desired version number to install
gperf_v=${1}
if [ -z "${gperf_v}" ] ; then
  gperf_v=3.1
fi

echo "Installing gperf ${gperf_v}..."

check_modules
module purge

downloadPackage gperf-${gperf_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/gperf-${gperf_v} ] ; then
  rm -rf ${tmp}/gperf-${gperf_v}
fi

tar xvfz ${pkg}/gperf-${gperf_v}.tar.gz
cd ${tmp}/gperf-${gperf_v}

config="./configure --prefix=${opt}/gperf-${gperf_v}"

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
mkdir -pv ${MODULEPATH}/gperf
cat << eof > ${MODULEPATH}/gperf/${gperf_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts gperf-${gperf_v} into your environment"
}

set VER ${gperf_v}
set PKG ${opt}/gperf-\$VER

module-whatis   "Loads gperf-${gperf_v}"
conflict gperf

prepend-path PATH \$PKG/bin
prepend-path MANPATH \$PKG/share/man

eof

cd ${root}
rm -rf ${tmp}/gperf-${gperf_v}

}
