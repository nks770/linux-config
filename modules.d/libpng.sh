#!/bin/bash

# Functions for detecting and building libpng
echo 'Loading libpng...'

function libpngInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check libpng
if [ ! -f ${MODULEPATH}/libpng/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_libpng() {
if libpngInstalled ${1}; then
  echo "libpng ${1} is installed."
else
  build_libpng ${1}
fi
}

function build_libpng() {

# Get desired version number to install
libpng_v=${1}
if [ -z "${libpng_v}" ] ; then
  libpng_v=1.6.39
fi

case ${libpng_v} in
1.5.29) # 2017-08-24
   zlib_ver=1.2.11   #2017-01-15
   ;;
1.6.34) # 2017-09-29
   zlib_ver=1.2.11   #2017-01-15
   ;;
1.6.36) # 2018-12-02
   zlib_ver=1.2.11   #2017-01-15
   ;;
1.6.37) # 2019-04-15
   zlib_ver=1.2.11   #2017-01-15
   ;;
*)
   echo "ERROR: Need review for libpng ${libpng_v}"
   exit 4
   ;;
esac

# Optimized dependency strategy
if [ "${dependency_strategy}" == "optimized" ] ; then
  zlib_ver=${global_zlib}
fi

echo "Installing libpng ${libpng_v}..."
libpng_srcdir=libpng-${libpng_v}

check_modules
check_zlib ${zlib_ver}

downloadPackage libpng-${libpng_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${libpng_srcdir} ] ; then
  rm -rf ${tmp}/${libpng_srcdir}
fi

tar xvfz ${pkg}/libpng-${libpng_v}.tar.gz
cd ${tmp}/${libpng_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load zlib/${zlib_ver}

config="./configure --prefix=${opt}/libpng-${libpng_v} CFLAGS=-I${opt}/zlib-${zlib_ver}/include LDFLAGS=-L${opt}/zlib-${zlib_ver}/lib"

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
  make test
  # Note 'make check' also works
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
mkdir -pv ${MODULEPATH}/libpng
cat << eof > ${MODULEPATH}/libpng/${libpng_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts libpng-${libpng_v} into your environment"
}

set VER ${libpng_v}
set PKG ${opt}/libpng-\$VER

module-whatis   "Loads libpng-${libpng_v}"
conflict libpng
module load zlib/${zlib_ver}
prereq zlib/${zlib_ver}

prepend-path PATH \$PKG/bin
prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path MANPATH \$PKG/share/man
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/${libpng_srcdir}

}
