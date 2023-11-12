#!/bin/bash

# Functions for detecting and building xvidcore
echo 'Loading xvidcore...'

function xvidcoreInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check xvidcore
if [ ! -f ${MODULEPATH}/xvidcore/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_xvidcore() {
if xvidcoreInstalled ${1}; then
  echo "xvidcore ${1} is installed."
else
  build_xvidcore ${1}
fi
}

function build_xvidcore() {

# Get desired version number to install
xvidcore_v=${1}
if [ -z "${xvidcore_v}" ] ; then
  xvidcore_v=1.3.6
fi
xvidcore_srcdir=xvidcore

echo "Installing xvidcore ${xvidcore_v}..."

case ${1} in
  1.3.6) # 2019-12-08
#   nasm_ver=2.14.02  # 2018-12-26
   xvidcore_yasm_ver=1.3.0    # 2014-08-10
  ;;
  1.3.7) # 2019-12-29
#   nasm_ver=2.14.02  # 2018-12-26
   xvidcore_yasm_ver=1.3.0    # 2014-08-10
  ;;
  *)
   echo "ERROR: Need review for xvidcore ${1}"
   exit 4
   ;;
esac

check_modules
#check_nasm ${nasm_ver}
check_yasm ${xvidcore_yasm_ver}

downloadPackage xvidcore-${xvidcore_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${xvidcore_srcdir} ] ; then
  rm -rf ${tmp}/${xvidcore_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/xvidcore-${xvidcore_v}.tar.gz
cd ${tmp}/${xvidcore_srcdir}/build/generic

config="./configure --prefix=${opt}/xvidcore-${xvidcore_v}"

module purge
#module load nasm/${nasm_ver}
module load yasm/${xvidcore_yasm_ver}

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
mkdir -pv ${MODULEPATH}/xvidcore
cat << eof > ${MODULEPATH}/xvidcore/${xvidcore_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts xvidcore-${xvidcore_v} into your environment"
}

set VER ${xvidcore_v}
set PKG ${opt}/xvidcore-\$VER

module-whatis   "Loads xvidcore-${xvidcore_v}"
conflict xvidcore

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib

eof

cd ${root}
rm -rf ${tmp}/${xvidcore_srcdir}

}
