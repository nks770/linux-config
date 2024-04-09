#!/bin/bash

# Functions for detecting and building xavs2
echo 'Loading xavs2...'

function xavs2Installed() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check xavs2
if [ ! -f ${MODULEPATH}/xavs2/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_xavs2() {
if xavs2Installed ${1}; then
  echo "xavs2 ${1} is installed."
else
  build_xavs2 ${1}
fi
}

function build_xavs2() {

# Get desired version number to install
xavs2_v=${1}
if [ -z "${xavs2_v}" ] ; then
  echo "ERROR: No xavs2 version specified!"
  exit 2
fi

case ${xavs2_v} in
  1.4 ) # 2019-04-21
   xavs2_nasm_ver=2.14.02 # 2018-12-26
  ;;
  *)
   echo "ERROR: Review needed for xavs2 ${xavs2_v}"
   exit 4 # Please review
  ;;
esac

echo "Installing xavs2 ${xavs2_v}..."
xavs2_srcdir=xavs2-${xavs2_v}
xavs2_prefix=${opt}/${xavs2_srcdir}

check_modules
check_nasm ${xavs2_nasm_ver}

downloadPackage xavs2-${xavs2_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${xavs2_srcdir} ] ; then
  rm -rf ${tmp}/${xavs2_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/xavs2-${xavs2_v}.tar.gz
cd ${tmp}/${xavs2_srcdir}/build/linux

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load nasm/${xavs2_nasm_ver}

config="./configure --prefix=${xavs2_prefix} --enable-shared"

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

#make
make -j ${ncpu}

if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Build complete'
  read k
fi

# There is no testsuite for xavs2
#
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
mkdir -pv ${MODULEPATH}/xavs2
cat << eof > ${MODULEPATH}/xavs2/${xavs2_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts xavs2-${xavs2_v} into your environment"
}

set VER ${xavs2_v}
set PKG ${opt}/xavs2-\$VER

module-whatis   "Loads xavs2-${xavs2_v}"
conflict xavs2

prepend-path PATH \$PKG/bin
prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/${xavs2_srcdir}

}
