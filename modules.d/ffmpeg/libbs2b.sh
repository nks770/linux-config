#!/bin/bash

# Functions for detecting and building libbs2b
echo 'Loading libbs2b...'

function libbs2bInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check libbs2b
if [ ! -f ${MODULEPATH}/libbs2b/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_libbs2b() {
if libbs2bInstalled ${1}; then
  echo "libbs2b ${1} is installed."
else
  build_libbs2b ${1}
fi
}

function build_libbs2b() {

# Get desired version number to install
libbs2b_v=${1}
if [ -z "${libbs2b_v}" ] ; then
  libbs2b_v=3.1.0
fi

case ${libbs2b_v} in
  3.1.0-flac1.3.3) # 2009-06-04 / 2019-08-04
   libbs2b_vv=3.1.0
   libsndfile_ver=1.0.28-flac1.3.3 # 2017-04-02 / 2019-08-04
  ;;
  *)
   echo "ERROR: Review needed for libbs2b ${libbs2b_v}"
   exit 4 # Please review
  ;;
esac

libbs2b_srcdir=libbs2b-${libbs2b_vv}

echo "Installing libbs2b ${libbs2b_v}..."

check_modules
check_libsndfile ${libsndfile_ver}

downloadPackage libbs2b-${libbs2b_vv}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${libbs2b_srcdir} ] ; then
  rm -rf ${tmp}/${libbs2b_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/libbs2b-${libbs2b_vv}.tar.gz
cd ${tmp}/${libbs2b_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load libsndfile/${libsndfile_ver}

config="./configure --prefix=${opt}/libbs2b-${libbs2b_v}"
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
mkdir -pv ${MODULEPATH}/libbs2b
cat << eof > ${MODULEPATH}/libbs2b/${libbs2b_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts libbs2b-${libbs2b_v} into your environment"
}

set VER ${libbs2b_v}
set PKG ${opt}/libbs2b-\$VER

module-whatis   "Loads libbs2b-${libbs2b_v}"
conflict libbs2b
module load libsndfile/${libsndfile_ver}
prereq libsndfile/${libsndfile_ver}

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig
prepend-path PATH \$PKG/bin

eof

cd ${root}
rm -rf ${tmp}/${libbs2b_srcdir}

}
