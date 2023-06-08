#!/bin/bash

# Functions for detecting and building libbs2b

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
exit 4
# Get desired version number to install
libbs2b_v=${1}
if [ -z "${libbs2b_v}" ] ; then
  libbs2b_v=3.1.0
fi
libbs2b_srcdir=libbs2b-${libbs2b_v}

echo "Installing libbs2b ${libbs2b_v}..."

case ${1} in
  3.1.0)
   libbs2b_libsndfile_ver=1.0.28
  ;;
esac

check_modules
check_libsndfile ${libbs2b_libsndfile_ver}
module purge
module load libsndfile/${libbs2b_libsndfile_ver}
module list

downloadPackage libbs2b-${libbs2b_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${libbs2b_srcdir} ] ; then
  rm -rf ${tmp}/${libbs2b_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/libbs2b-${libbs2b_v}.tar.gz
cd ${tmp}/${libbs2b_srcdir}

./configure --prefix=${opt}/libbs2b-${libbs2b_v}
make -j ${ncpu} && make install

if [ ! $? -eq 0 ] ; then
  exit 4
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
module load libsndfile/${libbs2b_libsndfile_ver}
prereq libsndfile/${libbs2b_libsndfile_ver}

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
