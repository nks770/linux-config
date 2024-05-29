#!/bin/bash

# Functions for detecting and building lerc
echo 'Loading lerc...'

function get_lerc_library() {
case ${1} in
  3.0)
    echo libLerc.so
  ;;
  *)
    echo ''
  ;;
esac
}

function lercInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check lerc
if [ ! -f ${MODULEPATH}/lerc/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_lerc() {
if lercInstalled ${1}; then
  echo "lerc ${1} is installed."
else
  build_lerc ${1}
fi
}

function build_lerc() {

# Get desired version number to install
lerc_v=${1}
if [ -z "${lerc_v}" ] ; then
  echo "ERROR: No lerc version specified!"
  exit 2
fi

case ${lerc_v} in
3.0) # 2021-07-30
   lerc_cmake_ver=3.21.1    # 2021-07-27
   ;;
*)
   echo "ERROR: Need review for lerc ${lerc_v}"
   exit 4
   ;;
esac

echo "Installing lerc ${lerc_v}..."

lerc_srcdir=lerc-${lerc_v}

check_modules
check_cmake ${lerc_cmake_ver}

downloadPackage ${lerc_srcdir}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${lerc_srcdir} ] ; then
  rm -rf ${tmp}/${lerc_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/${lerc_srcdir}.tar.gz
cd ${tmp}/${lerc_srcdir}/build/linux

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load cmake/${lerc_cmake_ver}

if [ ${debug} -gt 0 ] ; then
  echo ''
  module list
  echo cmake -L -G \"Unix Makefiles\" \
       -DCMAKE_BUILD_TYPE=Release \
       -DBUILD_SHARED_LIBS=ON \
       -DCMAKE_INSTALL_PREFIX=${opt}/lerc-${lerc_v} ../..
  echo ''
  read k
fi

cmake -L -G "Unix Makefiles" \
       -DCMAKE_BUILD_TYPE=Release \
       -DBUILD_SHARED_LIBS=ON \
       -DCMAKE_INSTALL_PREFIX=${opt}/lerc-${lerc_v} ../..

if [ ${debug} -gt 0 ] ; then
  echo '>> Configure complete'
  read k
fi

make
#make -j ${ncpu}

if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Build complete'
  read k
fi

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
mkdir -pv ${MODULEPATH}/lerc
cat << eof > ${MODULEPATH}/lerc/${lerc_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts lerc-${lerc_v} into your environment"
}

set VER ${lerc_v}
set PKG ${opt}/lerc-\$VER

module-whatis   "Loads lerc-${lerc_v}"
conflict lerc

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib

eof

cd ${root}
rm -rf ${tmp}/${lerc_srcdir}

}
