#!/bin/bash

# Functions for detecting and building Speex
# The Speex codec has been obsoleted by Opus. It will continue to be available, but since Opus is better than Speex in all aspects, users are encouraged to switch
echo 'Loading speex...'

function speexInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check speex
if [ ! -f ${MODULEPATH}/speex/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_speex() {
if speexInstalled ${1}; then
  echo "speex ${1} is installed."
else
  build_speex ${1}
fi
}

function build_speex() {

# Get desired version number to install
speex_v=${1}
if [ -z "${speex_v}" ] ; then
  speex_v=1.2.0
fi

case ${1} in
  1.2.0) # December 7, 2016
   speex_libogg_ver=1.3.5
  ;;
  *)
   echo "ERROR: Review needed for speex ${speex_v}"
   exit 4 # Please review
  ;;
esac

echo "Installing speex ${speex_v}..."
speex_srcdir=speex-${speex_v}

check_modules
check_libogg ${speex_libogg_ver}

downloadPackage speex-${speex_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${speex_srcdir} ] ; then
  rm -rf ${tmp}/${speex_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/speex-${speex_v}.tar.gz
cd ${tmp}/${speex_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load libogg/${speex_libogg_ver}

config="./configure --prefix=${opt}/speex-${speex_v}"
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
mkdir -pv ${MODULEPATH}/speex
cat << eof > ${MODULEPATH}/speex/${speex_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts speex-${speex_v} into your environment"
}

set VER ${speex_v}
set PKG ${opt}/speex-\$VER

module-whatis   "Loads speex-${speex_v}"
conflict speex
module load libogg/${speex_libogg_ver}
prereq libogg/${speex_libogg_ver}

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig
prepend-path MANPATH \$PKG/share/man
prepend-path PATH \$PKG/bin

eof

cd ${root}
rm -rf ${tmp}/${speex_srcdir}

}
