#!/bin/bash

# Functions for detecting and building libaom
echo 'Loading libaom...'

function libaomInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check libaom
if [ ! -f ${MODULEPATH}/libaom/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_libaom() {
if libaomInstalled ${1}; then
  echo "libaom ${1} is installed."
else
  build_libaom ${1}
fi
}

function build_libaom() {

# Get desired version number to install
libaom_v=${1}
if [ -z "${libaom_v}" ] ; then
  libaom_v=1.0.0
fi
libaom_srcdir=libaom-${libaom_v}

case ${1} in
  1.0.0)              #Mon Jun 25 07:54:59 2018 -0700
   yasm_ver=1.3.0     # 2014-08-10
   cmake_ver=3.11.4   # 2018-06-14
   doxygen_ver=1.8.14 # 2017-12-25
   python_ver=3.6.5   # 2018-03-28
  ;;
  1.0.0-errata1-avif) #Thu Dec 12 10:50:24 2019 -0800
   yasm_ver=1.3.0     # 2014-08-10
   doxygen_ver=1.8.16 # 2019-08-08
#   cmake_ver=3.15.5   # 2019-10-30
#   python_ver=3.8.0   # 2019-10-14
   cmake_ver=3.19.2  # 2020-03-04 - earliest cmake that uses ncurses 6.2 and openssl 1.1.1i
   python_ver=3.7.10 # 2021-02-15 - earliest python 3.7 that uses ncurses 6.2 and openssl 1.1.1i
   libdir=lib # Directory where installed libraries go
  ;;
  3.5.0) #Wed Sep 21 12:36:24 2022 -0400
   yasm_ver=1.3.0
   cmake_ver=3.24.2   # 2022-09-13
   doxygen_ver=1.9.5  # 2022-08-26
   python_ver=3.10.7  # 2022-09-06
  ;;
  *)
   echo "ERROR: Review needed for libaom ${1}"
   exit 4 # Please review
  ;;
esac

## Optimized dependency strategy
#if [ "${dependency_strategy}" == "optimized" ] ; then
#  cmake_ver=${global_zlib}
#fi

echo "Installing libaom ${libaom_v}..."

check_modules
check_yasm ${yasm_ver}
check_cmake ${cmake_ver}
check_doxygen ${doxygen_ver}
check_python ${python_ver}

downloadPackage libaom-${libaom_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${libaom_srcdir} ] ; then
  rm -rf ${tmp}/${libaom_srcdir}
fi
if [ -d ${tmp}/${libaom_srcdir}_build ] ; then
  rm -rf ${tmp}/${libaom_srcdir}_build
fi

mkdir -pv ${tmp}/${libaom_srcdir}/build
cd ${tmp}/${libaom_srcdir}
tar xvfz ${pkg}/libaom-${libaom_v}.tar.gz
cd ${tmp}/${libaom_srcdir}/build

module purge
module load yasm/${yasm_ver}
module load cmake/${cmake_ver}
module load doxygen/${doxygen_ver}
module load Python/${python_ver}
module list

if [ ${debug} -gt 0 ] ; then
  echo ''
  module list
  echo cmake -L -G \"Unix Makefiles\" \
       -DPYTHON_EXECUTABLE:FILEPATH=$(which python3) \
       -DCMAKE_INSTALL_PREFIX=${opt}/libaom-${libaom_v} -DBUILD_SHARED_LIBS=on ..
  echo ''
  read k
fi

cmake -L -G "Unix Makefiles" \
-DPYTHON_EXECUTABLE:FILEPATH=$(which python3) \
-DCMAKE_INSTALL_PREFIX=${opt}/libaom-${libaom_v} -DBUILD_SHARED_LIBS=on ..

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

# Disabling the unit tests for now
# Running 'make runtests' downloads test data from the internet
# and then takes a long time to run them all
#if [ ${run_tests} -gt 0 ] ; then
#  make runtests
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
mkdir -pv ${MODULEPATH}/libaom
cat << eof > ${MODULEPATH}/libaom/${libaom_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts libaom-${libaom_v} into your environment"
}

set VER ${libaom_v}
set PKG ${opt}/libaom-\$VER

module-whatis   "Loads libaom-${libaom_v}"
conflict libaom

prepend-path PATH \$PKG/bin
prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/${libdir}
prepend-path PKG_CONFIG_PATH \$PKG/${libdir}/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/${libaom_srcdir}

}
